#!/bin/sh
# Run script for gdrive server

set -e

ENV_FILE=""

# Parse options and command
OPTS=$(getopt -o e: -l env: -- "$@")
if [ $? != 0 ]; then
  echo "Failed to parse options." >&2
  exit 1
fi
eval set -- "$OPTS"

while true; do
  case "$1" in
    -e|--env)
      ENV_FILE="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1" >&2
      exit 1
      ;;
  esac
done

# Positional args after options
COMMAND="$1"
PORT="$2"
HOST="${3:-0.0.0.0}"

if [ -n "$ENV_FILE" ]; then
  if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    . "$ENV_FILE"
  else
    echo "Environment file '$ENV_FILE' not found."
    exit 1
  fi
fi

if [ "$COMMAND" != "run" ]; then
  echo "Unsupported command: $COMMAND"
  echo "Usage: $0 run PORT [HOST] [-e|--env ENV_FILE]"
  exit 1
fi

if [ -z "$PORT" ]; then
  echo "ERROR: PORT parameter is required"
  echo "Usage: $0 run PORT [HOST] [-e|--env ENV_FILE]"
  exit 1
fi

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