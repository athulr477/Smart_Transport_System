from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class GPSData(BaseModel):
    vehicle_id: str
    latitude: float
    longitude: float
    speed: Optional[float] = None
    heading: Optional[float] = None
    accuracy: Optional[float] = None

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
