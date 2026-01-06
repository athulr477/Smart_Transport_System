from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from database import get_db
from models import Vehicle, GPSLocation

router = APIRouter(prefix="/api", tags=["Statistics"])

@router.get("/stats")
def get_system_stats(db: Session = Depends(get_db)):
    try:
        total_vehicles = db.query(Vehicle).count()
        total_locations = db.query(GPSLocation).count()

        active_vehicles = db.query(Vehicle)\
            .filter(Vehicle.status == "active")\
            .count()

        inactive_vehicles = db.query(Vehicle)\
            .filter(Vehicle.status == "inactive")\
            .count()

        today_start = datetime.utcnow().replace(
            hour=0, minute=0, second=0, microsecond=0
        )

        today_locations = db.query(GPSLocation)\
            .filter(GPSLocation.timestamp >= today_start)\
            .count()

        last_location = db.query(GPSLocation)\
            .order_by(GPSLocation.timestamp.desc())\
            .first()

        return {
            "total_vehicles": total_vehicles,
            "total_locations": total_locations,
            "active_vehicles": active_vehicles,
            "inactive_vehicles": inactive_vehicles,
            "today_locations": today_locations,
            "last_update": last_location.timestamp.isoformat() if last_location else None,
            "server_time": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
