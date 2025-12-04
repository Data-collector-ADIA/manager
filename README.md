# Data Collector ADIA - Project Overview

A distributed microservices system for AI-powered browser automation. The system uses gRPC (Remote Procedure Calls) for inter-service communication, allowing each service to run independently on separate machines or in isolated environments.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Streamlit Frontend                       │
│                      (Port 8501)                            │
│  - Task Creation Interface                                   │
│  - Task History Viewing                                      │
│  - Real-time Status Updates                                  │
└───────────────────────┬─────────────────────────────────────┘
                        │ gRPC
                        │
┌───────────────────────▼─────────────────────────────────────┐
│                    Backend Service                           │
│                     (Port 50050)                             │
│  - Task Orchestration                                        │
│  - browser_use Agent Execution                               │
│  - Service Coordination                                      │
└───────────┬──────────────────────────┬──────────────────────┘
            │                          │
            │ gRPC                     │ gRPC
            │                          │
┌───────────▼──────────┐   ┌──────────▼─────────────┐
│   Browser Service    │   │   Database Service     │
│    (Port 50051)      │   │    (Port 50052)        │
│                      │   │                        │
│  - Playwright Server │   │  - MongoDB Connection  │
│  - Browser Instance  │   │  - Task Storage        │
│  - CDP URL Provider  │   │  - Output Storage      │
│  - Process Management│   │  - History Management  │
└──────────────────────┘   └──────────┬─────────────┘
                                      │
                            ┌─────────▼─────────┐
                            │     MongoDB       │
                            │   (Port 27017)    │
                            │                   │
                            │  - Tasks Collection│
                            │  - Outputs Collection│
                            └───────────────────┘
```

## Project Structure

```
Data-collector-ADIA/
├── Browser-server/          # Browser management service
│   ├── server.py            # gRPC server
│   ├── browser_server.py    # Browser management logic
│   ├── QUICKSTART.md        # Quick start guide
│   └── README.md            # Service documentation
│
├── data-base/               # Database service
│   ├── server.py            # gRPC server
│   ├── mongodb_connection.py # MongoDB connection manager
│   ├── docker/              # MongoDB Docker setup
│   │   └── docker-compose.yml
│   ├── QUICKSTART.md        # Quick start guide
│   └── README.md            # Service documentation
│
├── back-end/                # Backend orchestration service
│   ├── server.py            # gRPC server
│   ├── app.py               # Core browser automation logic
│   ├── browser_use/         # browser_use library
│   ├── QUICKSTART.md        # Quick start guide
│   └── README.md            # Service documentation
│
├── Front-end/               # Streamlit frontend
│   ├── app.py               # Streamlit application
│   ├── QUICKSTART.md        # Quick start guide
│   └── README.md            # Service documentation
│
├── shared/                  # Shared definitions
│   ├── protos/              # Protocol Buffer definitions
│   │   ├── browser_service.proto
│   │   ├── database_service.proto
│   │   └── backend_service.proto
│   ├── generate_protos.py   # Protobuf generation script
│   └── README.md            # Protobuf documentation
│
└── manager/                 # Project management
    ├── README.md            # This file
    ├── ARCHITECTURE.md      # Detailed architecture
    ├── QUICKSTART.md        # Quick start guide
    └── start_all_services.sh # Service startup script
```

## Services Overview

### 1. Frontend Service (Streamlit)
- **Port**: 8501
- **Technology**: Streamlit, Python, gRPC
- **Purpose**: Web-based UI for task management and monitoring
- **Location**: `Front-end/`

### 2. Backend Service
- **Port**: 50050 (gRPC)
- **Technology**: Python, gRPC, browser_use
- **Purpose**: Orchestrates browser automation tasks
- **Location**: `back-end/`

### 3. Browser Service
- **Port**: 50051 (gRPC)
- **Technology**: Python, gRPC, Playwright
- **Purpose**: Manages Playwright browser instances
- **Location**: `Browser-server/`

### 4. Database Service
- **Port**: 50052 (gRPC)
- **Technology**: Python, gRPC, PyMongo
- **Purpose**: MongoDB data persistence
- **Location**: `data-base/`

### 5. MongoDB
- **Port**: 27017
- **Technology**: MongoDB 7.0
- **Purpose**: Data storage
- **Location**: `data-base/docker/`

## Communication Protocol

All services communicate via **gRPC (Remote Procedure Calls)** using Protocol Buffers for type-safe message definitions.

### Benefits of gRPC

- **Performance**: Binary protocol, faster than REST
- **Type Safety**: Protocol Buffers ensure type correctness
- **Streaming**: Built-in support for streaming data
- **Language Agnostic**: Services can be written in different languages
- **Production Ready**: Used by Google and many major companies

## Quick Start

### Prerequisites

- Python 3.11+
- Docker and Docker Compose
- Playwright browsers
- Google API Key (for Gemini LLM)

### One-Time Setup

1. **Generate Protocol Buffer Files**
   ```bash
   cd shared
   python generate_protos.py
   ```

2. **Install Dependencies for Each Service**
   ```bash
   # Browser Service
   cd Browser-server && pip install -r requirements.txt && cd ..
   
   # Database Service
   cd data-base && pip install -r requirements.txt && cd ..
   
   # Backend Service
   cd back-end && pip install -r requirements.txt && cd ..
   
   # Frontend Service
   cd Front-end && pip install -r requirements.txt && cd ..
   ```

3. **Install Playwright Browsers**
   ```bash
   playwright install
   ```

4. **Set Up Environment Variables**
   
   Create `.env` in `back-end/`:
   ```bash
   GOOGLE_API_KEY=your_google_api_key_here
   ```

### Running Services

Each service should run on a separate machine in production, but for testing, you can run them in separate screen sessions on the same machine.

#### Option 1: Using Screen Sessions (Testing)

```bash
# Terminal 1: Browser Service
cd Browser-server
screen -S browser-service
python server.py
# Press Ctrl+A then D to detach

