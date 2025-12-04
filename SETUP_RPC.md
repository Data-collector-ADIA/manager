# RPC-Based Setup Guide

This guide explains how to set up and run the Data Collector ADIA system with gRPC-based service communication.

## Prerequisites

1. Python 3.11 or higher
2. Docker and Docker Compose (for MongoDB)
3. All Python dependencies installed

## Step 1: Generate Protocol Buffer Files

Before running any services, generate the Python code from `.proto` files:

```bash
cd shared
python generate_protos.py
```

This will create the necessary `*_pb2.py` and `*_pb2_grpc.py` files in each service directory.

## Step 2: Start MongoDB

```bash
cd data-base/docker
docker-compose up -d
```

Verify MongoDB is running:
```bash
docker ps
```

## Step 3: Install Dependencies

Install dependencies for each service:

```bash
# Browser Service
cd Browser-server
pip install -r requirements.txt

# Database Service
cd ../data-base
pip install -r requirements.txt

# Backend Service
cd ../back-end
pip install -r requirements.txt

# Frontend (Streamlit)
cd ../Front-end
pip install -r requirements.txt
```

## Step 4: Start Services

Start each service in a separate terminal:

### Terminal 1: Browser Service
```bash
cd Browser-server
python server.py
```
Service runs on port `50051` by default.

### Terminal 2: Database Service
```bash
cd data-base
python server.py
```
Service runs on port `50052` by default.

### Terminal 3: Backend Service
```bash
cd back-end
python server.py
```
Service runs on port `50050` by default.

### Terminal 4: Frontend (Streamlit)
```bash
cd Front-end
streamlit run app.py
```
Frontend runs on port `8501` by default.

Access the UI at: http://localhost:8501

## Environment Variables

You can customize service ports and hosts:

### Browser Service
- `BROWSER_SERVICE_PORT` (default: 50051)
- `BROWSER_SERVICE_HOST` (default: localhost)

### Database Service
- `DATABASE_SERVICE_PORT` (default: 50052)
- `DATABASE_SERVICE_HOST` (default: localhost)
- `MONGO_URI` (default: mongodb://admin:admin123@localhost:27017/adiadb?authSource=admin)

### Backend Service
- `BACKEND_SERVICE_PORT` (default: 50050)
- `BACKEND_SERVICE_HOST` (default: localhost)
- `BROWSER_SERVICE_HOST` (default: localhost)
- `BROWSER_SERVICE_PORT` (default: 50051)
- `DATABASE_SERVICE_HOST` (default: localhost)
- `DATABASE_SERVICE_PORT` (default: 50052)
- `GOOGLE_API_KEY` (required for Gemini LLM)

### Frontend
- `BACKEND_SERVICE_HOST` (default: localhost)
- `BACKEND_SERVICE_PORT` (default: 50050)
- `DATABASE_SERVICE_HOST` (default: localhost)
- `DATABASE_SERVICE_PORT` (default: 50052)

## Verifying Services

### Check Browser Service
```bash
# Using grpcurl (if installed)
grpcurl -plaintext localhost:50051 list
```

### Check Database Service
```bash
grpcurl -plaintext localhost:50052 list
```

### Check Backend Service
```bash
grpcurl -plaintext localhost:50050 list
```

## Troubleshooting

### Protobuf Import Errors

If you see import errors like `ModuleNotFoundError: No module named 'database_service_pb2'`:

1. Make sure you've run `python shared/generate_protos.py`
2. Check that the generated files exist in the service directories
3. Verify you're running the service from the correct directory

### Connection Errors

If services can't connect:

1. Verify all services are running
2. Check that ports are not already in use
3. Verify environment variables are set correctly
4. Check firewall settings

### MongoDB Connection Issues

1. Verify MongoDB is running: `docker ps`
2. Check MongoDB logs: `docker logs mongodb`
3. Verify connection string in environment variables
4. Test connection: `mongosh "mongodb://admin:admin123@localhost:27017/adiadb?authSource=admin"`

## Service Ports Summary

| Service | Default Port | Protocol |
|---------|--------------|----------|
| Frontend (Streamlit) | 8501 | HTTP |
| Backend Service | 50050 | gRPC |
| Browser Service | 50051 | gRPC |
| Database Service | 50052 | gRPC |
| MongoDB | 27017 | MongoDB Protocol |

## Next Steps

1. Open the Streamlit frontend at http://localhost:8501
2. Create a new task
3. Monitor task execution
4. View task history

For more details, see [ARCHITECTURE.md](ARCHITECTURE.md).

