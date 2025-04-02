#!/bin/sh
# Run script for sequential-thinking server

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
  echo "[sequential-thinking] $*" 
}

log "Starting sequential-thinking server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-sequential-thinking 