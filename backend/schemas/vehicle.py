from pydantic import BaseModel
from datetime import datetime
from typing import Optional

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
