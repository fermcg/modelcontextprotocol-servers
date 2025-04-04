#!/bin/sh
# Run script for mcpunk server

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
  echo "[mcpunk] $*"
}

# Build mcpunk environment variables
MCPUNK_ARGS=""

# List of possible mcpunk environment variables
if [ -n "${MCP_MCPUNK_ENABLE_STDERR_LOGGING}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_ENABLE_STDERR_LOGGING \"${MCP_MCPUNK_ENABLE_STDERR_LOGGING}\""
fi

if [ -n "${MCP_MCPUNK_ENABLE_LOG_FILE}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_ENABLE_LOG_FILE \"${MCP_MCPUNK_ENABLE_LOG_FILE}\""
fi

if [ -n "${MCP_MCPUNK_LOG_FILE}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_LOG_FILE \"${MCP_MCPUNK_LOG_FILE}\""
fi

if [ -n "${MCP_MCPUNK_LOG_LEVEL}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_LOG_LEVEL \"${MCP_MCPUNK_LOG_LEVEL}\""
fi

if [ -n "${MCP_MCPUNK_DEFAULT_RESPONSE_INDENT}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_DEFAULT_RESPONSE_INDENT \"${MCP_MCPUNK_DEFAULT_RESPONSE_INDENT}\""
fi

if [ -n "${MCP_MCPUNK_INCLUDE_CHARS_IN_RESPONSE}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_INCLUDE_CHARS_IN_RESPONSE \"${MCP_MCPUNK_INCLUDE_CHARS_IN_RESPONSE}\""
fi

if [ -n "${MCP_MCPUNK_DEFAULT_RESPONSE_MAX_CHARS}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_DEFAULT_RESPONSE_MAX_CHARS \"${MCP_MCPUNK_DEFAULT_RESPONSE_MAX_CHARS}\""
fi

if [ -n "${MCP_MCPUNK_DEFAULT_GIT_DIFF_RESPONSE_MAX_CHARS}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_DEFAULT_GIT_DIFF_RESPONSE_MAX_CHARS \"${MCP_MCPUNK_DEFAULT_GIT_DIFF_RESPONSE_MAX_CHARS}\""
fi

if [ -n "${MCP_MCPUNK_FILE_WATCH_REFRESH_FREQ_SECONDS}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_FILE_WATCH_REFRESH_FREQ_SECONDS \"${MCP_MCPUNK_FILE_WATCH_REFRESH_FREQ_SECONDS}\""
fi

if [ -n "${MCP_MCPUNK_MAX_CHUNK_SIZE}" ]; then
  MCPUNK_ARGS="$MCPUNK_ARGS --env MCPUNK_MAX_CHUNK_SIZE \"${MCP_MCPUNK_MAX_CHUNK_SIZE}\""
fi

log "Starting mcpunk server on port ${PORT}..."
exec mcp-proxy --sse-port "${PORT}" --sse-host "${HOST}" \
  ${MCPUNK_ARGS} \
  --env NODE_ENV "production" \
  -- uvx mcpunk