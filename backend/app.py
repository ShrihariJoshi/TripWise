from flask import Flask, jsonify
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from flask_cors import CORS
from dotenv import load_dotenv
import os
from db import create_tables
from db import get_db_connection
import endpoints.auth as auth_handlers
import endpoints.trip as trip_handlers  

load_dotenv()
app = Flask(__name__)
CORS(app)
app.config["SECRET_KEY"]= os.getenv("SECRET_KEY", "dev-secret")
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "dev-jwt")
jwt = JWTManager(app)
app.add_url_rule("/register", view_func=auth_handlers.register_handler, methods=["POST"])
app.add_url_rule("/login", view_func=auth_handlers.login_handler, methods=["POST"])
app.add_url_rule("/trip", view_func=trip_handlers.trip_handler, methods=["POST"])
app.add_url_rule("/join_trip", view_func=trip_handlers.join_trip_handler, methods=["POST"])

@app.get("/me")
@jwt_required()
def me():
    user_id = get_jwt_identity()
    conn = get_db_connection()  
    cur = conn.cursor()
    cur.execute("SELECT id,username, email, phone FROM users WHERE id = %s", (user_id,))
    user = cur.fetchone()
    cur.close()
    conn.close()
    if not user:
        return jsonify(message="User not found"), 404
    return jsonify(user_id=[0],username=user[1], email=user[2], phone=user[3])

if __name__ == "__main__":
    create_tables()
    app.run(debug=True)
