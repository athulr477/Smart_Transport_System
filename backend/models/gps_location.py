from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base


class GPSLocation(Base):
    __tablename__ = "gps_locations"

    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(String(50), ForeignKey("vehicles.vehicle_id"), index=True, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    speed = Column(Float)
    heading = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    accuracy = Column(Float)

    vehicle = relationship("Vehicle", back_populates="locations")
