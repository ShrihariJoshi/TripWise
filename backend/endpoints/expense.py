from flask import request, jsonify
from db import get_db_connection

EPS = 0.01
def expense_handler():
    data = request.get_json() or {}

    trip_name = data.get("trip_name", "").strip()
    amount = float(data.get("amount", 0))
    description = data.get("description", "")
    paid_by_username = data.get("paid_by")
    date = data.get("date")
    shares = data.get("shares", {})

    if not (trip_name and amount > 0 and paid_by_username and shares):
        return jsonify(message="missing fields"), 400

    if abs(sum(float(v) for v in shares.values()) - amount) > EPS:
        return jsonify(message="sum of shares does not match amount"), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT trip_id FROM trips WHERE trip_name=%s", (trip_name,))
    row = cur.fetchone()
    if not row:
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]
    cur.execute("SELECT id FROM users WHERE username=%s", (paid_by_username,))
    row = cur.fetchone()
    if not row:
        return jsonify(message="paid_by user not found"), 404
    paid_by_id = row[0]
    cur.execute("""
        INSERT INTO expenses (trip_id, amount, description, paid_by, date)
        VALUES (%s,%s,%s,%s,%s)
        RETURNING expense_id
    """, (trip_id, amount, description, paid_by_id, date))
    expense_id = cur.fetchone()[0]
    for username, share_amount in shares.items():
        cur.execute("SELECT id FROM users WHERE username=%s", (username,))
        row = cur.fetchone()
        if not row:
            conn.rollback()
            return jsonify(message=f"user {username} not found"), 404

        share_amount = float(share_amount)
        if share_amount <= 0:
            continue
        if row[0] == paid_by_id:
            continue

        cur.execute("""
            INSERT INTO expenseShare
            (expense_id, from_user, to_user, share_amount, amt_left)
            VALUES (%s,%s,%s,%s,%s)
        """, (expense_id, row[0], paid_by_id, share_amount, share_amount))

    update_settlement_for_trip(trip_id, cur)

    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Expense recorded successfully"), 201
def update_settlement_for_trip(trip_id, cur):
    print("Updating settlements for trip:", trip_id)
    cur.execute("DELETE FROM settlement WHERE trip_id=%s", (trip_id,))
    cur.execute("""
        SELECT paid_by, SUM(amount)
        FROM expenses
        WHERE trip_id=%s
        GROUP BY paid_by
    """, (trip_id,))
    paid = {u: float(a) for u, a in cur.fetchall()}
    cur.execute("""
        SELECT from_user, SUM(amt_left)
        FROM expenseShare
        WHERE expense_id IN (
            SELECT expense_id FROM expenses WHERE trip_id=%s
        )
        GROUP BY from_user
    """, (trip_id,))
    owed = {u: float(a) for u, a in cur.fetchall()}

    users = set(paid) | set(owed)
    net = {u: paid.get(u, 0) - owed.get(u, 0) for u in users}

    creditors = [(u, a) for u, a in net.items() if a > EPS]
    debtors = [(u, a) for u, a in net.items() if a < -EPS]

    creditors.sort(key=lambda x: x[1], reverse=True)
    debtors.sort(key=lambda x: x[1])

    i = j = 0
    while i < len(creditors) and j < len(debtors):
        cu, ca = creditors[i]
        du, da = debtors[j]

        settle = min(ca, -da)
        print(trip_id, du, cu, round(settle, 2))
        cur.execute("""
            INSERT INTO settlement (trip_id, from_user, to_user, amount, date)
            VALUES (%s,%s,%s,%s,NOW())
        """, (trip_id, du, cu, round(settle, 2)))

        creditors[i] = (cu, ca - settle)
        debtors[j] = (du, da + settle)

        if creditors[i][1] <= EPS:
            i += 1
        if debtors[j][1] >= -EPS:
            j += 1
