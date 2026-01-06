#test_api.py
import requests
import json
import time
import sys

BASE_URL = "http://localhost:8000"

def test_api():
    print("🧪 Testing Smart Transport System API...")
    
    # Test 1: Health Check
    print("\n1. Testing health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
        return False
    
    # Test 2: Create a vehicle
    print("\n2. Creating a test vehicle...")
    vehicle_data = {
        "vehicle_id": "TRUCK-001",
        "license_plate": "ABC123",
        "vehicle_type": "delivery_truck",
        "status": "active"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/vehicles", json=vehicle_data, timeout=5)
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    # Test 3: Get all vehicles
    print("\n3. Getting all vehicles...")
    try:
        response = requests.get(f"{BASE_URL}/api/vehicles", timeout=5)
        vehicles = response.json()
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Found {len(vehicles)} vehicles")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    # Test 4: Update location
    print("\n4. Updating vehicle location...")
    location_data = {
        "vehicle_id": "TRUCK-001",
        "latitude": 40.7128,
        "longitude": -74.0060,
        "speed": 45.5,
        "heading": 90.0,
        "accuracy": 5.0
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/location", json=location_data, timeout=5)
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    # Wait a moment
    time.sleep(1)
    
    # Test 5: Add another location
    print("\n5. Adding another location update...")
    location_data2 = {
        "vehicle_id": "TRUCK-001",
        "latitude": 40.7138,
        "longitude": -74.0070,
        "speed": 50.0,
        "heading": 95.0
    }
    
    try:
        response = requests.post(f"{BASE_URL}/api/location", json=location_data2, timeout=5)
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Response: {response.json()}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    # Test 6: Get location history
    print("\n6. Getting location history...")
    try:
        response = requests.get(f"{BASE_URL}/api/locations/TRUCK-001?limit=5", timeout=5)
        locations = response.json()
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Found {len(locations)} locations")
        if locations:
            print(f"   Latest location: Lat={locations[0]['latitude']}, Lon={locations[0]['longitude']}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    # Test 7: Get latest location
    print("\n7. Getting latest location...")
    try:
        response = requests.get(f"{BASE_URL}/api/latest/TRUCK-001", timeout=5)
        print(f"   ✅ Status: {response.status_code}")
        location = response.json()
        print(f"   Latest: Lat={location['latitude']}, Lon={location['longitude']}, Speed={location['speed']}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    # Test 8: Get system stats
    print("\n8. Getting system statistics...")
    try:
        response = requests.get(f"{BASE_URL}/api/stats", timeout=5)
        print(f"   ✅ Status: {response.status_code}")
        print(f"   Stats: {response.json()}")
    except Exception as e:
        print(f"   ❌ Failed: {e}")
    
    print("\n" + "="*50)
    print("✅ API Testing Complete!")
    print("📚 Open http://localhost:8000/docs for interactive API documentation")
    return True

if __name__ == "__main__":
    success = test_api()
    sys.exit(0 if success else 1)
