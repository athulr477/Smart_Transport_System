🚌 Smart Transport System


A real-time Bus Tracking & Management System designed to modernize public transportation. This full-stack solution connects Drivers, Admins, and Passengers through a unified mobile application and a central server.

🚀 Project Overview


The Smart Transport System replaces manual logbooks with a digital architecture. It allows:

Drivers to broadcast their real-time location.

Admins to manage the fleet and view live bus positions on a map.

Passengers to track buses and see Estimated Time of Arrival (ETA).

🛠️ Tech Stack


Frontend (Mobile App)
Framework: Flutter (Dart)

Architecture: Role-based navigation (Single codebase for all 3 roles)

State Management: Native Flutter State

Networking: HTTP requests to REST API

Backend (Server)
Language: Python

Framework: FastAPI (High-performance web framework)

Server: Uvicorn (ASGI)

Data Validation: Pydantic Models

📱 Key Features
1. Multi-Role Authentication
The app dynamically changes interfaces based on the user type:

Driver: Access to Trip Controls (Start/Stop) and GPS broadcasting.

Admin: Access to Fleet Dashboard and Driver Management.

Passenger: Access to Bus Search and Live Map Tracking.

2. Smart Networking Layer
The application automatically detects the environment to establish the correct server connection:

Android Emulator: Connects via 10.0.2.2 (Loopback).

Web/Physical Device: Connects via 127.0.0.1 or Local IP.

3. Real-Time Communication
Location Updates: The Driver app sends GPS coordinates (Latitude/Longitude) to the server via POST requests.

Status Checks: The Admin dashboard polls the server to update bus markers on the map.

📂 Project Structure
Plaintext

Smart_Transport_System/
├── backend/                  # Python FastAPI Server
│   ├── main.py               # API Endpoints & Logic
│   └── requirements.txt      # Python dependencies
│
└── frontend/                 # Flutter Mobile Application
    └── Smart_Transport_System/
        ├── lib/
        │   ├── main.dart     # App Entry Point
        │   ├── screens/      # Login, Dashboard, & Map Screens
        │   └── services/     # API & Networking Logic
        └── pubspec.yaml      # Flutter dependencies
⚙️ How to Run
1. Start the Backend (Python)
Navigate to the backend folder and run the server:

Bash

cd backend
# Install dependencies
pip install -r requirements.txt
# Start the server
uvicorn main:app --reload
Server will run on: http://127.0.0.1:8000

2. Start the Frontend (Flutter)
Navigate to the frontend folder and launch the app:

Bash

cd frontend/Smart_Transport_System
# Install packages
flutter pub get
# Run the app
flutter run
🔮 Future Roadmap

[ ] Google Maps Integration: Visualizing live bus movement on the Admin map.

[ ] Database Integration: Connecting to Supabase/Firebase for persistent user and trip data.

[ ] Passenger ETA: Algorithms to calculate arrival times based on traffic.
