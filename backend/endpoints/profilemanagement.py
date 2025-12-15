from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection

def profile_update_profile():
    data = request.get_json()
    username = data.get("user_id")
    new_email = data.get("email")
    new_phone = data.get("phone")

    if not username:
        return jsonify(message="user_id is required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT id FROM users WHERE username = %s", (username,))
    user_row = cur.fetchone()
    if not user_row:
        cur.close()
        conn.close()
        return jsonify(message="User not found"), 404
    user_id = user_row[0]

    conn = get_db_connection()
    cur = conn.cursor()
    if new_email:
        cur.execute("UPDATE users SET email = %s WHERE id = %s", (new_email, user_id))
    if new_phone:
        cur.execute("UPDATE users SET phone = %s WHERE id = %s", (new_phone, user_id))

    conn.commit()
    cur.close()
    conn.close()

    return jsonify({
        "message": "Profile updated successfully",
        "email": new_email,
        "phone": new_phone
    }), 200
def reset_password():
    data = request.get_json()
    username = data.get("username")
    old_password = data.get("old_password")
    new_password = data.get("new_password")

    if not username or not old_password or not new_password:
        return jsonify(message="username, old_password, and new_password are required"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT id, password_hash FROM users WHERE username = %s", (username,))
    user_row = cur.fetchone()
    if not user_row:
        cur.close()
        conn.close()
        return jsonify(message="User not found"), 404

    user_id, password_hash = user_row
    if not check_password_hash(password_hash, old_password):
        cur.close()
        conn.close()
        return jsonify(message="Old password is incorrect"), 401

    new_password_hash = generate_password_hash(new_password)
    cur.execute("UPDATE users SET password_hash = %s WHERE id = %s", (new_password_hash, user_id))

    conn.commit()
    cur.close()
    conn.close()

    return jsonify(message="Password updated successfully"), 200