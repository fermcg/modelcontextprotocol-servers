#!/bin/sh
# This script starts all Node MCP servers defined in Dockerfile.node using mcp-proxy
# IMPORTANT: Verify the actual <server_start_command> for each server below.

set -e

export DOCKER_CONTAINER=true

# Define log function at the beginning
log() {
  echo "[Entrypoint] $*" 
}

# Add to entrypoint.sh
start_service() {
  log "Starting $1 server..."
  eval "$2 &"
  # Optional: add a small sleep to stagger startups
  sleep 0.5
}

# Default all to disabled if arguments are provided
if [ "$#" -gt 0 ]; then
  log "Received arguments: $@"
  log "Starting only specified servers..."
  MCP_ENABLE_ALL_SERVERS=false # Override if args are present
  MCP_BRAVE_SEARCH_ENABLED=false
  MCP_EVERART_ENABLED=false
  MCP_EVERYTHING_ENABLED=false
  MCP_FETCH_ENABLED=false
  MCP_FILESYSTEM_ENABLED=false
  MCP_GDRIVE_ENABLED=false
  MCP_GIT_ENABLED=false
  MCP_GITHUB_ENABLED=false
  MCP_GITLAB_ENABLED=false
  MCP_GOOGLE_MAPS_ENABLED=false
  MCP_MEMORY_ENABLED=false
  MCP_POSTGRES_ENABLED=false
  MCP_PUPPETEER_ENABLED=false
  MCP_REDIS_ENABLED=false
  MCP_SEQUENTIAL_THINKING_ENABLED=false
  MCP_TIME_ENABLED=false
  MCP_MCPUNK_ENABLED=false

  # Enable servers based on arguments
  for server_name in "$@"; do
    case "$server_name" in
      brave-search) MCP_BRAVE_SEARCH_ENABLED=true ;;
      everart) MCP_EVERART_ENABLED=true ;;
      fetch) MCP_FETCH_ENABLED=true ;;
      filesystem) MCP_FILESYSTEM_ENABLED=true ;;
      gdrive) MCP_GDRIVE_ENABLED=true ;;
      git) MCP_GIT_ENABLED=true ;;
      github) MCP_GITHUB_ENABLED=true ;;
      gitlab) MCP_GITLAB_ENABLED=true ;;
      google-maps) MCP_GOOGLE_MAPS_ENABLED=true ;;
      memory) MCP_MEMORY_ENABLED=true ;;
      postgres) MCP_POSTGRES_ENABLED=true ;;
      puppeteer) MCP_PUPPETEER_ENABLED=true ;;
      redis) MCP_REDIS_ENABLED=true ;;
      sequential-thinking) MCP_SEQUENTIAL_THINKING_ENABLED=true ;;
      time) MCP_TIME_ENABLED=true ;;
      mcpunk) MCP_MCPUNK_ENABLED=true ;;
      *) log "Warning: Unknown server name '$server_name' provided as argument." ;;
    esac
  done
else
  log "No arguments provided. Starting servers based on environment variables (MCP_ENABLE_ALL_SERVERS or individual MCP_*_ENABLED)."
fi

