from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text, func
from database import get_db, GPSLocation, Vehicle, create_tables
from pydantic import BaseModel
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any

app = FastAPI(title="Smart Transport System API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for request/response validation
class GPSData(BaseModel):
    vehicle_id: str
    latitude: float
    longitude: float
    speed: Optional[float] = None
    heading: Optional[float] = None
    accuracy: Optional[float] = None

class VehicleCreate(BaseModel):
    vehicle_id: str
    license_plate: Optional[str] = None
    vehicle_type: Optional[str] = None
    status: Optional[str] = "active"

class VehicleResponse(BaseModel):
    id: int
    vehicle_id: str
    license_plate: Optional[str]
    vehicle_type: Optional[str]
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class GPSLocationResponse(BaseModel):
    id: int
    vehicle_id: str
    latitude: float
    longitude: float
    speed: Optional[float]
    heading: Optional[float]
    timestamp: datetime
    accuracy: Optional[float]
    
    class Config:
        from_attributes = True

# For status update endpoint
class StatusUpdate(BaseModel):
    status: str

# Health Check - Keep your original endpoint
@app.get("/")
def home():
    return {"message": "Smart Transport Backend is Online!", "status": "active"}

# Test Login API - Keep your original endpoint
@app.post("/driver-login")
def driver_login(driver_id: str, password: str):
    if driver_id == "D001" and password == "123":
        return {"success": True, "name": "Raju Bhai", "bus_id": "bus_001"}
    else:
        return {"success": False, "error": "Invalid Credentials"}

# Startup event to create tables
@app.on_event("startup")
def on_startup():
    create_tables()
    print("🚀 Smart Transport System API started successfully!")

# Additional health check endpoint (more detailed) - FIXED VERSION
@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        # Simple database query to check connection
        # FIX: Use text() for raw SQL in SQLAlchemy 2.0
        db.execute(text("SELECT 1"))
        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database connection failed: {str(e)}"
        )

# Update vehicle location endpoint
@app.post("/api/location", status_code=status.HTTP_201_CREATED)
async def update_location(data: GPSData, db: Session = Depends(get_db)):
    """
    Update vehicle location
    """
    try:
        # Check if vehicle exists
        vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == data.vehicle_id).first()
        if not vehicle:
            # You can also create the vehicle automatically if it doesn't exist
            # Uncomment the following lines if you want auto-creation:
            """
            vehicle = Vehicle(
                vehicle_id=data.vehicle_id,
                vehicle_type="bus",  # default type
                status="active"
            )
            db.add(vehicle)
            db.commit()
            """
            # Or keep the current behavior (return error):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Vehicle {data.vehicle_id} not found"
            )
        
        # Store location in database
        location = GPSLocation(
            vehicle_id=data.vehicle_id,
            latitude=data.latitude,
            longitude=data.longitude,
            speed=data.speed,
            heading=data.heading,
            accuracy=data.accuracy
        )
        db.add(location)
        db.commit()
        db.refresh(location)
        
        return {
            "status": "success",
            "message": "Location updated",
            "location_id": location.id,
            "timestamp": location.timestamp.isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update location: {str(e)}"
        )

# Get all vehicles endpoint
@app.get("/api/vehicles", response_model=List[VehicleResponse])
async def get_vehicles(db: Session = Depends(get_db)):
    """
    Get all vehicles
    """
    vehicles = db.query(Vehicle).all()
    return vehicles

# Create new vehicle endpoint
@app.post("/api/vehicles", status_code=status.HTTP_201_CREATED, response_model=VehicleResponse)
async def create_vehicle(vehicle_data: VehicleCreate, db: Session = Depends(get_db)):
    """
    Create a new vehicle
    """
    try:
        # Check if vehicle already exists
        existing = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_data.vehicle_id).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Vehicle {vehicle_data.vehicle_id} already exists"
            )
        
        vehicle = Vehicle(**vehicle_data.dict())
        db.add(vehicle)
        db.commit()
        db.refresh(vehicle)
        
        return vehicle
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create vehicle: {str(e)}"
        )

