#!/bin/bash

# Data Collector ADIA - Startup Script
# Starts all services in the distributed system

echo "🚀 Starting Data Collector ADIA Services..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if MongoDB is running
echo -e "${YELLOW}Checking MongoDB...${NC}"
if ! docker ps | grep -q mongodb; then
    echo -e "${YELLOW}Starting MongoDB...${NC}"
    cd data-base/docker
    docker-compose up -d
    sleep 3
    cd ../..
    echo -e "${GREEN}✓ MongoDB started${NC}"
else
    echo -e "${GREEN}✓ MongoDB already running${NC}"
fi

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0
    else
        return 1
    fi
}

# Start Browser Service
echo -e "\n${YELLOW}Starting Browser Service...${NC}"
if check_port 8001; then
    echo -e "${RED}✗ Port 8001 already in use${NC}"
else
    cd Browser-server
    python api_server.py > ../logs/browser_service.log 2>&1 &
    BROWSER_PID=$!
    echo $BROWSER_PID > ../logs/browser_service.pid
    cd ..
    sleep 2
    echo -e "${GREEN}✓ Browser Service started (PID: $BROWSER_PID)${NC}"
fi

# Start Database Service
echo -e "\n${YELLOW}Starting Database Service...${NC}"
if check_port 8002; then
    echo -e "${RED}✗ Port 8002 already in use${NC}"
else
    cd data-base
    python api_server.py > ../logs/database_service.log 2>&1 &
    DB_PID=$!
    echo $DB_PID > ../logs/database_service.pid
    cd ..
    sleep 2
    echo -e "${GREEN}✓ Database Service started (PID: $DB_PID)${NC}"
fi

# Start Backend Service
echo -e "\n${YELLOW}Starting Backend Service...${NC}"
if check_port 8000; then
    echo -e "${RED}✗ Port 8000 already in use${NC}"
else
    cd back-end
    python api_server.py > ../logs/backend_service.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > ../logs/backend_service.pid
    cd ..
    sleep 2
    echo -e "${GREEN}✓ Backend Service started (PID: $BACKEND_PID)${NC}"
fi

# Start Frontend Service
echo -e "\n${YELLOW}Starting Frontend Service...${NC}"
if check_port 8003; then
    echo -e "${RED}✗ Port 8003 already in use${NC}"
else
    cd Front-end
    python server.py > ../logs/frontend_service.log 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > ../logs/frontend_service.pid
    cd ..
    sleep 2
    echo -e "${GREEN}✓ Frontend Service started (PID: $FRONTEND_PID)${NC}"
fi

# Create logs directory if it doesn't exist
mkdir -p logs

echo -e "\n${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}All services started!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "\nService URLs:"
echo -e "  Frontend:  ${GREEN}http://localhost:8003${NC}"
echo -e "  Backend:   ${GREEN}http://localhost:8000${NC}"
echo -e "  Browser:   ${GREEN}http://localhost:8001${NC}"
echo -e "  Database:  ${GREEN}http://localhost:8002${NC}"
echo -e "\nLogs directory: ${YELLOW}./logs/${NC}"
echo -e "\nTo stop all services, run: ${YELLOW}./stop_all_services.sh${NC}"
echo -e "\n"

