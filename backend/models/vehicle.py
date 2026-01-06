from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base


class Vehicle(Base):
    __tablename__ = "vehicles"

    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(String(50), unique=True, index=True, nullable=False)
    license_plate = Column(String(20))
    vehicle_type = Column(String(50))
    status = Column(String(20), default="active")
    created_at = Column(DateTime, default=datetime.utcnow)

    locations = relationship(
        "GPSLocation",
        back_populates="vehicle",
        cascade="all, delete-orphan"
    )