# Get location history for a specific vehicle
@app.get("/api/locations/{vehicle_id}", response_model=List[GPSLocationResponse])
async def get_vehicle_locations(
    vehicle_id: str, 
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Get location history for a specific vehicle
    """
    # Check if vehicle exists
    vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_id).first()
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Vehicle {vehicle_id} not found"
        )
    
    locations = db.query(GPSLocation)\
        .filter(GPSLocation.vehicle_id == vehicle_id)\
        .order_by(GPSLocation.timestamp.desc())\
        .limit(limit)\
        .all()
    
    return locations

# Get latest location for a specific vehicle - Old endpoint kept for backward compatibility
@app.get("/api/locations/{vehicle_id}/latest", response_model=GPSLocationResponse)
async def get_latest_location_old(vehicle_id: str, db: Session = Depends(get_db)):
    """
    Get the latest location for a specific vehicle
    """
    # Check if vehicle exists
    vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_id).first()
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Vehicle {vehicle_id} not found"
        )
    
    location = db.query(GPSLocation)\
        .filter(GPSLocation.vehicle_id == vehicle_id)\
        .order_by(GPSLocation.timestamp.desc())\
        .first()
    
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No location data found for vehicle {vehicle_id}"
        )
    
    return location

# ==================== STATISTICS ENDPOINT ====================
@app.get("/api/stats", tags=["Statistics"])
async def get_system_stats(db: Session = Depends(get_db)):
    """Get system statistics"""
    try:
        total_vehicles = db.query(Vehicle).count()
        total_locations = db.query(GPSLocation).count()
        
        # Get most recent location timestamp
        recent_location = db.query(GPSLocation)\
            .order_by(GPSLocation.timestamp.desc())\
            .first()
        
        # Get vehicles by status
        active_vehicles = db.query(Vehicle).filter(Vehicle.status == "active").count()
        inactive_vehicles = db.query(Vehicle).filter(Vehicle.status == "inactive").count()
        
        # Get today's location count
        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
        today_locations = db.query(GPSLocation)\
            .filter(GPSLocation.timestamp >= today_start)\
            .count()
        
        return {
            "total_vehicles": total_vehicles,
            "total_locations": total_locations,
            "active_vehicles": active_vehicles,
            "inactive_vehicles": inactive_vehicles,
            "today_locations": today_locations,
            "last_update": recent_location.timestamp.isoformat() if recent_location else None,
            "server_time": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get statistics: {str(e)}"
        )

# ==================== LATEST LOCATION ENDPOINT (Alternative) ====================
@app.get("/api/latest/{vehicle_id}", 
         response_model=GPSLocationResponse,
         tags=["Locations"],
         summary="Get latest vehicle location",
         description="Get the most recent GPS location for a vehicle")
async def get_latest_location(vehicle_id: str, db: Session = Depends(get_db)):
    """Get the latest location for a vehicle"""
    # Check if vehicle exists
    vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_id).first()
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Vehicle {vehicle_id} not found"
        )
    
    location = db.query(GPSLocation)\
        .filter(GPSLocation.vehicle_id == vehicle_id)\
        .order_by(GPSLocation.timestamp.desc())\
        .first()
    
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No location data found for vehicle {vehicle_id}"
        )
    
    return location

# ==================== VEHICLE STATUS UPDATE ENDPOINT ====================
@app.patch("/api/vehicles/{vehicle_id}/status", 
          response_model=VehicleResponse,
          tags=["Vehicles"],
          summary="Update vehicle status",
          description="Update the status of a vehicle (active/inactive)")
async def update_vehicle_status(
    vehicle_id: str, 
    status_update: StatusUpdate,
    db: Session = Depends(get_db)
):
    """Update vehicle status"""
    try:
        vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_id).first()
        if not vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Vehicle {vehicle_id} not found"
            )
        
        # Validate status
        new_status = status_update.status
        if new_status not in ["active", "inactive", "maintenance", "offline"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Status must be one of: active, inactive, maintenance, offline"
            )
        
        vehicle.status = new_status
        db.commit()
        db.refresh(vehicle)
        
        return vehicle
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update vehicle status: {str(e)}"
        )

# ==================== DELETE LOCATION ENDPOINT ====================
@app.delete("/api/locations/{location_id}", 
           tags=["Locations"],
           summary="Delete a location record",
           description="Delete a specific GPS location record")
async def delete_location(location_id: int, db: Session = Depends(get_db)):
    """Delete a location record"""
    try:
        location = db.query(GPSLocation).filter(GPSLocation.id == location_id).first()
        if not location:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Location with ID {location_id} not found"
            )
        
        db.delete(location)
        db.commit()
        
        return {
            "status": "success",
            "message": f"Location {location_id} deleted successfully",
            "vehicle_id": location.vehicle_id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete location: {str(e)}"
        )

# ==================== BULK LOCATIONS ENDPOINT ====================
@app.post("/api/locations/bulk", status_code=status.HTTP_201_CREATED)
async def bulk_update_locations(
    locations_data: List[GPSData],
    db: Session = Depends(get_db)
):
    """Bulk update multiple vehicle locations"""
    try:
        created_locations = []
        failed_updates = []
        
        for data in locations_data:
            try:
                # Check if vehicle exists
                vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == data.vehicle_id).first()
                if not vehicle:
                    failed_updates.append({
                        "vehicle_id": data.vehicle_id,
                        "error": "Vehicle not found"
                    })
                    continue
                
                # Store location in database
                location = GPSLocation(
                    vehicle_id=data.vehicle_id,
                    latitude=data.latitude,
                    longitude=data.longitude,
                    speed=data.speed,
                    heading=data.heading,
                    accuracy=data.accuracy
                )
                db.add(location)
                created_locations.append(location.id)
                
            except Exception as e:
                failed_updates.append({
                    "vehicle_id": data.vehicle_id,
                    "error": str(e)
                })
        
        db.commit()
        
        return {
            "status": "success",
            "message": f"Bulk update completed: {len(created_locations)} locations added",
            "created_locations": created_locations,
            "failed_updates": failed_updates if failed_updates else None
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to bulk update locations: {str(e)}"
        )

# ==================== DELETE VEHICLE ENDPOINT ====================
@app.delete("/api/vehicles/{vehicle_id}", 
           tags=["Vehicles"],
           summary="Delete a vehicle",
           description="Delete a vehicle and all its associated locations")
async def delete_vehicle(vehicle_id: str, db: Session = Depends(get_db)):
    """Delete a vehicle and its locations"""
    try:
        vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_id).first()
        if not vehicle:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Vehicle {vehicle_id} not found"
            )
        
        # Delete associated locations first
        location_count = db.query(GPSLocation)\
            .filter(GPSLocation.vehicle_id == vehicle_id)\
            .delete()
        
        # Delete the vehicle
        db.delete(vehicle)
        db.commit()
        
        return {
            "status": "success",
            "message": f"Vehicle {vehicle_id} deleted successfully",
            "deleted_locations": location_count
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete vehicle: {str(e)}"
        )