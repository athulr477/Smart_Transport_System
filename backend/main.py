from fastapi import FastAPI

app = FastAPI()

# Health Check
@app.get("/")
def home():
    return {"message": "Smart Transport Backend is Online!", "status": "active"}

# Test Login API
@app.post("/driver-login")
def driver_login(driver_id: str, password: str):
    if driver_id == "D001" and password == "123":
        return {"success": True, "name": "Raju Bhai", "bus_id": "bus_001"}
    else:
        return {"success": False, "error": "Invalid Credentials"}