# Terminal 2: Database Service
cd data-base
screen -S database-service
python server.py
# Press Ctrl+A then D to detach

# Terminal 3: Backend Service
cd back-end
screen -S backend-service
python server.py
# Press Ctrl+A then D to detach

# Terminal 4: Frontend Service
cd Front-end
screen -S frontend-service
streamlit run app.py
# Press Ctrl+A then D to detach
```

#### Option 2: Separate Machines (Production)

Each service runs independently on its own machine:

- **Machine 1**: Browser Service (port 50051)
- **Machine 2**: Database Service (port 50052)
- **Machine 3**: Backend Service (port 50050)
- **Machine 4**: Frontend Service (port 8501)
- **Machine 5**: MongoDB (port 27017)

Configure service addresses via environment variables.

### Access the System

- **Frontend UI**: http://localhost:8501
- **Service Health**: Check individual service READMEs

## Configuration

### Service Ports

| Service | Default Port | Protocol |
|---------|-------------|----------|
| Frontend | 8501 | HTTP |
| Backend | 50050 | gRPC |
| Browser | 50051 | gRPC |
| Database | 50052 | gRPC |
| MongoDB | 27017 | MongoDB |

### Environment Variables

Each service can be configured via environment variables. See individual service READMEs for details:

- [Browser Service README](../Browser-server/README.md)
- [Database Service README](../data-base/README.md)
- [Backend Service README](../back-end/README.md)
- [Frontend Service README](../Front-end/README.md)

## Usage

### Creating a Task

1. Open the Streamlit frontend: http://localhost:8501
2. Navigate to "Create Task"
3. Enter task prompt (e.g., "Search for browser automation on DuckDuckGo")
4. Set max steps and browser type
5. Click "Start Task"
6. Monitor execution in real-time

### Viewing Task History

1. Navigate to "Task List" in the frontend
2. Select a task to view its history
3. See step-by-step execution details

## Development

### Project Structure

Each service is self-contained with:
- `server.py` - gRPC server implementation
- `README.md` - Service documentation
- `QUICKSTART.md` - Quick start guide
- `requirements.txt` - Python dependencies

### Protocol Buffer Definitions

All gRPC services use Protocol Buffers defined in `shared/protos/`:
- `browser_service.proto` - Browser Service interface
- `database_service.proto` - Database Service interface
- `backend_service.proto` - Backend Service interface

Generate Python code:
```bash
cd shared
python generate_protos.py
```

### Service Independence

Each service:
- Can run on separate machines
- Can be scaled independently
- Can be developed independently
- Can be replaced independently

## Deployment

### Testing Environment

Run all services on the same machine using screen sessions (see Quick Start above).

### Production Environment

Deploy each service on separate machines:

1. **Browser Service Machine**
   - Install Python 3.11+
   - Install Playwright browsers
   - Run `python server.py`
   - Expose port 50051

2. **Database Service Machine**
   - Install Python 3.11+
   - Run `python server.py`
   - Expose port 50052
   - Connect to MongoDB (local or remote)

3. **Backend Service Machine**
   - Install Python 3.11+
   - Set `GOOGLE_API_KEY`
   - Configure service addresses
   - Run `python server.py`
   - Expose port 50050

4. **Frontend Service Machine**
   - Install Python 3.11+
   - Run `streamlit run app.py`
   - Expose port 8501

5. **MongoDB Machine**
   - Run MongoDB (Docker or native)
   - Expose port 27017

## Troubleshooting

### Service Connection Issues

1. Verify all services are running
2. Check service ports are accessible
3. Verify environment variables are set correctly
4. Check firewall/network rules

### Protobuf Errors

```bash
# Regenerate protobuf files
cd shared
python generate_protos.py
```

### Service-Specific Issues

See individual service READMEs:
- [Browser Service](../Browser-server/README.md)
- [Database Service](../data-base/README.md)
- [Backend Service](../back-end/README.md)
- [Frontend Service](../Front-end/README.md)

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed system architecture
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
- **Service READMEs** - Individual service documentation
- **Service QUICKSTARTs** - Individual service quick start guides

## License

Part of the Data Collector ADIA project.

## Support

For issues or questions:
1. Check service-specific README files
2. Review troubleshooting sections
3. Check service logs
4. Verify service connectivity
