from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection

def expense_handler():
    data = request.get_json() or {}
    trip_id = data.get("trip_id")
    amount = data.get("amount")
    description = data.get("description")
    paid_by_username = data.get("paid_by")
    date = data.get("date")

    if not (trip_id and amount and description and paid_by_username):
        return jsonify(message="missing fields"), 400

    conn = get_db_connection()
    cur = conn.cursor()
    paid_by = cur.execute("SELECT id FROM users WHERE username = %s", (paid_by_username,))
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
    amount=cur.execute("SELECT amount FROM Expenses WHERE expense_id = %s", (expense_id,))
    for user in users_list:
        user_id = cur.execute("SELECT id FROM users WHERE username = %s", (user,))
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