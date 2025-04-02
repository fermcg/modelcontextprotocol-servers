#!/bin/sh

# Test script for nginx routing issues
# Uses only /bin/sh compatible syntax for host and container compatibility

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "${YELLOW}Starting nginx routing test...${NC}"

# Define the endpoints to test
ENDPOINTS="
http://localhost:8204/sse
http://localhost:8109/fetch
"

# Function to test an endpoint with curl
test_endpoint() {
    local url="$1"
    echo "${YELLOW}Testing: ${url}${NC}"
    
    # Send a request with curl
    # -s silent mode, -o /dev/null to discard output, -w to show status code
    # --max-time 5 to timeout after 5 seconds
    # For SSE endpoints, don't use HEAD request since we need to establish the connection
    response=$(curl -s --max-time 5 -w "%{http_code}" -o /dev/null "${url}" || echo "Failed")
    
    if [ "$response" = "Failed" ]; then
        echo "${RED}Connection failed or timed out for ${url}${NC}"
        return 1
    elif [ "$response" -ge 200 ] && [ "$response" -lt 400 ]; then
        echo "${GREEN}Success: ${url} returned status code ${response}${NC}"
        return 0
    else
        echo "${RED}Error: ${url} returned status code ${response}${NC}"
        return 1
    fi
}

# Test if nginx is running
echo "${YELLOW}Checking if nginx is running on port 8109...${NC}"
if ! curl -s --max-time 2 http://localhost:8109 > /dev/null 2>&1; then
    echo "${RED}Warning: Nginx might not be running or not listening on port 8109${NC}"
fi

# Test each endpoint
failures=0
for endpoint in $ENDPOINTS; do
    if ! test_endpoint "$endpoint"; then
        failures=$((failures + 1))
    fi
done

echo ""
if [ "$failures" -eq 0 ]; then
    echo "${GREEN}All endpoints tested successfully!${NC}"
    exit 0
else
    echo "${RED}${failures} endpoint(s) failed the test.${NC}"
    exit 1
fi 