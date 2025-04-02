#!/bin/sh
# Run script for gitlab server

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
  echo "[gitlab] $*" 
}

# Check required environment variables
if [ -z "${MCP_GITLAB_PERSONAL_ACCESS_TOKEN}" ]; then
  log "ERROR: MCP_GITLAB_PERSONAL_ACCESS_TOKEN environment variable is required"
  exit 1
fi

if [ -z "${MCP_GITLAB_API_URL}" ]; then
  log "ERROR: MCP_GITLAB_API_URL environment variable is required"
  exit 1
fi

log "Starting gitlab server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env GITLAB_PERSONAL_ACCESS_TOKEN "${MCP_GITLAB_PERSONAL_ACCESS_TOKEN}" \
  --env GITLAB_API_URL "${MCP_GITLAB_API_URL}" \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-gitlab 