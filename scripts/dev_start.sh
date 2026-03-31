#!/bin/bash

# Development startup script for Ambient AI Scribe

echo "🚀 Starting Ambient AI Scribe Development Environment"

# Check if required tools are installed
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        exit 1
    fi
}

echo "📋 Checking prerequisites..."
check_command "node"
check_command "npm"
check_command "flutter"
check_command "docker"

# Start PostgreSQL if not running
if ! docker ps | grep -q postgres; then
    echo "🐘 Starting PostgreSQL..."
    docker-compose up -d postgres
    sleep 5
fi

# Setup backend
echo "🔧 Setting up backend..."
cd backend
if [ ! -d "node_modules" ]; then
    npm install
fi

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your database configuration"
fi

# Generate Prisma client
npx prisma generate

# Push database schema
npx prisma db push

# Start backend in background
echo "🚀 Starting backend..."
npm run start:dev &
BACKEND_PID=$!

# Setup frontend
echo "🔧 Setting up frontend..."
cd ../mobile_app
if [ ! -d ".dart_tool" ]; then
    flutter pub get
fi

# Start frontend
echo "🚀 Starting frontend..."
flutter run &
FRONTEND_PID=$!

echo "✅ Development environment started!"
echo "📱 Mobile app: Flutter should open automatically"
echo "🌐 Backend API: http://localhost:3000"
echo "📚 API Docs: http://localhost:3000/api/docs"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for interrupt signal
trap "echo '🛑 Stopping services...'; kill $BACKEND_PID $FRONTEND_PID; docker-compose down; exit" INT
wait
