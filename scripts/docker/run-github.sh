#!/bin/sh
# Run script for github server

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
  echo "[github] $*" 
}

# Check required environment variables
if [ -z "${MCP_GITHUB_PERSONAL_ACCESS_TOKEN}" ]; then
  log "ERROR: MCP_GITHUB_PERSONAL_ACCESS_TOKEN environment variable is required"
  exit 1
fi

log "Starting github server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env GITHUB_PERSONAL_ACCESS_TOKEN "${MCP_GITHUB_PERSONAL_ACCESS_TOKEN}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-github 