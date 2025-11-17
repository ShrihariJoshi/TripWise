import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    return conn
def create_tables():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(150) NOT NULL,
        email VARCHAR(150) UNIQUE NOT NULL,
        phone VARCHAR(10),
        password_hash VARCHAR(255) NOT NULL
    );
    CREATE TABLE IF NOT EXISTS trips (
        trip_id SERIAL PRIMARY KEY,
        trip_name VARCHAR(255) NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        destination VARCHAR(255) NOT NULL,
        created_by INTEGER REFERENCES users(id),
        trip_budget FLOAT
    );
    CREATE TABLE IF NOT EXISTS TripMember (
        member_id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        trip_id INTEGER REFERENCES trips(trip_id),
        role VARCHAR(50) NOT NULL
    );
    CREATE TABLE IF NOT EXISTS Expenses (
        expense_id SERIAL PRIMARY KEY,
        trip_id INTEGER REFERENCES trips(trip_id),
        Paid_by INTEGER REFERENCES users(id),
        description TEXT,      
        amount FLOAT NOT NULL,
        date DATE NOT NULL
    );
    CREATE TABLE IF NOT EXISTS ExpenseShare (
        share_id SERIAL PRIMARY KEY,
        expense_id INTEGER REFERENCES Expenses(expense_id),
        user_id INTEGER REFERENCES users(id),
        share_amount FLOAT NOT NULL,
        status VARCHAR(50) NOT NULL
    );
    CREATE TABLE IF NOT EXISTS Itineary (
        itineary_id SERIAL PRIMARY KEY,
        trip_id INTEGER REFERENCES trips(trip_id),
        day_number INTEGER NOT NULL,
        title VARCHAR(255) NOT NULL,
        description TEXT
    );
    CREATE TABLE IF NOT EXISTS Activity (
        activity_id SERIAL PRIMARY KEY,
        itineary_id INTEGER REFERENCES Itineary(itineary_id),
        start_Time TIME NOT NULL,
        end_time TIME NOT NULL,
        location VARCHAR(255) NOT NULL,
        notes TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS Settlement (
                settlement_id SERIAL PRIMARY KEY,
                trip_id INTEGER REFERENCES trips(trip_id),
                from_user INTEGER REFERENCES users(id),
                to_user INTEGER REFERENCES users(id),
                amount FLOAT NOT NULL,
                date DATE NOT NULL
    );
    """)
    
    conn.commit()
    cur.close()
    conn.close()