from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection

def expense_handler():
    data = request.get_json() or {}
    trip_name = data.get("trip_name").strip()
    amount = data.get("amount")
    description = data.get("description")
    paid_by_username = data.get("paid_by")
    date = data.get("date")
    shares = data.get("shares")  

    if not (trip_name and amount is not None and description and paid_by_username and shares):
        return jsonify(message="missing fields"), 400

    if not isinstance(shares, dict) or not shares:
        return jsonify(message="shares must be a non-empty map of username->share_amount"), 400
    try:
        total_shares = sum(float(v) for v in shares.values())
        amount = float(amount)
    except (TypeError, ValueError):
        return jsonify(message="amount and shares must be numeric"), 400

  
    if abs(total_shares - amount) > 0.01:
        return jsonify(message="sum of shares does not match amount"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    print(trip_name)
    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute("SELECT id FROM users WHERE username = %s", (paid_by_username,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="paid_by user not found"), 404
    paid_by = row[0]

    cur.execute(
        "INSERT INTO expenses (trip_id, amount, description, paid_by, date) VALUES (%s, %s, %s, %s, %s) RETURNING expense_id",
        (trip_id, amount, description, paid_by, date)
    )
    row = cur.fetchone()
    if not row:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify(message="failed to create expense"), 500
    expense_id = row[0]
    for username, share_amount in shares.items():
        cur.execute("SELECT id FROM users WHERE username = %s", (username,))
        user_row = cur.fetchone()
        if not user_row:
            conn.rollback()
            cur.close()
            conn.close()
            return jsonify(message=f"user '{username}' not found"), 404
        user_id = user_row[0]
        try:
            share_amount = float(share_amount)
        except (TypeError, ValueError):
            conn.rollback()
            cur.close()
            conn.close()
            return jsonify(message="share amounts must be numeric"), 400

        cur.execute(
            "INSERT INTO ExpenseShare (expense_id, user_id, share_amount, status) VALUES (%s, %s, %s, %s)",
            (expense_id, user_id, share_amount, "unpaid")
        )

    try:
        update_settlement_for_trip(trip_id, conn=conn, cur=cur)
    except Exception:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify(message="failed to update settlements"), 500

    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Expense recorded successfully", expense_id=expense_id), 201
def update_settlement_for_trip(trip_id, conn=None, cur=None):
    if conn is None or cur is None:
        conn = get_db_connection()
        cur = conn.cursor()
        close_conn = True
    else:
        close_conn = False
    
    cur.execute("""
        SELECT paid_by, SUM(amount)
        FROM expenses
        WHERE trip_id = %s
        GROUP BY paid_by
    """, (trip_id,))
    paid_map = {row[0]: float(row[1]) for row in cur.fetchall()}
    cur.execute("""
        SELECT user_id, SUM(share_amount)
        FROM expenseShare
        WHERE expense_id IN (SELECT expense_id FROM expenses WHERE trip_id = %s)
        GROUP BY user_id
    """, (trip_id,))
    owe_map = {row[0]: float(row[1]) for row in cur.fetchall()}
    all_users = set(list(paid_map.keys()) + list(owe_map.keys()))
    net = {u: paid_map.get(u, 0.0) - owe_map.get(u, 0.0) for u in all_users}
    creditors = [(u, amt) for u, amt in net.items() if amt > 1e-9]
    debtors   = [(u, amt) for u, amt in net.items() if amt < -1e-9]
    creditors.sort(key=lambda x: x[1], reverse=True)
    debtors.sort(key=lambda x: x[1])  

    settlements = []
    cred_idx = 0
    debt_idx = 0
    while cred_idx < len(creditors) and debt_idx < len(debtors):
        creditor_id, c_amt = creditors[cred_idx]
        debtor_id, d_amt = debtors[debt_idx]  

        settle_amt = min(c_amt, -d_amt)
        if settle_amt <= 0:
            break

        settlements.append((debtor_id, creditor_id, round(settle_amt, 2)))

        c_amt -= settle_amt
        d_amt += settle_amt  

        
        if c_amt <= 0.009: 
            cred_idx += 1
        else:
            creditors[cred_idx] = (creditor_id, c_amt)

        if d_amt >= -0.009:  
            debt_idx += 1
        else:
            debtors[debt_idx] = (debtor_id, d_amt)
    cur.execute("DELETE FROM settlement WHERE trip_id = %s", (trip_id,))

    for from_u, to_u, amt in settlements:
        cur.execute("""
            INSERT INTO settlement (trip_id, from_user, to_user, amount, date)
            VALUES (%s, %s, %s, %s, NOW())
        """, (trip_id, from_u, to_u, amt))

    if close_conn:
        conn.commit()
        cur.close()
        conn.close()
def get_settlement_json():
    trip_name = request.args.get("trip_name", "")
    trip_name = trip_name.strip()
    if not trip_name:
        return jsonify(message="trip_name parameter is required"), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute("""
        SELECT settlement_id, from_user, to_user, amount, date
        FROM settlement
        WHERE trip_id = %s
        ORDER BY settlement_id ASC
    """, (trip_id,))
    rows = cur.fetchall()

    settlements = []
    for row in rows:
        settlements.append({
            "settlement_id": row[0],
            "from_user": row[1],
            "to_user": row[2],
            "amount": float(row[3]),
            "date": str(row[4])
        })

    cur.close()
    conn.close()

    return jsonify({
        "trip_name": trip_name,
        "settlements": settlements
    })
def individual_settlements():
    username = request.args.get("username", "").strip()
    if not username:
        return jsonify(message="username parameter is required"), 400
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id FROM users WHERE username = %s", (username,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="User not found"), 404

    user_id = row[0]
    cur.execute("""
        SELECT DISTINCT t.trip_id, t.trip_name
        FROM trips t
        JOIN expenses e ON t.trip_id = e.trip_id
        WHERE e.paid_by = %s
           OR e.expense_id IN (
                SELECT expense_id FROM expenseShare WHERE user_id = %s
           )
    """, (user_id, user_id))

    trips = cur.fetchall()
    trip_balances = []

    for trip_id, trip_name in trips:
        cur.execute("""
            SELECT COALESCE(SUM(amount), 0)
            FROM expenses
            WHERE trip_id = %s AND paid_by = %s
        """, (trip_id, user_id))
        total_paid = float(cur.fetchone()[0])
        cur.execute("""
            SELECT COALESCE(SUM(share_amount), 0)
            FROM expenseShare
            WHERE user_id = %s AND expense_id IN (
                SELECT expense_id FROM expenses WHERE trip_id = %s
            )
        """, (user_id, trip_id))
        total_owed = float(cur.fetchone()[0])
        net = total_paid - total_owed

        trip_balances.append({
            "trip_name": trip_name,
            "net_balance": round(net, 2),
            "status": "owed" if net > 0.01 else ("owes" if net < -0.01 else "settled")
        })

    cur.close()
    conn.close()

    return jsonify({
        "username": username,
        "trip_balances": trip_balances
    })
