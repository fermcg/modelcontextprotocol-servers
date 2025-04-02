#!/bin/sh
# Run script for memory server

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
  echo "[memory] $*" 
}

log "Starting memory server on port ${PORT}..."

# Check if memory file path is set
OPT_ARG=""
if [ -n "${MCP_MEMORY_FILE_PATH}" ]; then
  OPT_ARG="--env MEMORY_FILE_PATH \"${MCP_MEMORY_FILE_PATH}\""
fi

exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  ${OPT_ARG} \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-memory 