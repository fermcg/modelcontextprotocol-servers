#!/bin/sh
# Run script for filesystem server

set -e

# PORT is required
if [ -z "$1" ]; then
  echo "ERROR: PORT parameter is required"
  echo "Usage: $0 PORT [HOST] [DIRS]"
  exit 1
fi

PORT="$1"
HOST="${2:-0.0.0.0}"
DIRS="${3:-${MCP_FILESYSTEM_DIR_LIST:-/tmp}}"

# Log function
log() {
  echo "[filesystem] $*" 
}

log "Starting filesystem server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-filesystem ${DIRS} 