# Log all environment variables that are inputs to this script
if [ "$MCP_ENV_DEBUG" = "true" ]; then
  log "Environment variables configuration:"
  log "- MCP_ENABLE_ALL_SERVERS: ${MCP_ENABLE_ALL_SERVERS:-not set}"
  log "- MCP_BRAVE_SEARCH_ENABLED: ${MCP_BRAVE_SEARCH_ENABLED:-not set}"
  log "- MCP_BRAVE_API_KEY: ${MCP_BRAVE_API_KEY:+set (value hidden)}"
  log "- MCP_EVERART_ENABLED: ${MCP_EVERART_ENABLED:-not set}"
  log "- MCP_EVERART_API_KEY: ${MCP_EVERART_API_KEY:+set (value hidden)}"
  log "- MCP_EVERYTHING_ENABLED: ${MCP_EVERYTHING_ENABLED:-not set}"
  log "- MCP_FETCH_ENABLED: ${MCP_FETCH_ENABLED:-not set}"
  log "- MCP_FILESYSTEM_ENABLED: ${MCP_FILESYSTEM_ENABLED:-not set}"
  log "- MCP_FILESYSTEM_DIR_LIST: ${MCP_FILESYSTEM_DIR_LIST:-not set}"
  log "- MCP_GDRIVE_ENABLED: ${MCP_GDRIVE_ENABLED:-not set}"
  log "- MCP_GDRIVE_CREDENTIALS_PATH: ${MCP_GDRIVE_CREDENTIALS_PATH:-not set}"
  log "- MCP_GDRIVE_PATH: ${MCP_GDRIVE_PATH:-not set}"
  log "- MCP_GIT_ENABLED: ${MCP_GIT_ENABLED:-not set}"
  log "- MCP_GIT_REPOSITORY_PATH: ${MCP_GIT_REPOSITORY_PATH:-not set}"
  log "- MCP_GITHUB_ENABLED: ${MCP_GITHUB_ENABLED:-not set}"
  log "- MCP_GITHUB_PERSONAL_ACCESS_TOKEN: ${MCP_GITHUB_PERSONAL_ACCESS_TOKEN:+set (value hidden)}"
  log "- MCP_GITLAB_ENABLED: ${MCP_GITLAB_ENABLED:-not set}"
  log "- MCP_GITLAB_PERSONAL_ACCESS_TOKEN: ${MCP_GITLAB_PERSONAL_ACCESS_TOKEN:+set (value hidden)}"
  log "- MCP_GITLAB_API_URL: ${MCP_GITLAB_API_URL:-not set}"
  log "- MCP_GOOGLE_MAPS_ENABLED: ${MCP_GOOGLE_MAPS_ENABLED:-not set}"
  log "- MCP_GOOGLE_MAPS_API_KEY: ${MCP_GOOGLE_MAPS_API_KEY:+set (value hidden)}"
  log "- MCP_MEMORY_ENABLED: ${MCP_MEMORY_ENABLED:-not set}"
  log "- MCP_MEMORY_FILE_PATH: ${MCP_MEMORY_FILE_PATH:-not set}"
  log "- MCP_POSTGRES_ENABLED: ${MCP_POSTGRES_ENABLED:-not set}"
  log "- MCP_POSTGRES_CONNECTION_STRING: ${MCP_POSTGRES_CONNECTION_STRING:+set (value hidden)}"
  log "- MCP_PUPPETEER_ENABLED: ${MCP_PUPPETEER_ENABLED:-not set}"
  log "- MCP_PUPPETEER_LAUNCH_OPTIONS: ${MCP_PUPPETEER_LAUNCH_OPTIONS:-not set}"
  log "- MCP_PUPPETEER_ALLOW_DANGEROUS: ${MCP_PUPPETEER_ALLOW_DANGEROUS:-not set}"
  log "- MCP_REDIS_ENABLED: ${MCP_REDIS_ENABLED:-not set}"
  log "- MCP_REDIS_CONNECTION_STRING: ${MCP_REDIS_CONNECTION_STRING:+set (value hidden)}"
  log "- MCP_SEQUENTIAL_THINKING_ENABLED: ${MCP_SEQUENTIAL_THINKING_ENABLED:-not set}"
  log "- MCP_TIME_ENABLED: ${MCP_TIME_ENABLED:-not set}"
  log "- MCP_TIME_LOCAL_TIMEZONE: ${MCP_TIME_LOCAL_TIMEZONE:-not set}"
fi

# Set all servers to enabled by default if MCP_ENABLE_ALL_SERVERS is true
if [ "$MCP_ENABLE_ALL_SERVERS" = "true" ]; then
  log "Enabling all servers..."
  MCP_BRAVE_SEARCH_ENABLED=true
  MCP_EVERART_ENABLED=true
  MCP_EVERYTHING_ENABLED=true
  MCP_FETCH_ENABLED=true
  MCP_FILESYSTEM_ENABLED=true
  MCP_GDRIVE_ENABLED=true
  MCP_GIT_ENABLED=true
  MCP_GITHUB_ENABLED=true
  MCP_GITLAB_ENABLED=true
  MCP_GOOGLE_MAPS_ENABLED=true
  MCP_MEMORY_ENABLED=true
  MCP_POSTGRES_ENABLED=true
  MCP_PUPPETEER_ENABLED=true
  MCP_REDIS_ENABLED=true
  MCP_SEQUENTIAL_THINKING_ENABLED=true
  MCP_TIME_ENABLED=true
  MCP_MCPUNK_ENABLED=true
