# backend/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from urllib.parse import quote_plus

# Encode password safely
password = "FleetTracker!2024@secure"
encoded_password = quote_plus(password)

DATABASE_URL = f"postgresql://fleet_admin:{encoded_password}@localhost/fleet_tracker"

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()

def create_tables():
    # IMPORTANT: models must be imported HERE
    from models.vehicle import Vehicle
    from models.gps_location import GPSLocation
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables verified")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
