from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection

def expense_handler():
    data = request.get_json() or {}
    trip_name = data.get("trip_name")
    amount = data.get("amount")
    description = data.get("description")
    paid_by_username = data.get("paid_by")
    date = data.get("date")

    if not (trip_name and amount and description and paid_by_username):
        return jsonify(message="missing fields"), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name,))
    trip_id = cur.fetchone()
    cur.execute("SELECT id FROM users WHERE username = %s", (paid_by_username,))
    paid_by = cur.fetchone()
    cur.execute(
        "INSERT INTO expenses (trip_id, amount, description, paid_by,date) VALUES (%s, %s, %s, %s,%s)",
        (trip_id, amount, description, paid_by, date)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Expense recorded successfully"), 201  
def expense_share_handler():
    data = request.get_json() or {}
    expense_id = data.get("expense_id")
    username = data.get("username")
    users_list=data.get("users_list")
    status = data.get("status")
    conn = get_db_connection()
    cur = conn.cursor()
    id_list=[]
    cur.execute("SELECT amount FROM Expenses WHERE expense_id = %s", (expense_id,))
    amount=cur.fetchone()[0]
    for user in users_list:
        cur.execute("SELECT id FROM users WHERE username = %s", (user,))
        user_id = cur.fetchone()
        id_list.append(user_id)
    for uid in id_list:
        share_amount=amount/len(id_list)
        cur.execute(
            "INSERT INTO ExpenseShare (expense_id, user_id, share_amount, status) VALUES (%s, %s, %s, %s)",
            (expense_id, uid, share_amount, status)
        )
    
    cur.execute("SELECT trip_id FROM Expenses WHERE expense_id = %s", (expense_id,))
    trip_id_of_expense = cur.fetchone()[0]
    update_settlement_for_trip(trip_id_of_expense)
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Expense share recorded successfully"), 201  
def update_settlement_for_trip(trip_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT paid_by, SUM(amount) 
        FROM Expenses 
        WHERE trip_id = %s 
        GROUP BY paid_by
    """, (trip_id,))
    paid_map = {row[0]: row[1] for row in cur.fetchall()}
    cur.execute("""
        SELECT user_id, SUM(share_amount)
        FROM ExpenseShare
        WHERE expense_id IN (SELECT expense_id FROM Expenses WHERE trip_id = %s)
        GROUP BY user_id
    """, (trip_id,))
    owe_map = {row[0]: row[1] for row in cur.fetchall()}
    all_users = set(list(paid_map.keys()) + list(owe_map.keys()))
    net = {u: paid_map.get(u, 0) - owe_map.get(u, 0) for u in all_users}

    creditors = [(u, amt) for u, amt in net.items() if amt > 0]
    debtors   = [(u, amt) for u, amt in net.items() if amt < 0]

    creditors.sort(key=lambda x: x[1])       
    debtors.sort(key=lambda x: x[1])         

    settlements = []
    while creditors and debtors:
        debtor, d_amt = debtors.pop(0)
        creditor, c_amt = creditors.pop(0)

        settle_amt = min(-d_amt, c_amt)

        settlements.append((debtor, creditor, settle_amt))

        d_amt += settle_amt
        c_amt -= settle_amt

        if d_amt < 0:
            debtors.insert(0, (debtor, d_amt))
        if c_amt > 0:
            creditors.insert(0, (creditor, c_amt))

    cur.execute("DELETE FROM Settlement WHERE trip_id = %s", (trip_id,))

   
    for from_u, to_u, amt in settlements:
        cur.execute("""
            INSERT INTO Settlement (trip_id, from_user, to_user, amount, date)
            VALUES (%s, %s, %s, %s, NOW())
        """, (trip_id, from_u, to_u, amt))

    conn.commit()
    cur.close()
    conn.close()
def get_settlement_json():
    trip_name = request.args.get("trip_name")
    trip_name=trip_name.strip()
    if not trip_name:
        return jsonify(message="trip_name parameter is required"), 400  
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name,))

    trip_id = cur.fetchone()

    
    if not trip_id:
        return jsonify(message="Trip not found"), 404

    cur.execute("""
        SELECT settlement_id, from_user, to_user, amount, date
        FROM Settlement
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
        "trip_id": trip_id,
        "settlements": settlements
    })

