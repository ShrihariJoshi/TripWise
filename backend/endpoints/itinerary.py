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
    location = data.get("location")
    start_time = data.get("start_time")
    end_time = data.get("end_time")

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
        "INSERT INTO itinerary (trip_id, day_number, title, description,loctation,start_time,end_time) VALUES (%s, %s, %s, %s,%s,%s,%s) RETURNING itinerary_id",
        (trip_id, day_number, title, description, location,start_time,end_time)
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
def itinerary_details():
    trip_name=request.args.get("trip_name")
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT trip_id FROM trips WHERE trip_name = %s", (trip_name,))
    row = cur.fetchone()
    if not row:
        cur.close()
        conn.close()
        return jsonify(message="Trip not found"), 404
    trip_id = row[0]
    cur.execute("""
        SELECT day_number, title, description,loctation,start_time,end_time
        FROM itinerary
        WHERE trip_id = %s
        ORDER BY day_number ASC
    """, (trip_id,))
    rows = cur.fetchall()

    itinerary_items = []
    for row in rows:
        itinerary_items.append({
            "day_number": row[0],
            "title": row[1],
            "description": row[2],
            "location":row[3],
            "start_time": row[4].isoformat(),
            "end_time": row[5].isoformat(),
        })
    cur.close()
    conn.close()
    return jsonify(itinerary_items=itinerary_items)

