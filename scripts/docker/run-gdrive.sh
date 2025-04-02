#!/bin/sh
# Run script for gdrive server

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
  echo "[gdrive] $*" 
}

# Check required environment variables
if [ -z "${MCP_GDRIVE_CREDENTIALS_PATH}" ]; then
  log "ERROR: MCP_GDRIVE_CREDENTIALS_PATH environment variable is required"
  exit 1
fi

if [ -z "${MCP_GDRIVE_PATH}" ]; then
  log "ERROR: MCP_GDRIVE_PATH environment variable is required"
  exit 1
fi

log "Starting gdrive server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env GDRIVE_CREDENTIALS_PATH "${MCP_GDRIVE_CREDENTIALS_PATH}" \
  --env GDRIVE_PATH "${MCP_GDRIVE_PATH}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-gdrive 