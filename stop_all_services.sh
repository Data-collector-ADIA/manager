#!/bin/bash

# Data Collector ADIA - Stop Script
# Stops all running services

echo "🛑 Stopping Data Collector ADIA Services..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Stop services by PID file
if [ -f logs/browser_service.pid ]; then
    PID=$(cat logs/browser_service.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        echo -e "${GREEN}✓ Browser Service stopped${NC}"
    fi
    rm logs/browser_service.pid
fi

if [ -f logs/database_service.pid ]; then
    PID=$(cat logs/database_service.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        echo -e "${GREEN}✓ Database Service stopped${NC}"
    fi
    rm logs/database_service.pid
fi

if [ -f logs/backend_service.pid ]; then
    PID=$(cat logs/backend_service.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        echo -e "${GREEN}✓ Backend Service stopped${NC}"
    fi
    rm logs/backend_service.pid
fi

if [ -f logs/frontend_service.pid ]; then
    PID=$(cat logs/frontend_service.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        echo -e "${GREEN}✓ Frontend Service stopped${NC}"
    fi
    rm logs/frontend_service.pid
fi

# Optional: Stop MongoDB
read -p "Stop MongoDB as well? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd data-base/docker
    docker-compose down
    cd ../..
    echo -e "${GREEN}✓ MongoDB stopped${NC}"
fi

echo -e "\n${GREEN}All services stopped!${NC}\n"

