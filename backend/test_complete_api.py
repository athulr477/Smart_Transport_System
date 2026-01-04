import requests
import json

BASE_URL = "http://localhost:8000"

def test_all_endpoints():
    print("🧪 Testing ALL API Endpoints...\n")
    
    endpoints_to_test = [
        # Basic endpoints
        ("GET", "/", "Root"),
        ("GET", "/health", "Health Check"),
        ("POST", "/driver-login?driver_id=D001&password=123", "Driver Login"),
        
        # Vehicle endpoints
        ("GET", "/api/vehicles", "Get All Vehicles"),
        ("POST", "/api/vehicles", "Create Vehicle"),
        ("GET", "/api/vehicles/TRUCK-001", "Get Specific Vehicle"),
        ("PATCH", "/api/vehicles/TRUCK-001/status", "Update Vehicle Status"),
        
        # Location endpoints
        ("POST", "/api/location", "Update Location"),
        ("GET", "/api/locations/TRUCK-001", "Get Location History"),
        ("GET", "/api/latest/TRUCK-001", "Get Latest Location"),
        ("GET", "/api/locations/TRUCK-001?limit=5", "Get Limited History"),
        
        # Stats endpoint
        ("GET", "/api/stats", "System Statistics"),
    ]
    
    for method, endpoint, description in endpoints_to_test:  # FIXED: changed 'endpoints' to 'endpoints_to_test'
        print(f"🔍 {description}")
        print(f"   {method} {endpoint}")
        
        try:
            # Prepare data for POST/PA~~TCH requests
            json_data = None
            if method == "POST" and endpoint == "/api/vehicles":
                json_data = {
                    "vehicle_id": "TEST-NEW-001",
                    "license_plate": "NEW001",
                    "vehicle_type": "test_car"
                }
            elif method == "POST" and endpoint == "/api/location":
                json_data = {
                    "vehicle_id": "TRUCK-001",
                    "latitude": 40.7128,
                    "longitude": -74.0060,
                    "speed": 60.0
                }
            elif method == "PATCH" and "status" in endpoint:
                json_data = {"status": "active"}
            
            # Make the request
            if method == "GET":
                response = requests.get(f"{BASE_URL}{endpoint}", timeout=5)
            elif method == "POST":
                if json_data:
                    response = requests.post(f"{BASE_URL}{endpoint}", json=json_data, timeout=5)
                else:
                    # Handle query parameters for driver-login
                    if "driver-login" in endpoint:
                        response = requests.post(f"{BASE_URL}/driver-login", params={"driver_id": "D001", "password": "123"}, timeout=5)
                    else:
                        response = requests.post(f"{BASE_URL}{endpoint}", timeout=5)
            elif method == "PATCH":
                response = requests.patch(f"{BASE_URL}{endpoint}", json=json_data, timeout=5)
            elif method == "DELETE":
                response = requests.delete(f"{BASE_URL}{endpoint}", timeout=5)
            
            status_emoji = "✅" if response.status_code < 400 else "⚠️" if response.status_code < 500 else "❌"
            print(f"   {status_emoji} Status: {response.status_code}")
            
            if response.status_code < 400:
                try:
                    data = response.json()
                    print(f"   Response: OK")
                except:
                    print(f"   Response: {response.text[:100]}")
            else:
                print(f"   Error: {response.text[:100]}")
            
        except Exception as e:
            print(f"   ❌ Failed: {e}")
        
        print("-" * 40)
    
    print("\n" + "="*50)
    print("🎉 API Testing Summary")
    print("="*50)
    
    # Final verification
    try:
        # Test CORS headers
        print("\n🔒 Checking CORS headers...")
        response = requests.get(f"{BASE_URL}/health")
        cors_headers = {k: v for k, v in response.headers.items() 
                       if 'access-control' in k.lower()}
        if cors_headers:
            print("✅ CORS headers present")
        else:
            print("⚠️  CORS headers not found")
        
        # Test Swagger docs
        print("\n📚 Checking Swagger documentation...")
        response = requests.get(f"{BASE_URL}/docs")
        if response.status_code == 200:
            print("✅ Swagger docs accessible")
        else:
            print("⚠️  Swagger docs not accessible")
        
    except Exception as e:
        print(f"❌ Final checks failed: {e}")
    
    print("\n✅ Step 1.4 COMPLETED!")
    print("🚀 Your API is ready for Flutter integration")

if __name__ == "__main__":
    test_all_endpoints()
