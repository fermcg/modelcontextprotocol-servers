#!/bin/sh
# Run script for google-maps server

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
  echo "[google-maps] $*" 
}

# Check required environment variables
if [ -z "${MCP_GOOGLE_MAPS_API_KEY}" ]; then
  log "ERROR: MCP_GOOGLE_MAPS_API_KEY environment variable is required"
  exit 1
fi

log "Starting google-maps server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env GOOGLE_MAPS_API_KEY "${MCP_GOOGLE_MAPS_API_KEY}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-google-maps 