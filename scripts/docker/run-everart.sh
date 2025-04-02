#!/bin/sh
# Run script for everart server

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
  echo "[everart] $*" 
}

# Check required environment variables
if [ -z "${MCP_EVERART_API_KEY}" ]; then
  log "ERROR: MCP_EVERART_API_KEY environment variable is required"
  exit 1
fi

log "Starting everart server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env EVERART_API_KEY "${MCP_EVERART_API_KEY}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-everart 