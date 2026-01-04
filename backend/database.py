# backend/database.py (UPDATED VERSION)
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
import os
from urllib.parse import quote_plus

# Your password contains special characters that need URL encoding
password = "FleetTracker!2024@secure"
encoded_password = quote_plus(password)  # This encodes @ to %40

# Database URL with encoded password
DATABASE_URL = f"postgresql://fleet_admin:{encoded_password}@localhost/fleet_tracker"

# Alternative: Use environment variable (RECOMMENDED for security)
# DATABASE_URL = os.getenv("DATABASE_URL")

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_recycle=300)

# Create SessionLocal class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create Base class
Base = declarative_base()

# Define Vehicle model
class Vehicle(Base):
    __tablename__ = "vehicles"
    
    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(String(50), unique=True, index=True, nullable=False)
    license_plate = Column(String(20))
    vehicle_type = Column(String(50))
    status = Column(String(20), default="active")
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship with GPS locations
    locations = relationship("GPSLocation", back_populates="vehicle", cascade="all, delete-orphan")

# Define GPSLocation model
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
    
    # Relationship with Vehicle
    vehicle = relationship("Vehicle", back_populates="locations")

# Create all tables in the database
def create_tables():
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created/verified successfully!")

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()