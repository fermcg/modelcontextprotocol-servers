#!/bin/sh
# Run script for puppeteer server

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