from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection
from datetime import datetime

def trip_handler():
    data = request.get_json() or {}
    trip_name = data.get("trip_name")
    start_date = data.get("start_date")
    end_date = data.get("end_date")
    destination = data.get("destination")
    created_by_username= data.get("created_by")
    trip_budget = data.get("trip_budget")

    if not (trip_name and start_date and end_date and destination and created_by_username):
        return jsonify(message="missing fields"), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id FROM users WHERE username = %s", (created_by_username,))
    created_by = cur.fetchone()[0]
    cur.execute(
        "INSERT INTO trips (trip_name, start_date, end_date, destination, created_by, trip_budget) VALUES (%s, %s, %s, %s, %s, %s)",
        (trip_name, start_date, end_date, destination, created_by, trip_budget)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Trip created successfully"), 201
def join_trip_handler():
    data = request.get_json() or {}
    username = data.get("username")
    tripname = data.get("tripname")
    role = data.get("role")
    print(username,tripname,role)
    if not (username and tripname and role):
        return jsonify(message="missing fields"), 400

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id FROM users WHERE username = %s", (username,))
    user_id = cur.fetchone()[0]
    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (tripname,))
    trip_id = cur.fetchone()[0]

    print(user_id,trip_id)
    cur.execute(
        "INSERT INTO TripMember (user_id, trip_id, role) VALUES (%s, %s, %s)",
        (user_id, trip_id, role)
    )
    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Joined trip successfully"), 201
def get_trip_user():
    user_name=request.args.get("username")
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id FROM users WHERE username = %s", (user_name,))
    user_id = cur.fetchone()[0]
    cur.execute("select tm.trip_id, t.trip_name ,t.destination , t.start_date , t.end_date from trips t inner join TripMember tm on t.trip_id=tm.trip_id where tm.user_id=%s",(user_id,))
    trips = cur.fetchall()
    trip_list = []
    for trip in trips:
        trip_info = {
            "trip_id": trip[0],
            "trip_name": trip[1],
            "destination": trip[2],
            "start_date": trip[3],
            "end_date": trip[4],
            "status": "completed" if trip[4] < datetime.now().date() else "ongoing"
        }
        trip_list.append(trip_info)
    cur.close()
    conn.close()
    return jsonify(trips=trip_list), 200