fi

# Brave Search MCP server
if [ "$MCP_BRAVE_SEARCH_ENABLED" = "true" ]; then
  if [ -z "$MCP_BRAVE_API_KEY" ]; then
    log "Aborting start of brave-search server: MCP_BRAVE_API_KEY not defined"
  else
    log "Starting brave-search server on port 8201..."
    BRAVE_SEARCH_CMD="mcp-proxy --sse-port 8201 --sse-host 0.0.0.0 \
    --env BRAVE_API_KEY \"$MCP_BRAVE_API_KEY\" \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-brave-search"
    start_service "brave-search" "$BRAVE_SEARCH_CMD"
  fi
fi

# Everart MCP server
if [ "$MCP_EVERART_ENABLED" = "true" ]; then
  if [ -z "$MCP_EVERART_API_KEY" ]; then
    log "Aborting start of everart server: MCP_EVERART_API_KEY not defined"
  else
    log "Starting everart server on port 8202..."
    EVERART_CMD="mcp-proxy --sse-port 8202 --sse-host 0.0.0.0 \
    --env EVERART_API_KEY \"$MCP_EVERART_API_KEY\" \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-everart"
    start_service "everart" "$EVERART_CMD"
  fi
fi

# # Everything MCP server
# if [ "$MCP_EVERYTHING_ENABLED" = "true" ]; then
#   log "Starting everything server on port 8203..."
#   EVERYTHING_CMD="mcp-proxy --sse-port 8203 --sse-host 0.0.0.0 \
#   --env NODE_ENV \"production\" \
#   -- npx -y @modelcontextprotocol/server-everything"
#   start_service "everything" "$EVERYTHING_CMD"
# fi

# Fetch MCP server
if [ "$MCP_FETCH_ENABLED" = "true" ]; then
  log "Starting fetch server on port 8204..."
  FETCH_CMD="mcp-proxy --sse-port 8204 --sse-host 0.0.0.0 \
  -- uvx mcp-server-fetch"
  start_service "fetch" "$FETCH_CMD"
fi

# Filesystem MCP server
if [ "$MCP_FILESYSTEM_ENABLED" = "true" ]; then
  log "Starting filesystem server on port 8205..."

  FILESYSTEM_CMD="mcp-proxy --sse-port 8205 --sse-host 0.0.0.0"
  FILESYSTEM_CMD="$FILESYSTEM_CMD --env NODE_ENV \"production\""
  FILESYSTEM_CMD="$FILESYSTEM_CMD -- npx -y @modelcontextprotocol/server-filesystem"
  if [ -z "$MCP_FILESYSTEM_DIR_LIST" ]; then
    FILESYSTEM_CMD="$FILESYSTEM_CMD /tmp"
  else
    # Process directories without losing variable changes
    DIRS_ARG=""
    for dir in $(echo "$MCP_FILESYSTEM_DIR_LIST" | tr '|' ' '); do
      DIRS_ARG="$DIRS_ARG \"$dir\""
    done
    FILESYSTEM_CMD="$FILESYSTEM_CMD $DIRS_ARG"
  fi
  start_service "filesystem" "$FILESYSTEM_CMD"
fi

# GDrive MCP server
if [ "$MCP_GDRIVE_ENABLED" = "true" ]; then
  if [ -z "$MCP_GDRIVE_CREDENTIALS_PATH" ] || [ -z "$MCP_GDRIVE_PATH" ]; then
    log "Aborting start of gdrive server: MCP_GDRIVE_CREDENTIALS_PATH or MCP_GDRIVE_PATH not defined"
  else
    log "Starting gdrive server on port 8206..."
    GDRIVE_CMD="mcp-proxy --sse-port 8206 --sse-host 0.0.0.0 \
    --env GDRIVE_CREDENTIALS_PATH \"$MCP_GDRIVE_CREDENTIALS_PATH\" \
    --env GDRIVE_PATH \"$MCP_GDRIVE_PATH\" \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-gdrive"
    start_service "gdrive" "$GDRIVE_CMD"
  fi
