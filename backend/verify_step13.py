# backend/verify_step13.py
import requests
import json

BASE_URL = "http://localhost:8000"

def test_endpoints():
    print("🔍 Testing Step 1.3 Completion...\n")
    
    try:
        # 1. Test root endpoint
        print("1. Testing root endpoint...")
        response = requests.get(f"{BASE_URL}/")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}\n")
        
        # 2. Test health endpoint
        print("2. Testing health endpoint...")
        response = requests.get(f"{BASE_URL}/health")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}\n")
        
        # 3. Test creating a vehicle
        print("3. Testing vehicle creation...")
        vehicle_data = {
            "vehicle_id": "VERIFY-001",
            "license_plate": "VERIFY-123",
            "vehicle_type": "verification_vehicle"
        }
        response = requests.post(f"{BASE_URL}/api/vehicles", json=vehicle_data)
        print(f"   Status: {response.status_code}")
        if response.status_code == 201:
            print(f"   Response: {response.json()}\n")
        else:
            print(f"   Response: {response.text}\n")
        
        # 4. Test updating location
        print("4. Testing location update...")
        location_data = {
            "vehicle_id": "VERIFY-001",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "speed": 45.5
        }
        response = requests.post(f"{BASE_URL}/api/location", json=location_data)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}\n")
        
        # 5. Test getting locations
        print("5. Testing location retrieval...")
        response = requests.get(f"{BASE_URL}/api/locations/VERIFY-001")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            locations = response.json()
            print(f"   Found {len(locations)} location(s)")
            if locations:
                print(f"   Latest location: Lat={locations[0]['latitude']}, Lon={locations[0]['longitude']}\n")
        
        # 6. Test getting all vehicles
        print("6. Testing get all vehicles...")
        response = requests.get(f"{BASE_URL}/api/vehicles")
        print(f"   Status: {response.status_code}")
        vehicles = response.json()
        print(f"   Found {len(vehicles)} vehicle(s)\n")
        
        print("✅ All tests completed!")
        
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Make sure FastAPI is running on port 8000.")
        print("   Run: uvicorn main:app --reload --host 0.0.0.0 --port 8000")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_endpoints()

    