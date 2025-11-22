.PHONY: help build up down logs ps test clean restart rebuild security-scan

# Default target
help:
	@echo "Voting App - Make Commands"
	@echo "=========================="
	@echo "build          - Build all Docker images"
	@echo "up             - Start all services"
	@echo "down           - Stop all services"
	@echo "logs           - View logs from all services"
	@echo "ps             - Show running containers"
	@echo "test           - Run smoke tests"
	@echo "clean          - Remove all containers, volumes, and images"
	@echo "restart        - Restart all services"
	@echo "rebuild        - Rebuild and restart all services"
	@echo "security-scan  - Run Trivy security scans on all images"

# Build all images
build:
	@echo "Building Docker images..."
	docker compose build --no-cache

# Start services
up:
	@echo "Starting services..."
	docker compose up -d
	@echo "Waiting for services to be healthy..."
	@sleep 10
	@docker compose ps

# Stop services
down:
	@echo "Stopping services..."
	docker compose down

# View logs
logs:
	docker compose logs -f

# Show running containers
ps:
	sudo docker compose ps

# Run smoke tests
test:
	@echo "Running smoke tests..."
	@bash scripts/smoke-test.sh

# Clean everything
clean:
	@echo "Cleaning up..."
	docker compose down -v --rmi all --remove-orphans
	docker system prune -af --volumes

# Restart services
restart:
	docker compose restart

# Rebuild and restart
rebuild:
	docker compose down
	docker compose build --no-cache
	docker compose up -d

# Security scan
security-scan:
	@echo "Scanning images for vulnerabilities..."
	@for service in vote result worker; do \
		echo "Scanning $$service..."; \
		trivy image --severity HIGH,CRITICAL devops-$$service:latest; \
	done
