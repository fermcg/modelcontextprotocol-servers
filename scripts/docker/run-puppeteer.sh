#!/bin/sh
# Run script for puppeteer server

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
  echo "[puppeteer] $*" 
}

log "Starting puppeteer server on port ${PORT}..."

# Build command with optional arguments
ARGS=""
if [ -n "${MCP_PUPPETEER_LAUNCH_OPTIONS}" ]; then
  ARGS="$ARGS --env PUPPETEER_LAUNCH_OPTIONS \"${MCP_PUPPETEER_LAUNCH_OPTIONS}\""
fi
if [ -n "${MCP_PUPPETEER_ALLOW_DANGEROUS}" ]; then
  ARGS="$ARGS --env ALLOW_DANGEROUS \"${MCP_PUPPETEER_ALLOW_DANGEROUS}\""
fi

exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  --env PUPPETEER_SKIP_CHROMIUM_DOWNLOAD "true" \
  --env PUPPETEER_EXECUTABLE_PATH "/usr/bin/chromium" \
  ${ARGS} \
  --env NODE_ENV "production" \
  -- npx -y @modelcontextprotocol/server-puppeteer 