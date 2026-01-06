from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
from models import GPSLocation, Vehicle
from schemas.location import GPSData, GPSLocationResponse

router = APIRouter(prefix="/api", tags=["Locations"])
