#!/bin/sh
# Run script for time server

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
  echo "[time] $*" 
}

# Set timezone option if available
TZ_OPT=""
if [ -n "${MCP_TIME_LOCAL_TIMEZONE}" ]; then
  TZ_OPT="--local-timezone=${MCP_TIME_LOCAL_TIMEZONE}"
elif [ -n "${TZ}" ]; then
  TZ_OPT="--local-timezone=${TZ}"
fi

log "Starting time server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  -- uvx mcp-server-time ${TZ_OPT} 