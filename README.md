# Voting Application - DevOps Challenge

## Project Overview

This is a distributed voting application that allows users to vote between two options and view real-time results. The application consists of multiple microservices that work together to provide a complete voting experience.

## Application Architecture

The voting application consists of the following components:

![Architecture Diagram](./architecture.excalidraw.png)

### Frontend Services
- **Vote Service** (`/vote`): Python Flask web application that provides the voting interface
- **Result Service** (`/result`): Node.js web application that displays real-time voting results

### Backend Services  
- **Worker Service** (`/worker`): .NET worker application that processes votes from the queue
- **Redis**: Message broker that queues votes for processing
- **PostgreSQL**: Database that stores the final vote counts

### Data Flow
1. Users visit the vote service to cast their votes
2. Votes are sent to Redis queue
3. Worker service processes votes from Redis and stores them in PostgreSQL
4. Result service queries PostgreSQL and displays real-time results via WebSocket

### Network Architecture
The application uses a **two-tier network architecture** for security and organization:

- **Frontend Tier Network**: 
  - Vote service (port 5000)
  - Result service (port 5001)
  - Accessible from outside the Docker environment

- **Backend Tier Network**:
  - Worker service
  - Redis
  - PostgreSQL
  - Internal communication only

This separation ensures that database and message queue services are not directly accessible from outside, while the web services remain accessible to users.

---

## Phase 1: Containerization & Local Development ✅ COMPLETED

### Implemented Solutions

#### 1. Docker Files ✅
Created multi-stage Dockerfiles for all services:
- ✅ `docker/vote/Dockerfile` - Python Flask with Gunicorn
- ✅ `docker/result/Dockerfile` - Node.js with Express
- ✅ `docker/worker/Dockerfile` - .NET 7.0 worker application

**Key Features:**
- Multi-stage builds for optimized image sizes
- Alpine Linux base images for security
- Non-root user configuration
- Security updates via `apk upgrade`
- Proper health checks

#### 2. Docker Compose ✅
Created comprehensive Docker Compose configuration:
- ✅ `docker-compose.yml` - Production configuration
- ✅ `docker-compose.override.yml` - Development overrides

**Implementation Details:**
- Two-tier network architecture (frontend/backend)
- Health checks for Redis and PostgreSQL
- Proper service dependencies with `depends_on` conditions
- Environment variable configuration
- Vote service on port 5000
- Result service on port 5001

#### 3. Automation & Testing ✅
Created `Makefile` with commands:
```bash
make build          # Build all Docker images
make up             # Start all services
make down           # Stop all services
make logs           # View logs
make ps             # Show running containers
make test           # Run smoke tests
make security-scan  # Run Trivy vulnerability scans
make clean          # Clean up all resources
make restart        # Restart services
make rebuild        # Rebuild and restart
```

**Smoke Test Suite:**
- ✅ Vote service endpoint validation
- ✅ Result service endpoint validation
- ✅ PostgreSQL connectivity test
- ✅ Redis connectivity test
- ✅ Vote submission functionality test

All tests passing: **5/5** ✅

#### 4. Security Implementation ✅
- ✅ Trivy integration for vulnerability scanning
- ✅ Non-root users in all containers
- ✅ Minimal Alpine Linux base images
- ✅ Regular security updates
- ✅ Network isolation (frontend/backend)

### Bug Fixes Applied

1. **Result Service Port Mapping** - Fixed port mismatch (internal 4000 → external 5001)
2. **Worker .NET Compatibility** - Aligned Dockerfile to use .NET 7.0 runtime
3. **Volume Mount Conflict** - Removed worker volume mount that overwrote compiled DLL
4. **Test Script Arithmetic** - Fixed `((var++))` operations causing premature exit
5. **Permission Handling** - Added sudo support for Docker commands

---

## Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose V2
- Make
- Trivy (for security scanning)

### Running the Application
```bash
# Build all images
make build

# Start all services
make up

# Wait for services to be healthy (about 30 seconds)
# Check status
make ps

# Run tests to verify everything works
make test

# Access the application
# Vote: http://localhost:5000
# Results: http://localhost:5001
```

### Stopping the Application
```bash
# Stop services
make down

# Clean everything (containers, volumes, images)
make clean
```

---

## Development

For local development with hot-reloading:
```bash
# Services automatically use docker-compose.override.yml
make up

# View logs in real-time
make logs
```

**Note:** The override file provides volume mounts for vote and result services for development convenience.

---

## Testing

Run the comprehensive smoke test suite:
```bash
make test
```

Expected output:
```
=== Voting App Smoke Tests ===
Testing Vote Service (http://localhost:5000)... PASSED (HTTP 200)
Testing Result Service (http://localhost:5001)... PASSED (HTTP 200)
Testing PostgreSQL connection... PASSED
Testing Redis connection... PASSED
Testing vote submission... PASSED

=== Test Summary ===
Passed: 5
Failed: 0
All tests passed!
```

---

## Security Scanning

Run Trivy security scans:
```bash
make security-scan
```

Scans all custom images for HIGH and CRITICAL vulnerabilities.

---

## Project Structure
```
.
├── vote/                           # Python voting service
│   ├── app.py
│   └── requirements.txt
├── result/                         # Node.js results service
│   ├── server.js
│   └── package.json
├── worker/                         # .NET worker service
│   ├── Program.cs
│   └── Worker.csproj
├── docker/                         # Dockerfiles
│   ├── vote/Dockerfile
│   ├── result/Dockerfile
│   └── worker/Dockerfile
├── scripts/
│   └── smoke-test.sh              # Automated testing
├── docker-compose.yml             # Production config
├── docker-compose.override.yml    # Development overrides
├── Makefile                       # Automation commands
└── README.md                      # This file
```

---

## Troubleshooting

### Services not starting
```bash
# Check logs for errors
make logs

# Rebuild from scratch
make clean
make build
make up
```

### Tests failing
```bash
# Ensure all services are healthy
make ps

# Wait longer for services to stabilize
sleep 30
make test
```

### Worker service restarting
- Verify .NET 7.0 compatibility in Worker.csproj
- Check Redis and PostgreSQL connectivity
- Review worker logs: `docker compose logs worker`

### Permission denied errors
```bash
# Add user to docker group (one-time setup)
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

---

## Technical Details

### Service Ports
- **Vote Service**: 5000 (external) → 5000 (internal)
- **Result Service**: 5001 (external) → 4000 (internal)
- **PostgreSQL**: 5432 (internal only)
- **Redis**: 6379 (internal only)

### Health Checks
- **Redis**: `redis-cli ping` every 5s
- **PostgreSQL**: `pg_isready` every 10s
- **Worker**: Process check every 30s
- **Vote**: HTTP check on port 5000
- **Result**: HTTP check on port 4000

### Environment Variables
All services configured with appropriate environment variables for connectivity and configuration.

---

## Next Phases

- **Phase 2**: CI/CD Pipeline Setup
- **Phase 3**: Kubernetes Deployment
- **Phase 4**: Monitoring & Observability

---

## Contributing

Hassan - DevOps Engineer

---

## License
Code Quest Challanges
