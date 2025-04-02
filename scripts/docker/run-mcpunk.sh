#!/bin/sh
# Run script for mcpunk server

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