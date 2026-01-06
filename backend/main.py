from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import vehicles, locations
from database import create_tables
from routes import stats


app = FastAPI(title="Smart Transport System API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup():
    create_tables()

app.include_router(vehicles.router)
app.include_router(locations.router)
app.include_router(stats.router)


@app.get("/")
def home():
    return {"message": "Smart Transport Backend is Online!", "status": "active"}
