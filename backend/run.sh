#!/bin/bash

echo "🚀 Starting Smart Transport System Backend..."

# Activate virtual environment
if [ -d "venv" ]; then
    echo "📦 Activating virtual environment..."
    source venv/bin/activate
else
    echo "❌ Virtual environment not found. Please create it first."
    echo "   Run: python3 -m venv venv"
    exit 1
fi

# Install requirements
echo "📦 Checking/installing dependencies..."
pip install -r requirements.txt > /dev/null 2>&1

# Create sample data if needed
echo "📊 Creating sample data..."
python create_sample_data.py

# Start the server
echo "🚀 Starting FastAPI server..."
echo "📚 Documentation: http://localhost:8000/docs"
echo "🌐 API Base URL: http://localhost:8000"
echo "🔌 Press Ctrl+C to stop the server"
echo "="*50

uvicorn main:app --reload --host 0.0.0.0 --port 8000
