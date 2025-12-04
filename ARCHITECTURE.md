# System Architecture

## Overview

Data Collector ADIA is a distributed microservices system for AI-powered browser automation. The system is designed with clear separation of concerns, where each service can run independently and communicate via gRPC (Remote Procedure Calls).

## Architecture Diagram

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

## Service Communication

### Communication Patterns

1. **gRPC (Remote Procedure Calls)**: All service-to-service communication uses gRPC
2. **Protocol Buffers**: Type-safe message definitions for all RPC calls
3. **Direct Database Access**: Only Database Service accesses MongoDB

### Request Flow

```
User Action (Streamlit Frontend)
    ↓
Frontend → Backend Service (gRPC: StartTask)
    ↓
Backend Service
    ├─→ Database Service (gRPC: CreateTask) - Create task
    ├─→ Browser Service (gRPC: StartBrowser) - Start browser
    └─→ Execute browser_use Agent
        └─→ Save outputs (gRPC: SaveTaskOutput → Database)
```

## Service Details

### 1. Frontend Service

**Technology**: Streamlit, Python, gRPC

**Responsibilities**:
- User interface for task management
- Task history display
- Task creation form
- Real-time status updates via polling

**Communication**:
- gRPC to Backend Service (StartTask, GetTaskStatus, CancelTask)
- gRPC to Database Service (ListTasks, GetTaskHistory, GetTask)

**gRPC Methods Used**:
- `BackendService.StartTask` - Start new task
- `BackendService.GetTaskStatus` - Get task status
- `BackendService.CancelTask` - Cancel running task
- `DatabaseService.ListTasks` - List all tasks
- `DatabaseService.GetTaskHistory` - Get task execution history
- `DatabaseService.GetTask` - Get task details

### 2. Backend Service

**Technology**: gRPC, Python, browser_use

**Responsibilities**:
- Task orchestration and execution
- Browser agent management
- Service coordination
- Error handling

**Dependencies**:
- Browser Service (gRPC client for browser instances)
- Database Service (gRPC client for task persistence)
- Google Gemini API (for LLM)

**Key Components**:
- `run_agent_task()`: Executes browser automation
- `get_browser_connection()`: Acquires browser via gRPC from Browser Service
- `save_task_output()`: Saves outputs via gRPC to Database Service

**gRPC Methods**:
- `StartTask` - Start new browser automation task
- `GetTaskStatus` - Get current task status
- `CancelTask` - Cancel a running task

### 3. Browser Service

**Technology**: gRPC, Python, Playwright

**Responsibilities**:
- Browser instance management
- Playwright server lifecycle
- CDP URL generation
- Process management

**Key Features**:
- Start/stop browser instances on demand
- Support multiple browsers (Firefox, Chrome, WebKit)
- Port management
- Process tracking

**gRPC Methods**:
- `StartBrowser` - Start browser instance
- `StopBrowser` - Stop browser instance
- `GetBrowserConnection` - Get CDP URL and connection info
- `IsBrowserRunning` - Check if browser is running

**Browser Connection**:
- Uses Playwright's `run-server` command
- Provides CDP URLs for browser_use
- Manages browser processes and cleanup

### 4. Database Service

**Technology**: gRPC, Python, PyMongo

**Responsibilities**:
- Task data persistence
- Output storage
- History management
- Status tracking

**Collections**:
- `tasks`: Task metadata and status
- `task_outputs`: Step-by-step execution outputs

**gRPC Methods**:
- `CreateTask` - Create new task
- `GetTask` - Get task by ID
- `ListTasks` - List all tasks (with optional filters)
- `SaveTaskOutput` - Save task output/step
- `GetTaskHistory` - Get all outputs for a task
- `UpdateTaskStatus` - Update task status

### 5. MongoDB

**Technology**: MongoDB 7.0 (Docker)

**Storage**:
- Tasks collection
- Task outputs collection
- Indexed on task_id and timestamp

## Data Flow

### Task Creation Flow

```
1. User submits task in Streamlit Frontend
   ↓
2. Frontend → Backend: gRPC StartTask
   ↓
3. Backend → Database: gRPC CreateTask (create task record)
   ↓
4. Backend → Browser: gRPC StartBrowser (acquire browser)
   ↓
5. Backend receives CDP URL
   ↓
6. Backend initializes browser_use Agent with CDP URL
   ↓
7. Backend starts task execution (async)
```

