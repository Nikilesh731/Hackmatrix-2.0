# Development startup script for Ambient AI Scribe (PowerShell)

Write-Host "🚀 Starting Ambient AI Scribe Development Environment" -ForegroundColor Green

# Check if required tools are installed
function Check-Command {
    param ($Command)
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Write-Host "❌ $Command is not installed. Please install it first." -ForegroundColor Red
        exit 1
    }
}

Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow
Check-Command "node"
Check-Command "npm"
Check-Command "flutter"
Check-Command "docker"

# Start PostgreSQL if not running
$postgresRunning = docker ps --filter "name=postgres" --quiet
if (-not $postgresRunning) {
    Write-Host "🐘 Starting PostgreSQL..." -ForegroundColor Yellow
    docker-compose up -d postgres
    Start-Sleep -Seconds 5
}

# Setup backend
Write-Host "🔧 Setting up backend..." -ForegroundColor Yellow
Set-Location backend

if (-not (Test-Path "node_modules")) {
    npm install
}

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "⚠️  Please edit backend\.env with your database configuration" -ForegroundColor Yellow
}

# Generate Prisma client
npx prisma generate

# Push database schema
npx prisma db push

# Start backend in background
Write-Host "🚀 Starting backend..." -ForegroundColor Yellow
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    npm run start:dev
}

# Setup frontend
Write-Host "🔧 Setting up frontend..." -ForegroundColor Yellow
Set-Location ..\mobile_app

if (-not (Test-Path ".dart_tool")) {
    flutter pub get
}

# Start frontend
Write-Host "🚀 Starting frontend..." -ForegroundColor Yellow
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    flutter run
}

Write-Host "✅ Development environment started!" -ForegroundColor Green
Write-Host "📱 Mobile app: Flutter should open automatically" -ForegroundColor Cyan
Write-Host "🌐 Backend API: http://localhost:3000" -ForegroundColor Cyan
Write-Host "📚 API Docs: http://localhost:3000/api/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Yellow

# Wait for interrupt signal
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    Write-Host "🛑 Stopping services..." -ForegroundColor Yellow
    Stop-Job $backendJob -ErrorAction SilentlyContinue
    Stop-Job $frontendJob -ErrorAction SilentlyContinue
    Remove-Job $backendJob -ErrorAction SilentlyContinue
    Remove-Job $frontendJob -ErrorAction SilentlyContinue
    Set-Location ..
    docker-compose down
    Write-Host "✅ All services stopped" -ForegroundColor Green
}
