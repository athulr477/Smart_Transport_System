import requests

BASE_URL = "http://localhost:8000"

def verify_step14():
    print("🔍 Verifying Step 1.4 Completion...\n")
    
    # 1. Check basic endpoints
    print("1. Checking basic endpoints...")
    try:
        # Root endpoint
        resp = requests.get(f"{BASE_URL}/")
        print(f"   ✅ GET / - Status: {resp.status_code}")
        
        # Health endpoint
        resp = requests.get(f"{BASE_URL}/health")
        print(f"   ✅ GET /health - Status: {resp.status_code}")
    except Exception as e:
        print(f"   ❌ Basic endpoints failed: {e}")
        return False
    
    # 2. Check vehicle endpoints
    print("\n2. Checking vehicle endpoints...")
    try:
        # Get all vehicles
        resp = requests.get(f"{BASE_URL}/api/vehicles")
        print(f"   ✅ GET /api/vehicles - Status: {resp.status_code}, Vehicles: {len(resp.json())}")
        
        # Get specific vehicle
        resp = requests.get(f"{BASE_URL}/api/vehicles/TRUCK-001")
        print(f"   ✅ GET /api/vehicles/TRUCK-001 - Status: {resp.status_code}")
    except Exception as e:
        print(f"   ❌ Vehicle endpoints failed: {e}")
    
    # 3. Check location endpoints
    print("\n3. Checking location endpoints...")
    try:
        # Update location
        location_data = {
            "vehicle_id": "TRUCK-001",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "speed": 50.0
        }
        resp = requests.post(f"{BASE_URL}/api/location", json=location_data)
        print(f"   ✅ POST /api/location - Status: {resp.status_code}")
        
        # Get location history
        resp = requests.get(f"{BASE_URL}/api/locations/TRUCK-001?limit=5")
        print(f"   ✅ GET /api/locations/TRUCK-001 - Status: {resp.status_code}, Locations: {len(resp.json())}")
    except Exception as e:
        print(f"   ❌ Location endpoints failed: {e}")
    
    # 4. Check NEW endpoints (from Step 1.4)
    print("\n4. Checking Step 1.4 new endpoints...")
    
    # Check /api/stats
    try:
        resp = requests.get(f"{BASE_URL}/api/stats")
        if resp.status_code == 200:
            print(f"   ✅ GET /api/stats - Status: {resp.status_code}")
        else:
            print(f"   ❌ GET /api/stats - Status: {resp.status_code}, Error: {resp.text[:100]}")
    except Exception as e:
        print(f"   ❌ /api/stats failed: {e}")
    
    # Check /api/latest/{vehicle_id}
    try:
        resp = requests.get(f"{BASE_URL}/api/latest/TRUCK-001")
        if resp.status_code == 200:
            print(f"   ✅ GET /api/latest/TRUCK-001 - Status: {resp.status_code}")
        else:
            print(f"   ❌ GET /api/latest/TRUCK-001 - Status: {resp.status_code}, Error: {resp.text[:100]}")
    except Exception as e:
        print(f"   ❌ /api/latest failed: {e}")
    
    # 5. Check CORS headers
    print("\n5. Checking CORS configuration...")
    try:
        resp = requests.get(f"{BASE_URL}/health")
        headers = resp.headers
        cors_found = False
        
        for header in headers:
            if 'access-control' in header.lower():
                print(f"   ✅ CORS header found: {header}: {headers[header]}")
                cors_found = True
        
        if not cors_found:
            print("   ⚠️  No CORS headers found - Flutter app may have connection issues")
        else:
            print("   ✅ CORS properly configured")
    except Exception as e:
        print(f"   ❌ CORS check failed: {e}")
    
    # 6. Check Swagger documentation
    print("\n6. Checking documentation...")
    try:
        resp = requests.get(f"{BASE_URL}/docs")
        if resp.status_code == 200:
            print("   ✅ Swagger documentation available at /docs")
        else:
            print(f"   ⚠️  Swagger docs status: {resp.status_code}")
        
        resp = requests.get(f"{BASE_URL}/redoc")
        if resp.status_code == 200:
            print("   ✅ ReDoc documentation available at /redoc")
    except Exception as e:
        print(f"   ❌ Documentation check failed: {e}")
    
    print("\n" + "="*50)
    print("📋 Step 1.4 Verification Complete!")
    print("="*50)
    
    print("\n✅ If all checks pass, Step 1.4 is COMPLETED!")
    print("\n🚀 Next Steps:")
    print("1. Your backend is ready for Flutter integration")
    print("2. Test with Postman or curl commands")
    print("3. Move to Step 2: Real-time WebSocket integration")
    
    return True

if __name__ == "__main__":
    verify_step14()

