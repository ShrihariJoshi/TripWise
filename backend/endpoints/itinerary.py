from werkzeug.security import generate_password_hash, check_password_hash
from flask import request, jsonify
from flask_jwt_extended import create_access_token
from db import get_db_connection

def itinerary_handler():
    data = request.get_json() or {}
    trip_name = data.get("trip_name").strip()
    day_number = data.get("day_number")
    title = data.get("title")
    description = data.get("description", "")

    if not (trip_name and day_number is not None and title):
        return jsonify(message="missing fields"), 400

    try:
        day_number = int(day_number)
    except (TypeError, ValueError):
        return jsonify(message="day_number must be an integer"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute(
        "INSERT INTO itinerary (trip_id, day_number, title, description) VALUES (%s, %s, %s, %s) RETURNING itinerary_id",
        (trip_id, day_number, title, description)
    )
    row = cur.fetchone()
    if not row:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify(message="failed to create itinerary item"), 500
    itinerary_id = row[0]

    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Itinerary item recorded successfully", itinerary_id=itinerary_id), 201
def activity_handler():
    data = request.get_json() or {}
    itinerary_id = data.get("itinerary_id")
    start_time = data.get("start_time")
    end_time = data.get("end_time")
    location = data.get("location")
    description = data.get("description", "")

    if not (itinerary_id and start_time and end_time and location):
        return jsonify(message="missing fields"), 400

    try:
        itinerary_id = int(itinerary_id)
    except (TypeError, ValueError):
        return jsonify(message="itinerary_id must be an integer"), 400

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT itinerary_id FROM itinerary WHERE itinerary_id = %s", (itinerary_id,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Itinerary item not found"), 404

    cur.execute(
        "INSERT INTO activity (itinerary_id, start_time, end_time, location, description) VALUES (%s, %s, %s, %s, %s) RETURNING activity_id",
        (itinerary_id, start_time, end_time, location, description)
    )
    row = cur.fetchone()
    if not row:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify(message="failed to create activity"), 500
    activity_id = row[0]

    conn.commit()
    cur.close()
    conn.close()
    return jsonify(message="Activity recorded successfully", activity_id=activity_id), 201
def get_itinerary_for_trip():
    trip_name = request.args.get("trip_name", "").strip()
    if not trip_name:
        return jsonify(message="trip_name is required"), 400
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name.strip(),))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]

    cur.execute("""
        SELECT itinerary_id, day_number, title, description
        FROM itinerary
        WHERE trip_id = %s
        ORDER BY day_number ASC
    """, (trip_id,))
    itinerary_items = [
        {
            "itinerary_id": row[0],
            "day_number": row[1],
            "title": row[2],
            "description": row[3]
        }
        for row in cur.fetchall()
    ]

    cur.close()
    conn.close()
    return jsonify(itinerary=itinerary_items), 200