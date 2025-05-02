#!/bin/sh
# Run script for excel-mcp-server

set -e

# PORT is required
if [ -z "$1" ]; then
  echo "ERROR: PORT parameter is required"
  echo "Usage: $0 PORT"
  exit 1
fi

PORT="$1"
HOST="${2:-0.0.0.0}"

# Log function
log() {
  echo "[haris-musa:excel-mcp-server] $*"
}

log "Starting haris-musa:excel-mcp-server on port ${PORT}..."
sleep 5
# Set FASTMCP_PORT and run the server
cd ./src/hm-excel
export FASTMCP_PORT="${PORT}"
export FASTMCP_HOST="${HOST}"
source .venv/bin/activate
uv run excel-mcp-server