fi

# Git MCP server
if [ "$MCP_GIT_ENABLED" = "true" ]; then
  if [ -z "$MCP_GIT_REPOSITORY_PATH" ]; then
    log "Aborting start of git server: MCP_GIT_REPOSITORY_PATH not defined"
  else
    log "Starting git server on port 8207..."
    GIT_CMD="mcp-proxy --sse-port 8207 --sse-host 0.0.0.0 \
    -- uvx mcp-server-git --repository \"$MCP_GIT_REPOSITORY_PATH\""
    start_service "git" "$GIT_CMD"
  fi
fi

# Github MCP server
if [ "$MCP_GITHUB_ENABLED" = "true" ]; then
  if [ -z "$MCP_GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    log "Aborting start of github server: MCP_GITHUB_PERSONAL_ACCESS_TOKEN not defined"
  else
    log "Starting github server on port 8208..."
    GITHUB_CMD="mcp-proxy --sse-port 8208 --sse-host 0.0.0.0 \
    --env GITHUB_PERSONAL_ACCESS_TOKEN \"$MCP_GITHUB_PERSONAL_ACCESS_TOKEN\" \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-github"
    start_service "github" "$GITHUB_CMD"
  fi
fi

# Gitlab MCP server
if [ "$MCP_GITLAB_ENABLED" = "true" ]; then
  if [ -z "$MCP_GITLAB_PERSONAL_ACCESS_TOKEN" ] || [ -z "$MCP_GITLAB_API_URL" ]; then
    log "Aborting start of gitlab server: MCP_GITLAB_PERSONAL_ACCESS_TOKEN or MCP_GITLAB_API_URL not defined"
  else
    log "Starting gitlab server on port 8209..."
    GITLAB_CMD="mcp-proxy --sse-port 8209 --sse-host 0.0.0.0 \
    --env GITLAB_PERSONAL_ACCESS_TOKEN \"$MCP_GITLAB_PERSONAL_ACCESS_TOKEN\" \
    --env GITLAB_API_URL \"$MCP_GITLAB_API_URL\" \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-gitlab"
    start_service "gitlab" "$GITLAB_CMD"
  fi
fi

# Google Maps MCP server
if [ "$MCP_GOOGLE_MAPS_ENABLED" = "true" ]; then
  if [ -z "$MCP_GOOGLE_MAPS_API_KEY" ]; then
    log "Aborting start of google-maps server: MCP_GOOGLE_MAPS_API_KEY not defined"
  else
    log "Starting google-maps server on port 8210..."
    GOOGLE_MAPS_CMD="mcp-proxy --sse-port 8210 --sse-host 0.0.0.0 \
    --env GOOGLE_MAPS_API_KEY \"$MCP_GOOGLE_MAPS_API_KEY\" \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-google-maps"
    start_service "google-maps" "$GOOGLE_MAPS_CMD"
  fi
fi

# Memory MCP server
if [ "$MCP_MEMORY_ENABLED" = "true" ]; then
  log "Starting memory server on port 8211..."
  
  # Build command with only defined environment variables
  MEMORY_CMD="mcp-proxy --sse-port 8211 --sse-host 0.0.0.0"
  
  # Add optional environment variables only if defined
  if [ ! -z "$MCP_MEMORY_FILE_PATH" ]; then
    MEMORY_CMD="$MEMORY_CMD --env MEMORY_FILE_PATH \"$MCP_MEMORY_FILE_PATH\""
  fi
  MEMORY_CMD="$MEMORY_CMD --env NODE_ENV \"production\""
  
  # Complete and execute the command
  MEMORY_CMD="$MEMORY_CMD -- npx -y @modelcontextprotocol/server-memory"
  start_service "memory" "$MEMORY_CMD"
fi

# Postgres MCP server
if [ "$MCP_POSTGRES_ENABLED" = "true" ]; then
  if [ -z "$MCP_POSTGRES_CONNECTION_STRING" ]; then
    log "Aborting start of postgres server: MCP_POSTGRES_CONNECTION_STRING not defined"
  else
    log "Starting postgres server on port 8212..."
    POSTGRES_CMD="mcp-proxy --sse-port 8212 --sse-host 0.0.0.0 \
    --env NODE_ENV \"production\" \
    -- npx -y @modelcontextprotocol/server-postgres \"$MCP_POSTGRES_CONNECTION_STRING\""
    start_service "postgres" "$POSTGRES_CMD"
  fi
fi

# Puppeteer MCP server
if [ "$MCP_PUPPETEER_ENABLED" = "true" ]; then
  log "Starting puppeteer server on port 8213..."
  
  # Build command with only defined environment variables
  PUPPETEER_CMD="mcp-proxy --sse-port 8213 --sse-host 0.0.0.0"
  
  # Always set these defaults
  PUPPETEER_CMD="$PUPPETEER_CMD --env PUPPETEER_SKIP_CHROMIUM_DOWNLOAD \"true\""
  PUPPETEER_CMD="$PUPPETEER_CMD --env PUPPETEER_EXECUTABLE_PATH \"/usr/bin/chromium\""
  PUPPETEER_CMD="$PUPPETEER_CMD --env NODE_ENV \"production\""
  
  # Add optional environment variables only if defined
  if [ ! -z "$MCP_PUPPETEER_LAUNCH_OPTIONS" ]; then
    PUPPETEER_CMD="$PUPPETEER_CMD --env PUPPETEER_LAUNCH_OPTIONS \"$MCP_PUPPETEER_LAUNCH_OPTIONS\""
  fi
  
  if [ ! -z "$MCP_PUPPETEER_ALLOW_DANGEROUS" ]; then
    PUPPETEER_CMD="$PUPPETEER_CMD --env ALLOW_DANGEROUS \"$MCP_PUPPETEER_ALLOW_DANGEROUS\""
  fi
  
  # Complete and execute the command
  PUPPETEER_CMD="$PUPPETEER_CMD -- npx -y @modelcontextprotocol/server-puppeteer"
  start_service "puppeteer" "$PUPPETEER_CMD"
fi

# Redis MCP server
if [ "$MCP_REDIS_ENABLED" = "true" ]; then
  log "Starting redis server on port 8214..."
  
  # Build command with only defined environment variables
  REDIS_CMD="mcp-proxy --sse-port 8214 --sse-host 0.0.0.0"
  REDIS_CMD="$REDIS_CMD --env NODE_ENV \"production\""
  REDIS_CMD="$REDIS_CMD -- npx -y @modelcontextprotocol/server-redis"
  
  # Complete the command with connection string if defined
  if [ ! -z "$MCP_REDIS_CONNECTION_STRING" ]; then
    REDIS_CMD="$REDIS_CMD \"$MCP_REDIS_CONNECTION_STRING\""
  fi
  
  start_service "redis" "$REDIS_CMD"
fi

# Sequential Thinking MCP server
if [ "$MCP_SEQUENTIAL_THINKING_ENABLED" = "true" ]; then
  log "Starting sequentialthinking server on port 8215..."
  SEQUENTIAL_THINKING_CMD="mcp-proxy --sse-port 8215 --sse-host 0.0.0.0"
  SEQUENTIAL_THINKING_CMD="$SEQUENTIAL_THINKING_CMD --env NODE_ENV \"production\""
  SEQUENTIAL_THINKING_CMD="$SEQUENTIAL_THINKING_CMD -- npx -y @modelcontextprotocol/server-sequential-thinking"
  start_service "sequentialthinking" "$SEQUENTIAL_THINKING_CMD"
fi

# Time MCP server
if [ "$MCP_TIME_ENABLED" = "true" ]; then
  log "Starting time server on port 8216..."

  # Build command with only defined environment variables
  TIME_CMD="mcp-proxy --sse-port 8216 --sse-host 0.0.0.0"
  TIME_CMD="$TIME_CMD -- uvx mcp-server-time"

  # Use MCP_TIME_LOCAL_TIMEZONE if defined, otherwise fall back to system TZ
  if [ ! -z "$MCP_TIME_LOCAL_TIMEZONE" ]; then
    TIME_CMD="$TIME_CMD --local-timezone=$MCP_TIME_LOCAL_TIMEZONE"
  elif [ ! -z "$TZ" ]; then
    log "Using system timezone: $TZ"
    TIME_CMD="$TIME_CMD --local-timezone=$TZ"
  fi
  
  start_service "time" "$TIME_CMD"
fi

# MCPunk MCP server
if [ "$MCP_MCPUNK_ENABLED" = "true" ]; then
  log "Starting mcpunk server on port 8217..."
  MCPUNK_CMD="mcp-proxy --sse-port 8217 --sse-host 0.0.0.0"
  if [ ! -z "$MCP_MCPUNK_ENABLE_STDERR_LOGGING" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_ENABLE_STDERR_LOGGING \"$MCP_MCPUNK_ENABLE_STDERR_LOGGING\""
  fi
  if [ ! -z "$MCP_MCPUNK_ENABLE_LOG_FILE" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_ENABLE_LOG_FILE \"$MCP_MCPUNK_ENABLE_LOG_FILE\""
  fi
  if [ ! -z "$MCP_MCPUNK_LOG_FILE" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_LOG_FILE \"$MCP_MCPUNK_LOG_FILE\""
  fi
  if [ ! -z "$MCP_MCPUNK_LOG_LEVEL" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_LOG_LEVEL \"$MCP_MCPUNK_LOG_LEVEL\""
  fi
  if [ ! -z "$MCP_MCPUNK_DEFAULT_RESPONSE_INDENT" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_DEFAULT_RESPONSE_INDENT \"$MCP_MCPUNK_DEFAULT_RESPONSE_INDENT\""
  fi
  if [ ! -z "$MCP_MCPUNK_INCLUDE_CHARS_IN_RESPONSE" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_INCLUDE_CHARS_IN_RESPONSE \"$MCP_MCPUNK_INCLUDE_CHARS_IN_RESPONSE\""
  fi
  if [ ! -z "$MCP_MCPUNK_DEFAULT_RESPONSE_MAX_CHARS" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_DEFAULT_RESPONSE_MAX_CHARS \"$MCP_MCPUNK_DEFAULT_RESPONSE_MAX_CHARS\""
  fi
  if [ ! -z "$MCP_MCPUNK_DEFAULT_GIT_DIFF_RESPONSE_MAX_CHARS" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_DEFAULT_GIT_DIFF_RESPONSE_MAX_CHARS \"$MCP_MCPUNK_DEFAULT_GIT_DIFF_RESPONSE_MAX_CHARS\""
  fi
  if [ ! -z "$MCP_MCPUNK_FILE_WATCH_REFRESH_FREQ_SECONDS" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_FILE_WATCH_REFRESH_FREQ_SECONDS \"$MCP_MCPUNK_FILE_WATCH_REFRESH_FREQ_SECONDS\""
  fi
  if [ ! -z "$MCP_MCPUNK_MAX_CHUNK_SIZE" ]; then
    MCPUNK_CMD="$MCPUNK_CMD --env MCPUNK_MAX_CHUNK_SIZE \"$MCP_MCPUNK_MAX_CHUNK_SIZE\""
  fi
  MCPUNK_CMD="$MCPUNK_CMD --env NODE_ENV \"production\""
  MCPUNK_CMD="$MCPUNK_CMD -- uvx mcpunk"
  start_service "mcpunk" "$MCPUNK_CMD"
fi

# Add other servers as needed, incrementing port numbers

## TODO: Fix nginx path handling issue
# Start nginx in the foreground to handle routing
# log "Starting nginx router on port 8109..."
# Use -c to specify our custom config path, and -g to set daemon off directly
# nginx -c /etc/nginx/nginx.conf -g 'daemon off;' &

log "All MCP Node servers and router launched in background."

# Keep container running - prevents the container from exiting
log "Tailing /dev/null to keep container alive..."
tail -f /dev/null