def mark_settlement_done():
    data = request.get_json() or {}
    settlement_id = data.get("settlement_id")
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT trip_id, from_user, to_user, amount
        FROM settlement WHERE settlement_id=%s
    """, (settlement_id,))
    trip_id, debtor, creditor, amount = cur.fetchone()
    
   
    cur.execute("""
        SELECT expense_id, amt_left
        FROM expenseShare
        WHERE from_user=%s AND to_user=%s AND amt_left > 0
        ORDER BY expense_id
    """, (debtor, creditor))
    
    shares = cur.fetchall()
    remaining = float(amount)
    
    for expense_id, amt_left in shares:
        if remaining <= EPS:
            break
        
        payment = min(remaining, amt_left)
        cur.execute("""
            UPDATE expenseShare
            SET amt_left = amt_left - %s
            WHERE expense_id=%s AND from_user=%s AND to_user=%s
        """, (payment, expense_id, debtor, creditor))
        remaining -= payment

    cur.execute("""
        SELECT SUM(amt_left)
        FROM expenseShare
        WHERE from_user=%s AND to_user=%s
    """, (debtor, creditor))
    
    remaining_debt = cur.fetchone()[0]
    if remaining_debt is None or remaining_debt <= EPS:
        
        cur.execute("""
            SELECT  to_user FROM expenseShare WHERE from_user=%s AND amt_left > 0
        """, (debtor,))
        
        other_creditors = [row[0] for row in cur.fetchall()]
        for other_creditor in other_creditors:
            cur.execute("""
                UPDATE expenseShare
                SET amt_left = 0
                WHERE from_user=%s AND to_user=%s
            """, (debtor, other_creditor))

    cur.execute("DELETE FROM settlement WHERE settlement_id=%s", (settlement_id,))
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Settlement completed"), 200


def get_settlement_json():
    trip_name = request.args.get("trip_name", "").strip()
    if not trip_name:
        return jsonify(message="trip_name required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT trip_id FROM trips WHERE trip_name=%s", (trip_name,))
    row = cur.fetchone()
    if not row:
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute("""
        SELECT s.settlement_id, u1.username, u2.username, s.amount
        FROM settlement s
        JOIN users u1 ON s.from_user=u1.id
        JOIN users u2 ON s.to_user=u2.id
        WHERE s.trip_id=%s
    """, (trip_id,))

    settlements = [{
        "settlement_id": sid,
        "from_user": f,
        "to_user": t,
        "amount": float(a)
    } for sid, f, t, a in cur.fetchall()]

    cur.close()
    conn.close()

    return jsonify(trip_name=trip_name, settlements=settlements)



def individual_settlements():
    username = request.args.get("username", "").strip()
    if not username:
        return jsonify(message="username required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT id FROM users WHERE username=%s", (username,))
    row = cur.fetchone()
    if not row:
        return jsonify(message="User not found"), 404
    user_id = row[0]

    cur.execute("""
        SELECT t.trip_name,
        COALESCE(SUM(CASE WHEN es.to_user=%s THEN es.amt_left ELSE 0 END),0) -
        COALESCE(SUM(CASE WHEN es.from_user=%s THEN es.amt_left ELSE 0 END),0)
        FROM trips t
        JOIN expenses e ON t.trip_id=e.trip_id
        LEFT JOIN expenseShare es ON e.expense_id=es.expense_id
        WHERE es.amt_left > 0 OR es.amt_left IS NULL
        GROUP BY t.trip_name
    """, (user_id, user_id))

    result = [{
        "trip_name": trip,
        "net_balance": round(net, 2),
        "status": "owed" if net > EPS else "owes" if net < -EPS else "settled"
    } for trip, net in cur.fetchall()]

    cur.close()
    conn.close()
    return jsonify(username=username, trip_balances=result)



def get_trip_expense_history():
    trip_name = request.args.get("trip_name", "").strip()
    if not trip_name:
        return jsonify(message="trip_name required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT trip_id FROM trips WHERE trip_name=%s", (trip_name,))
    row = cur.fetchone()
    if not row:
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute("""
        SELECT e.expense_id, e.amount, e.description, u.username, e.date
        FROM expenses e
        JOIN users u ON e.paid_by=u.id
        WHERE e.trip_id=%s
        ORDER BY e.date
    """, (trip_id,))

    expenses = [{
        "expense_id": i,
        "amount": float(a),
        "description": d,
        "paid_by": u,
        "date": str(dt)
    } for i, a, d, u, dt in cur.fetchall()]

    cur.close()
    conn.close()

    return jsonify(trip_name=trip_name, expenses=expenses)
