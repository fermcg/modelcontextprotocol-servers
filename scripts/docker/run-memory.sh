#!/bin/sh
# Run script for memory server

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