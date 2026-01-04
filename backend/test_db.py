# test_db.py
import psycopg2

try:
    conn = psycopg2.connect(
        host="localhost",
        database="fleet_tracker",
        user="fleet_admin",
        password="FleetTracker!2024@secure",
        port="5432"  # Default PostgreSQL port
    )
    print("✅ Database connection successful!")
    
    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    print(f"PostgreSQL version: {cursor.fetchone()[0]}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Database connection failed: {e}")