@echo off
REM Data Collector ADIA - Startup Script for Windows
REM Starts all services in the distributed system

echo Starting Data Collector ADIA Services...

REM Create logs directory
if not exist logs mkdir logs

REM Check if MongoDB is running
echo Checking MongoDB...
docker ps | findstr mongodb >nul
if %errorlevel% neq 0 (
    echo Starting MongoDB...
    cd data-base\docker
    docker-compose up -d
    timeout /t 3 /nobreak >nul
    cd ..\..
    echo MongoDB started
) else (
    echo MongoDB already running
)

REM Start Browser Service
echo.
echo Starting Browser Service...
start "Browser Service" /D "Browser-server" cmd /c "python api_server.py > ..\logs\browser_service.log 2>&1"
timeout /t 2 /nobreak >nul
echo Browser Service started

REM Start Database Service
echo.
echo Starting Database Service...
start "Database Service" /D "data-base" cmd /c "python api_server.py > ..\logs\database_service.log 2>&1"
timeout /t 2 /nobreak >nul
echo Database Service started

REM Start Backend Service
echo.
echo Starting Backend Service...
start "Backend Service" /D "back-end" cmd /c "python api_server.py > ..\logs\backend_service.log 2>&1"
timeout /t 2 /nobreak >nul
echo Backend Service started

REM Start Frontend Service
echo.
echo Starting Frontend Service...
start "Frontend Service" /D "Front-end" cmd /c "python server.py > ..\logs\frontend_service.log 2>&1"
timeout /t 2 /nobreak >nul
echo Frontend Service started

echo.
echo ================================================
echo All services started!
echo ================================================
echo.
echo Service URLs:
echo   Frontend:  http://localhost:8003
echo   Backend:   http://localhost:8000
echo   Browser:   http://localhost:8001
echo   Database:  http://localhost:8002
echo.
echo Logs directory: .\logs\
echo.
echo To stop services, close the service windows or run stop_all_services.bat
echo.

pause

