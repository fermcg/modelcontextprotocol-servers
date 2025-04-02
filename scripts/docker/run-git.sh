#!/bin/sh
# Run script for git server

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
  echo "[git] $*" 
}

# Check required environment variables
if [ -z "${MCP_GIT_REPOSITORY_PATH}" ]; then
  log "ERROR: MCP_GIT_REPOSITORY_PATH environment variable is required"
  exit 1
fi

log "Starting git server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  -- uvx mcp-server-git --repository "${MCP_GIT_REPOSITORY_PATH}" 