from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection

def register_handler():
    data = request.get_json() or {}
    username = data.get("username")
    email = data.get("email")
    phone = data.get("phone")
    password = data.get("password")
    if not (username and email and phone and password):
        return jsonify(message="missing fields"), 400
    hashed = generate_password_hash(password)
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO users (username, email, phone, password_hash) VALUES (%s, %s, %s, %s)",
        (username, email, phone, hashed)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="User registered successfully"), 201

def login_handler():
    data = request.get_json() or {}
    email = data.get("email")
    password = data.get("password")
    if not (email and password):
        return jsonify(message="missing fields"), 400
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, password_hash FROM users WHERE email = %s", (email,))
    user = cur.fetchone()
    cur.close()
    conn.close()
    if not user or not check_password_hash(user[1], password):
        return jsonify(message="Invalid credentials"), 401
    token = create_access_token(identity=str(user[0]))
    return jsonify(access_token=token)
