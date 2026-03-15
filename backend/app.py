from flask import Flask, jsonify
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from flask_cors import CORS
from dotenv import load_dotenv
import os
from db import create_tables
from db import get_db_connection
import endpoints.auth as auth_handlers
import endpoints.trip as trip_handlers  
import endpoints.expense as expense_handlers
import endpoints.itinerary as i_handlers
import endpoints.profilemanagement as prof_handlers

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
app.add_url_rule("/expense", view_func=expense_handlers.expense_handler, methods=["POST"])
app.add_url_rule("/splits", view_func=expense_handlers.get_settlement_json, methods=["GET"])
app.add_url_rule("/iternary-dashboard", view_func=i_handlers.itinerary_handler, methods=["POST"])
app.add_url_rule("/itineary-details", view_func=i_handlers.itinerary_details, methods=["GET"])
app.add_url_rule("/trip-details", view_func=trip_handlers.get_trip_user, methods=["GET"])
app.add_url_rule("/user-expenses", view_func=expense_handlers.individual_settlements, methods=["GET"])
app.add_url_rule("/trip-expense-history", view_func=expense_handlers.get_trip_expense_history, methods=["GET"])
app.add_url_rule("/mark-done",view_func=expense_handlers.mark_settlement_done, methods=["POST"])
app.add_url_rule("/update_profile", view_func=prof_handlers.profile_update_profile, methods=["PATCH"])
app.add_url_rule("/reset_password", view_func=prof_handlers.reset_password, methods=["PATCH"])


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
    return jsonify(user_id=user[0],username=user[1], email=user[2], phone=user[3])

if __name__ == "__main__":
    create_tables()
    app.run(debug=True)
