from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import Vehicle

router = APIRouter(
    prefix="/api/vehicles",
    tags=["Vehicles"]
)

# ✅ GET all vehicles
@router.get("")
def get_vehicles(db: Session = Depends(get_db)):
    return db.query(Vehicle).all()

# ✅ CREATE vehicle
@router.post("", status_code=status.HTTP_201_CREATED)
def create_vehicle(vehicle: dict, db: Session = Depends(get_db)):
    vehicle_id = vehicle.get("vehicle_id")

    if not vehicle_id:
        raise HTTPException(status_code=400, detail="vehicle_id is required")

    existing = db.query(Vehicle).filter(
        Vehicle.vehicle_id == vehicle_id
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="Vehicle already exists")

    new_vehicle = Vehicle(
        vehicle_id=vehicle_id,
        vehicle_type=vehicle.get("vehicle_type", "bus"),
        status=vehicle.get("status", "active"),
    )

    db.add(new_vehicle)
    db.commit()
    db.refresh(new_vehicle)

    return new_vehicle

# ✅ DELETE vehicle by vehicle_id (NOT DB id)
@router.delete("/{vehicle_id}", status_code=status.HTTP_200_OK)
def delete_vehicle(vehicle_id: str, db: Session = Depends(get_db)):
    vehicle = db.query(Vehicle).filter(
        Vehicle.vehicle_id == vehicle_id
    ).first()

    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")

    db.delete(vehicle)
    db.commit()

    return {"message": "Vehicle deleted successfully"}
