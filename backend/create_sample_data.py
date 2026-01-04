from database import SessionLocal, Vehicle, GPSLocation
from datetime import datetime, timedelta
import random

def create_sample_data():
    print("📊 Creating sample data for testing...")
    db = SessionLocal()
    
    try:
        # Sample vehicles
        vehicles = [
            {"vehicle_id": "TRUCK-001", "license_plate": "ABC123", "vehicle_type": "delivery_truck"},
            {"vehicle_id": "VAN-001", "license_plate": "XYZ789", "vehicle_type": "delivery_van"},
            {"vehicle_id": "CAR-001", "license_plate": "DEF456", "vehicle_type": "sedan"},
            {"vehicle_id": "BIKE-001", "license_plate": "MOTO01", "vehicle_type": "motorcycle"},
        ]
        
        # Create vehicles
        created_count = 0
        for v_data in vehicles:
            vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == v_data["vehicle_id"]).first()
            if not vehicle:
                vehicle = Vehicle(**v_data)
                db.add(vehicle)
                created_count += 1
                print(f"  Created vehicle: {v_data['vehicle_id']}")
        
        db.commit()
        
        if created_count > 0:
            print(f"✅ Created {created_count} new vehicles")
        else:
            print("ℹ️  All vehicles already exist")
        
        # Create sample GPS locations (past 24 hours)
        print("\n📍 Creating sample GPS locations...")
        total_locations = 0
        
        for vehicle_id in [v["vehicle_id"] for v in vehicles]:
            # Start point (New York coordinates)
            lat = 40.7128 + random.uniform(-0.1, 0.1)
            lon = -74.0060 + random.uniform(-0.1, 0.1)
            
            # Create 20 location points over the last 24 hours
            for i in range(20):
                location = GPSLocation(
                    vehicle_id=vehicle_id,
                    latitude=lat + random.uniform(-0.01, 0.01),
                    longitude=lon + random.uniform(-0.01, 0.01),
                    speed=random.uniform(0, 80),
                    heading=random.uniform(0, 360),
                    accuracy=random.uniform(1, 10),
                    timestamp=datetime.utcnow() - timedelta(hours=random.uniform(0, 24))
                )
                db.add(location)
                total_locations += 1
            
            print(f"  Added 20 locations for {vehicle_id}")
        
        db.commit()
        print(f"\n✅ Added {total_locations} sample locations")
        
        # Show statistics
        vehicle_count = db.query(Vehicle).count()
        location_count = db.query(GPSLocation).count()
        print(f"\n📊 Database Statistics:")
        print(f"   Total vehicles: {vehicle_count}")
        print(f"   Total locations: {location_count}")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error creating sample data: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_sample_data()
