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
    
    # Get trip_id
    cur.execute("SELECT trip_id FROM trips WHERE trip_name=%s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]
    
    # Get paid_by user_id
    cur.execute("SELECT id FROM users WHERE username=%s", (paid_by_username,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="paid_by user not found"), 404
    paid_by_id = row[0]
    
    # Insert expense
    cur.execute("""
        INSERT INTO expenses (trip_id, amount, description, paid_by, date)
        VALUES (%s,%s,%s,%s,%s)
        RETURNING expense_id
    """, (trip_id, amount, description, paid_by_id, date))
    expense_id = cur.fetchone()[0]
    
    # Insert expense shares - only for people who owe money
    for username, share_amount in shares.items():
        cur.execute("SELECT id FROM users WHERE username=%s", (username,))
        row = cur.fetchone()
        if not row:
            conn.rollback()
            cur.close()
            conn.close()
            return jsonify(message=f"user {username} not found"), 404

        share_amount = float(share_amount)
        if share_amount <= 0:
            continue
            
        user_id = row[0]
        
        # Skip if user paid for themselves - they don't owe themselves money
        if user_id == paid_by_id:
            continue

        # Create debt record: from_user owes to_user the share_amount
        cur.execute("""
            INSERT INTO expenseShare
            (expense_id, from_user, to_user, share_amount, amt_left)
            VALUES (%s,%s,%s,%s,%s)
        """, (expense_id, user_id, paid_by_id, share_amount, share_amount))

    update_settlement_for_trip(trip_id, cur)

    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Expense recorded successfully"), 201


def update_settlement_for_trip(trip_id, cur):
    """
    Calculate optimal settlements using greedy algorithm.
    Net balance = (amount owed TO you) - (amount you OWE to others)
    Both are calculated from expenseShare table.
    """
    print("Updating settlements for trip:", trip_id)
    cur.execute("DELETE FROM settlement WHERE trip_id=%s", (trip_id,))
    
    # Calculate how much is owed TO each user (they are creditors)
    cur.execute("""
        SELECT to_user, SUM(amt_left)
        FROM expenseShare
        WHERE expense_id IN (
            SELECT expense_id FROM expenses WHERE trip_id=%s
        )
        GROUP BY to_user
    """, (trip_id,))
    owed_to = {u: float(a) for u, a in cur.fetchall()}
    
    # Calculate how much each user OWES to others (they are debtors)
    cur.execute("""
        SELECT from_user, SUM(amt_left)
        FROM expenseShare
        WHERE expense_id IN (
            SELECT expense_id FROM expenses WHERE trip_id=%s
        )
        GROUP BY from_user
    """, (trip_id,))
    owes = {u: float(a) for u, a in cur.fetchall()}

    # Calculate net balance for each user
    users = set(owed_to) | set(owes)
    net = {u: owed_to.get(u, 0) - owes.get(u, 0) for u in users}

    print("Net balances:", net)

    # Split into creditors (owed money) and debtors (owe money)
    creditors = [(u, a) for u, a in net.items() if a > EPS]
    debtors = [(u, a) for u, a in net.items() if a < -EPS]

    creditors.sort(key=lambda x: x[1], reverse=True)
    debtors.sort(key=lambda x: x[1])

    # Greedy settlement algorithm
    i = j = 0
    while i < len(creditors) and j < len(debtors):
        cu, ca = creditors[i]
        du, da = debtors[j]

        settle = min(ca, -da)
        print(f"Settlement: User {du} owes User {cu} amount {round(settle, 2)}")
        
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
    """
    Mark a settlement as complete by updating expenseShare records,
    handling transitive debts, and simplifying mutual debts.
    """
    data = request.get_json() or {}
    settlement_id = data.get("settlement_id")
    
    if not settlement_id:
        return jsonify(message="settlement_id required"), 400
    
    conn = get_db_connection()
    cur = conn.cursor()
    
    # Get settlement details
    cur.execute("""
        SELECT trip_id, from_user, to_user, amount
        FROM settlement WHERE settlement_id=%s
    """, (settlement_id,))
    result = cur.fetchone()
    
    if not result:
        cur.close()
        conn.close()
        return jsonify(message="Settlement not found"), 404
    
    trip_id, debtor, creditor, amount = result
    remaining = float(amount)
    
    # Step 1: Pay direct debts first (debtor→creditor)
    cur.execute("""
        SELECT expense_id, amt_left
        FROM expenseShare
        WHERE from_user=%s AND to_user=%s AND amt_left > 0
        ORDER BY expense_id
    """, (debtor, creditor))
    
    shares = cur.fetchall()
    
    for expense_id, amt_left in shares:
        if remaining <= EPS:
            break
        
        payment = min(remaining, float(amt_left))
        new_amt_left = float(amt_left) - payment
        
        if new_amt_left <= EPS:
            cur.execute("""
                DELETE FROM expenseShare
                WHERE expense_id=%s AND from_user=%s AND to_user=%s
            """, (expense_id, debtor, creditor))
        else:
            cur.execute("""
                UPDATE expenseShare
                SET amt_left = %s
                WHERE expense_id=%s AND from_user=%s AND to_user=%s
            """, (new_amt_left, expense_id, debtor, creditor))
        
        remaining -= payment
    
    # Step 2: If settlement amount exceeds direct debts, handle transitive debts
    # Find intermediate users where debtor→intermediate AND intermediate→creditor exist
    if remaining > EPS:
        cur.execute("""
            SELECT DISTINCT es1.to_user as intermediate
            FROM expenseShare es1
            JOIN expenses e1 ON es1.expense_id = e1.expense_id
            JOIN expenseShare es2 ON es2.from_user = es1.to_user
            JOIN expenses e2 ON es2.expense_id = e2.expense_id
            WHERE e1.trip_id = %s AND e2.trip_id = %s
                AND es1.from_user = %s 
                AND es2.to_user = %s
                AND es1.amt_left > 0 AND es2.amt_left > 0
        """, (trip_id, trip_id, debtor, creditor))
        
        intermediates = [row[0] for row in cur.fetchall()]
        
        for intermediate in intermediates:
            if remaining <= EPS:
                break
            
            # Get debtor→intermediate debts
            cur.execute("""
                SELECT e.expense_id, amt_left
                FROM expenseShare es
                JOIN expenses e ON es.expense_id = e.expense_id
                WHERE e.trip_id = %s AND es.from_user = %s AND es.to_user = %s AND es.amt_left > 0
                ORDER BY es.expense_id
            """, (trip_id, debtor, intermediate))
            debtor_to_int = cur.fetchall()
            
            # Get intermediate→creditor debts
            cur.execute("""
                SELECT e.expense_id, amt_left
                FROM expenseShare es
                JOIN expenses e ON es.expense_id = e.expense_id
                WHERE e.trip_id = %s AND es.from_user = %s AND es.to_user = %s AND es.amt_left > 0
                ORDER BY es.expense_id
            """, (trip_id, intermediate, creditor))
            int_to_creditor = cur.fetchall()
            
            # Calculate max we can reduce through this path
            total_debtor_int = sum(float(amt) for _, amt in debtor_to_int)
            total_int_creditor = sum(float(amt) for _, amt in int_to_creditor)
            max_reduction = min(remaining, total_debtor_int, total_int_creditor)
            
            if max_reduction > EPS:
                # Reduce both paths by max_reduction
                reduce_debt(cur, trip_id, debtor, intermediate, max_reduction)
                reduce_debt(cur, trip_id, intermediate, creditor, max_reduction)
                remaining -= max_reduction

    # Step 3: Simplify mutual debts (net out opposing edges)
    simplify_mutual_debts(cur, trip_id)

    # Delete the settlement record
    cur.execute("DELETE FROM settlement WHERE settlement_id=%s", (settlement_id,))
    
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Settlement completed"), 200


def simplify_mutual_debts(cur, trip_id):
    """
    Simplify mutual debts by netting out opposing edges.
    If A→B: X and B→A: Y exist, simplify to one edge with net amount.
    """
    cur.execute("""
        SELECT DISTINCT es.from_user, es.to_user
        FROM expenseShare es
        JOIN expenses e ON es.expense_id = e.expense_id
        WHERE e.trip_id = %s AND es.amt_left > 0
    """, (trip_id,))
    
    edges = cur.fetchall()
    processed_pairs = set()
    
    for user1, user2 in edges:
        if (user1, user2) in processed_pairs or (user2, user1) in processed_pairs:
            continue
        
        processed_pairs.add((user1, user2))
        
        # Get total debt user1→user2
        cur.execute("""
            SELECT SUM(amt_left)
            FROM expenseShare es
            JOIN expenses e ON es.expense_id = e.expense_id
            WHERE e.trip_id = %s AND es.from_user = %s AND es.to_user = %s AND es.amt_left > 0
        """, (trip_id, user1, user2))
        result1 = cur.fetchone()
        debt_1_to_2 = float(result1[0]) if result1 and result1[0] else 0
        
        # Get total debt user2→user1
        cur.execute("""
            SELECT SUM(amt_left)
            FROM expenseShare es
            JOIN expenses e ON es.expense_id = e.expense_id
            WHERE e.trip_id = %s AND es.from_user = %s AND es.to_user = %s AND es.amt_left > 0
        """, (trip_id, user2, user1))
        result2 = cur.fetchone()
        debt_2_to_1 = float(result2[0]) if result2 and result2[0] else 0
        
        # If both edges exist, net them out
        if debt_1_to_2 > EPS and debt_2_to_1 > EPS:
            smaller_debt = min(debt_1_to_2, debt_2_to_1)
            
            # Reduce both debts by the smaller amount
            reduce_debt(cur, trip_id, user1, user2, smaller_debt)
            reduce_debt(cur, trip_id, user2, user1, smaller_debt)


def reduce_debt(cur, trip_id, from_user, to_user, amount):
    """Helper function to reduce debt by a specific amount."""
    cur.execute("""
        SELECT es.expense_id, es.amt_left
        FROM expenseShare es
        JOIN expenses e ON es.expense_id = e.expense_id
        WHERE e.trip_id = %s AND es.from_user = %s AND es.to_user = %s AND es.amt_left > 0
        ORDER BY es.expense_id
    """, (trip_id, from_user, to_user))
    
    shares = cur.fetchall()
    remaining = float(amount)
    
    for expense_id, amt_left in shares:
        if remaining <= EPS:
            break
        
        payment = min(remaining, float(amt_left))
        new_amt_left = float(amt_left) - payment
        
        if new_amt_left <= EPS:
            cur.execute("""
                DELETE FROM expenseShare
                WHERE expense_id=%s AND from_user=%s AND to_user=%s
            """, (expense_id, from_user, to_user))
        else:
            cur.execute("""
                UPDATE expenseShare
                SET amt_left = %s
                WHERE expense_id=%s AND from_user=%s AND to_user=%s
            """, (new_amt_left, expense_id, from_user, to_user))
        
        remaining -= payment


def delete_all_debt(cur, trip_id, from_user, to_user):
    """Helper function to delete all debt between two users."""
    cur.execute("""
        DELETE FROM expenseShare
        WHERE expense_id IN (
            SELECT expense_id FROM expenses WHERE trip_id = %s
        ) AND from_user = %s AND to_user = %s
    """, (trip_id, from_user, to_user))


def get_settlement_json():
    """Get all settlements for a trip."""
    trip_name = request.args.get("trip_name", "").strip()
    if not trip_name:
        return jsonify(message="trip_name required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT trip_id FROM trips WHERE trip_name=%s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
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
    """Get individual user's balance across all trips."""
    username = request.args.get("username", "").strip()
    if not username:
        return jsonify(message="username required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT id FROM users WHERE username=%s", (username,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="User not found"), 404
    user_id = row[0]

    # Calculate net balance per trip
    # Positive = owed to user, Negative = user owes
    cur.execute("""
        SELECT t.trip_name,
        COALESCE(SUM(CASE WHEN es.to_user=%s THEN es.amt_left ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN es.from_user=%s THEN es.amt_left ELSE 0 END), 0) as net_balance
        FROM trips t
        JOIN expenses e ON t.trip_id = e.trip_id
        LEFT JOIN expenseShare es ON e.expense_id = es.expense_id
        WHERE (es.from_user=%s OR es.to_user=%s) AND es.amt_left > 0
        GROUP BY t.trip_name
        HAVING ABS(COALESCE(SUM(CASE WHEN es.to_user=%s THEN es.amt_left ELSE 0 END), 0) -
               COALESCE(SUM(CASE WHEN es.from_user=%s THEN es.amt_left ELSE 0 END), 0)) > %s
    """, (user_id, user_id, user_id, user_id, user_id, user_id, EPS))

    result = [{
        "trip_name": trip,
        "net_balance": round(float(net), 2),
        "status": "owed" if net > EPS else "owes" if net < -EPS else "settled"
    } for trip, net in cur.fetchall()]

    cur.close()
    conn.close()
    return jsonify(username=username, trip_balances=result)


def get_trip_expense_history():
    """Get all expenses for a trip."""
    trip_name = request.args.get("trip_name", "").strip()
    if not trip_name:
        return jsonify(message="trip_name required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT trip_id FROM trips WHERE trip_name=%s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute("""
        SELECT e.expense_id, e.amount, e.description, u.username, e.date
        FROM expenses e
        JOIN users u ON e.paid_by=u.id
        WHERE e.trip_id=%s
        ORDER BY e.date DESC
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