# Quick Start Guide

Get the Data Collector ADIA distributed system up and running in minutes!

## Prerequisites

- Python 3.11+
- Docker and Docker Compose
- Playwright browsers installed
- Google API Key for Gemini LLM

## One-Time Setup

### 1. Install Playwright Browsers

```bash
playwright install
```

Or if using Python's playwright:
```bash
python -m playwright install
```

### 2. Set Up Environment Variables

Create a `.env` file in the `back-end/` directory:

```bash
cd back-end
echo "GOOGLE_API_KEY=your_google_api_key_here" > .env
cd ..
```

Get your Google API key from: https://aistudio.google.com/apikey

### 3. Install Python Dependencies

Install dependencies for each service:

```bash
# Browser Service
cd Browser-server
pip install -r requirements.txt
cd ..

# Database Service
cd data-base
pip install -r requirements.txt
cd ..

# Backend Service
cd back-end
pip install -r requirements.txt
cd ..

# Frontend Service (optional, can use any web server)
cd Front-end
pip install -r requirements.txt 2>/dev/null || echo "No requirements for frontend"
cd ..
```

## Starting Services

### Option 1: Automated Script (Recommended)

**Linux/Mac:**
```bash
chmod +x start_all_services.sh
./start_all_services.sh
```

**Windows:**
```bash
start_all_services.bat
```

### Option 2: Manual Start (4 Terminals)

**Terminal 1 - MongoDB:**
```bash
cd data-base/docker
docker-compose up -d
cd ../..
```

**Terminal 2 - Browser Service:**
```bash
cd Browser-server
python api_server.py
```

**Terminal 3 - Database Service:**
```bash
cd data-base
python api_server.py
```

**Terminal 4 - Backend Service:**
```bash
cd back-end
python api_server.py
```

**Terminal 5 - Frontend Service:**
```bash
cd Front-end
python server.py
```

## Verify Services

Check that all services are running:

```bash
# Health checks
curl http://localhost:8000/health  # Backend
curl http://localhost:8001/health  # Browser
curl http://localhost:8002/health  # Database
```

Or open in browser:
- Frontend UI: http://localhost:8003
- Backend API docs: http://localhost:8000/docs
- Browser API docs: http://localhost:8001/docs
- Database API docs: http://localhost:8002/docs

## Create Your First Task

1. Open the frontend: http://localhost:8003

2. Enter a task prompt:
   ```
   Search for "browser automation" on DuckDuckGo
   ```

3. Set max steps: `10`

4. Select browser: `Firefox`

5. Click "Start Task"

6. Watch the real-time execution in the output panel!

## Stopping Services

**Linux/Mac:**
```bash
./stop_all_services.sh
```

**Windows:**
```bash
stop_all_services.bat
```

Or manually:
- Press `Ctrl+C` in each service terminal
- Stop MongoDB: `cd data-base/docker && docker-compose down`

## Troubleshooting

### Services Won't Start

1. **Check ports are free:**
   ```bash
   # Linux/Mac
   lsof -i :8000 -i :8001 -i :8002 -i :8003
   
   # Windows
   netstat -an | findstr "8000 8001 8002 8003"
   ```

2. **Check MongoDB is running:**
   ```bash
   docker ps | grep mongodb
   ```

3. **Verify Python dependencies:**
   ```bash
   pip list | grep -E "fastapi|playwright|pymongo|browser-use"
   ```

### Browser Service Issues

- Ensure Playwright browsers are installed: `playwright install`
- Check logs: `logs/browser_service.log`

### Backend Service Issues

- Verify Google API key is set: `cat back-end/.env`
- Check API key is valid
- Review logs: `logs/backend_service.log`

### Task Execution Fails

- Check all services are running
- Verify browser service can start browsers
- Check Google API quota/limits
- Review backend logs for specific errors

## Next Steps

- Read individual service README files for detailed documentation
- Explore the API endpoints using the interactive docs
- Customize browser automation tasks
- Check out the main [README.md](README.md) for architecture details

## Common Tasks

### View Task History

1. Open frontend: http://localhost:8003
2. Click on any task in the task list
3. View execution history in the output panel

### Check Service Status

```bash
# Backend health
curl http://localhost:8000/health

# Browser health
curl http://localhost:8001/health

# Database health
curl http://localhost:8002/health
```

### View Logs

All service logs are in the `logs/` directory:
- `logs/browser_service.log`
- `logs/database_service.log`
- `logs/backend_service.log`
- `logs/frontend_service.log`

## Need Help?

- Check service-specific README files
- Review troubleshooting sections
- Check service logs for errors
- Verify service connectivity

Enjoy automating! 🚀