### Task Execution Flow

```
1. browser_use Agent executes steps
   ↓
2. On each step:
   ├─→ Backend formats step data
   └─→ Backend → Database: gRPC SaveTaskOutput
   ↓
3. On completion:
   ├─→ Backend → Database: gRPC SaveTaskOutput (final)
   └─→ Backend → Database: gRPC UpdateTaskStatus (completed)
```

### Task History Flow

```
1. User selects task in Streamlit Frontend
   ↓
2. Frontend → Database: gRPC GetTaskHistory
   ↓
3. Database returns all outputs for task
   ↓
4. Frontend displays history in expandable sections
```

## Remote Browser Integration

### CDP URL Usage

The system uses Chrome DevTools Protocol (CDP) URLs to connect to remote browsers:

```python
# Browser Service provides CDP URL
cdp_url = "http://localhost:9999"

# Backend uses it with browser_use
browser = Browser(
    headless=True,
    cdp_url=cdp_url
)
```

### Browser Options

1. **Local Browser Service** (Default)
   - Managed by Browser Service
   - Playwright server on demand
   - Full control over browser lifecycle

2. **Browser-Use Cloud Service**
   - Managed cloud browsers
   - Requires API key
   - Automatic provisioning

3. **Custom CDP URL**
   - Any CDP-compatible browser
   - External browser providers
   - Maximum flexibility

## Scalability Considerations

### Horizontal Scaling

- **Frontend**: Can be served via CDN or load balancer
- **Backend**: Stateless, can scale horizontally
- **Browser Service**: Can run multiple instances with different ports
- **Database Service**: Can scale, but MongoDB should be clustered

### Resource Management

- Browser instances are created on demand
- Browsers are cleaned up after task completion
- Tasks are tracked in memory for cancellation
- Database stores persistent data

## Security Considerations

### Current Implementation

- No authentication (development mode)
- CORS enabled for all origins
- Direct MongoDB access only from Database Service

### Production Recommendations

1. Add authentication/authorization
2. Use environment variables for secrets
3. Implement API keys or JWT tokens
4. Secure WebSocket connections (WSS)
5. Network isolation between services
6. MongoDB authentication enabled

## Deployment Options

### Development

- All services on localhost
- Individual service processes
- Direct port access

### Production

- Containerized services (Docker)
- Orchestration (Kubernetes, Docker Compose)
- Reverse proxy (Nginx)
- Load balancing
- Service discovery

## Future Enhancements

### Planned Features

1. **gRPC Streaming**
   - Server-side streaming for real-time updates
   - Bidirectional streaming for interactive tasks

2. **Service Mesh**
   - Service discovery
   - Load balancing
   - Circuit breakers

3. **Message Queue**
   - Task queuing
   - Background processing
   - Better scalability

4. **Monitoring**
   - Metrics collection
   - Distributed tracing
   - Health checks

5. **Multi-user Support**
   - User authentication
   - Resource quotas
   - Task isolation

## Technology Stack Summary

| Service | Framework | Language | Key Dependencies |
|---------|-----------|----------|------------------|
| Frontend | Streamlit | Python | streamlit, grpcio |
| Backend | gRPC | Python | browser_use, grpcio |
| Browser | gRPC | Python | Playwright, grpcio |
| Database | gRPC | Python | PyMongo, grpcio |
| Storage | MongoDB | - | - |

## Communication Protocols

| Service Pair | Protocol | Purpose |
|--------------|----------|---------|
| Frontend ↔ Backend | gRPC | Task management |
| Frontend ↔ Database | gRPC | History retrieval |
| Backend ↔ Browser | gRPC | Browser management |
| Backend ↔ Database | gRPC | Data persistence |
| Database ↔ MongoDB | MongoDB Protocol | Data storage |

## Protocol Buffer Definitions

All gRPC services use Protocol Buffers for message definitions:
- `shared/protos/browser_service.proto` - Browser Service interface
- `shared/protos/database_service.proto` - Database Service interface
- `shared/protos/backend_service.proto` - Backend Service interface

Generate Python code from proto files:
```bash
python shared/generate_protos.py
```

This architecture provides a solid foundation for a distributed browser automation system with clear separation of concerns and scalability potential.

