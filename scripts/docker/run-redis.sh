#!/bin/sh
# Run script for redis server

set -e

# PORT is required
if [ -z "$1" ]; then
  echo "ERROR: PORT parameter is required"
  echo "Usage: $0 PORT [HOST]"
  exit 1
fi

PORT="$1"
HOST="${2:-0.0.0.0}"

# Log function
log() {
  echo "[redis] $*" 
}

# Check required environment variables
if [ -z "${MCP_REDIS_CONNECTION_STRING}" ]; then
  log "ERROR: MCP_REDIS_CONNECTION_STRING environment variable is required"
  exit 1
fi

log "Starting redis server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-redis "${MCP_REDIS_CONNECTION_STRING}" 