#!/bin/bash

set -e

echo "=== Voting App Smoke Tests ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local url=$1
    local expected_code=$2
    local service_name=$3
    
    echo -n "Testing $service_name ($url)... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    if [ "$response" = "$expected_code" ]; then
        echo -e "${GREEN}PASSED${NC} (HTTP $response)"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAILED${NC} (Expected HTTP $expected_code, got $response)"
        FAILED=$((FAILED + 1))
    fi
}

# Function to test database
test_database() {
    echo -n "Testing PostgreSQL connection... "
    
    if sudo docker compose exec -T db pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Function to test Redis
test_redis() {
    echo -n "Testing Redis connection... "
    
    if sudo docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        FAILED=$((FAILED + 1))
    fi
}

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 15

# Run tests
echo ""
echo "Running endpoint tests..."
test_endpoint "http://localhost:5000" "200" "Vote Service"
test_endpoint "http://localhost:5001" "200" "Result Service"

echo ""
echo "Running infrastructure tests..."
test_database
test_redis

# Test voting functionality
echo ""
echo -n "Testing vote submission... "
vote_response=$(curl -s -X POST -d "vote=a" http://localhost:5000/ || echo "failed")
if [[ "$vote_response" != "failed" ]]; then
    echo -e "${GREEN}PASSED${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}FAILED${NC}"
    FAILED=$((FAILED + 1))
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
