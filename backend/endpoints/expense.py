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
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Expense share recorded successfully"), 201  