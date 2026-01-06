# backend/test_sqlalchemy.py
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import engine, Base, create_tables, SessionLocal
from sqlalchemy import inspect

def test_database_connection():
    """Test database connection and table creation"""
    try:
        # Test connection
        with engine.connect() as conn:
            print("✅ Database connection successful via SQLAlchemy!")
        
        # Create tables
        create_tables()
        
        # Check if tables exist
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        print(f"✅ Tables in database: {tables}")
        
        # Check specific tables
        if 'vehicles' in tables and 'gps_locations' in tables:
            print("✅ Both vehicles and gps_locations tables exist!")
            
            # Check columns in vehicles table
            vehicle_columns = inspector.get_columns('vehicles')
            print(f"📋 Vehicles table columns: {[col['name'] for col in vehicle_columns]}")
            
            # Check columns in gps_locations table
            gps_columns = inspector.get_columns('gps_locations')
            print(f"📋 GPS locations table columns: {[col['name'] for col in gps_columns]}")
        
        # Try to insert a test vehicle
        from database import Vehicle
        db = SessionLocal()
        try:
            # Check if test vehicle already exists
            test_vehicle = db.query(Vehicle).filter_by(vehicle_id="TEST-001").first()
            if not test_vehicle:
                test_vehicle = Vehicle(
                    vehicle_id="TEST-001",
                    license_plate="TEST-123",
                    vehicle_type="test_vehicle"
                )
                db.add(test_vehicle)
                db.commit()
                print("✅ Test vehicle inserted successfully!")
            else:
                print("ℹ️  Test vehicle already exists")
        except Exception as e:
            print(f"❌ Error inserting test vehicle: {e}")
            db.rollback()
        finally:
            db.close()
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_database_connection()

    