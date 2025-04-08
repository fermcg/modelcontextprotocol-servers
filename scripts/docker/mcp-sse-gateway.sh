#!/bin/bash

DEFAULT_SETTINGS="$HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json"
GATEWAY_CONFIG="$HOME/.mcp-sse-gateway/gateway.yaml"
PID_DIR="/tmp"

show_usage() {
  cat <<EOF
Usage:

mcp-sse-gateway.sh command <servers> [options]

Commands

run      (Run server or list of servers)
start    (Starts a server or a list of servers in daemonized mode)
stop     (Stops a server or a list of servers in daemonized mode)
restart  (Restarts a server or a list of servers in daemonized mode)
status   (Lists servers and their status)

       - Running
       - Stopped
       - Disabled

-s --settings: path to mcp settings file
      Default: \$HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json
EOF
}

SETTINGS_FILE="$DEFAULT_SETTINGS"

OPTS=$(getopt -o s: -l settings: -- "$@")
if [ $? != 0 ]; then
  show_usage
  exit 1
fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -s|--settings)
      SETTINGS_FILE="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      show_usage
      exit 1
      ;;
  esac
done

if [ $# -lt 1 ]; then
  show_usage
  exit 1
fi

COMMAND="$1"
shift
SERVERS="$*"

load_gateway_config() {
  if [ ! -f "$GATEWAY_CONFIG" ]; then
    echo "Gateway config $GATEWAY_CONFIG not found."
    exit 1
  fi

  ALL_SERVERS=""
  ENABLED_SERVERS=""
  DISABLED_SERVERS=""

  current_srv=""
  disabled="false"

  while IFS= read -r line; do
    case "$line" in
      \ \ -\ *:)
        current_srv=$(echo "$line" | sed 's/  - \(.*\):/\1/')
        disabled="false"
        ;;
      *disabled:*)
        disabled_val=$(echo "$line" | awk '{print $2}')
        if [ "$disabled_val" = "true" ]; then
          disabled="true"
        fi
        if [ -n "$current_srv" ]; then
          ALL_SERVERS="$ALL_SERVERS $current_srv"
          if [ "$disabled" = "false" ]; then
            ENABLED_SERVERS="$ENABLED_SERVERS $current_srv"
          else
            DISABLED_SERVERS="$DISABLED_SERVERS $current_srv"
          fi
          current_srv=""
        fi
        ;;
    esac
  done < "$GATEWAY_CONFIG"

  export ALL_SERVERS
  export ENABLED_SERVERS
  export DISABLED_SERVERS
}

status_servers() {
  for srv in $ALL_SERVERS; do
    pidfile="$PID_DIR/mcp-sse-$srv.pid"
    if echo "$DISABLED_SERVERS" | grep -qw "$srv"; then
      disabled="true"
    else
      disabled="false"
    fi
    if [ "$disabled" = "true" ]; then
      echo "$srv: Disabled"
    else
      # Try to detect running process via ps and grep
      # Match the command line: mcp-sse-gateway.sh run <server>
      pid=$(ps aux | grep "[m]cp-sse-gateway.sh run $srv" | awk '{print $2}')
      if [ -n "$pid" ]; then
        echo "$srv: Running (PID $pid)"
      elif [ -f "$pidfile" ]; then
        # Fallback to PID file check
        pid_from_file=$(cat "$pidfile")
        if kill -0 "$pid_from_file" 2>/dev/null; then
          echo "$srv: Running (PID $pid_from_file)"
        else
          echo "$srv: Stopped (stale PID file)"
        fi
      else
        echo "$srv: Stopped"
      fi
    fi
  done
}

start_servers() {
  for srv in $@; do
    pidfile="$PID_DIR/mcp-sse-$srv.pid"
    disabled=$(grep -A5 "  - $srv:" "$GATEWAY_CONFIG" | grep 'disabled:' | awk '{print $2}')
    if [ "$disabled" = "true" ]; then
      echo "[start] $srv is disabled, skipping."
      continue
    fi
    if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
      echo "[start] $srv already running with PID $(cat "$pidfile")."
      continue
    fi
    echo "[start] Starting $srv..."
    nohup mcp-sse-gateway.sh run "$srv" > "/tmp/mcp-sse-$srv.log" 2>&1 &
    pid=$!
    echo $pid > "$pidfile"
    # Optional: verify process started
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
      echo "[start] $srv started successfully with PID $pid."
    else
      echo "[start] Failed to start $srv. Removing stale PID file."
      rm -f "$pidfile"
    fi
  done
}

stop_servers() {
  for srv in $@; do
    pidfile="$PID_DIR/mcp-sse-$srv.pid"
    if [ -f "$pidfile" ]; then
      pid=$(cat "$pidfile")
      if kill -0 "$pid" 2>/dev/null; then
        echo "[stop] Stopping $srv (PID $pid)..."
        kill "$pid"
        # Wait for process to terminate
        count=0
        while [ $count -lt 10 ]; do
          if kill -0 "$pid" 2>/dev/null; then
            sleep 0.5
          else
            break
          fi
          count=$((count + 1))
        done
        if kill -0 "$pid" 2>/dev/null; then
          echo "[stop] $srv did not terminate gracefully, sending SIGKILL."
          kill -9 "$pid"
        fi
        rm -f "$pidfile"
        echo "[stop] $srv stopped."
      else
        echo "[stop] $srv not running, removing stale PID file."
        rm -f "$pidfile"
      fi
    else
      echo "[stop] $srv is not running."
    fi
  done
}

load_gateway_config

case "$COMMAND" in
  status)
    status_servers
    ;;
  start)
    if [ -z "$SERVERS" ] || [ "$SERVERS" = "all" ]; then
      start_servers $ENABLED_SERVERS
    else
      start_servers $SERVERS
    fi
    ;;
  stop)
    if [ -z "$SERVERS" ] || [ "$SERVERS" = "all" ]; then
      stop_servers $ENABLED_SERVERS
    else
      stop_servers $SERVERS
    fi
    ;;
  restart)
    if [ -z "$SERVERS" ] || [ "$SERVERS" = "all" ]; then
      stop_servers $ENABLED_SERVERS
      start_servers $ENABLED_SERVERS
    else
      stop_servers $SERVERS
      start_servers $SERVERS
    fi
    ;;
  run)
    # Debug: log environment and cwd for diagnosis
    for srv in $SERVERS; do
      debug_log="/tmp/mcp-sse-debug-$srv.log"
      {
        echo "==== Debug info for $srv at $(date) ===="
        echo "PWD: $(pwd)"
        echo "User: $(whoami)"
        echo "Environment:"
        env | sort
        echo "==== End debug info ===="
      } > "$debug_log" 2>&1 &
    done

    if [ -z "$SERVERS" ]; then
      SRVS="$ENABLED_SERVERS"
    else
      # Filter SERVERS to include only valid server names from $ENABLED_SERVERS and ignore extras like ports
      FILTERED_SERVERS=""
      for s in $SERVERS; do
        if echo "$ENABLED_SERVERS" | grep -qw "$s"; then
          FILTERED_SERVERS="$FILTERED_SERVERS $s"
        fi
      done
      SRVS="$FILTERED_SERVERS"
    fi

    for srv in $SRVS; do
      # Extract sse-port
      port=$(yq -r '.["mcp-servers"][] | select(has("'"$srv"'")) | .["'"$srv"'"][] | select(has("sse-port")) | ."sse-port"' "$GATEWAY_CONFIG")

      # Extract command
      cmd=$(yq -r '.["mcp-servers"][] | select(has("'"$srv"'")) | .["'"$srv"'"][] | select(has("command")) | ."command"' "$GATEWAY_CONFIG")

      # Extract command-args as space-separated string
      args=$(yq -r '.["mcp-servers"][] | select(has("'"$srv"'")) | .["'"$srv"'"][] | select(has("command-args")) | ."command-args"[]' "$GATEWAY_CONFIG" | xargs)

      # Extract env-file
      envfile=$(yq -r '.["mcp-servers"][] | select(has("'"$srv"'")) | .["'"$srv"'"][] | select(has("env-file")) | ."env-file"' "$GATEWAY_CONFIG")

      # Source env-file if exists
      if [ -n "$envfile" ] && [ -f "$envfile" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
          # Skip comments and empty lines
          case "$line" in
            ''|\#*) continue ;;
          esac
          # Export KEY=VALUE
          export "$line"
        done < "$envfile"
      fi

      # Extract inline env vars and export them
      eval "$(yq -r '
        .["mcp-servers"][] | select(has("'"$srv"'")) | .["'"$srv"'"][] | select(has("env")) | .env // {} |
        to_entries | .[] | "export \(.key)=\(.value)"' "$GATEWAY_CONFIG")"

      echo "Running server: $srv"
      echo "Proxy on port: $port"
      echo "Command: $cmd $args"

      # If this is the last server, exec it; else, run in background and wait
      # Prepare --env flags for mcp-proxy
      MCP_PROXY_ENVS=""
      if [ -n "$BRAVE_API_KEY" ]; then
          MCP_PROXY_ENVS="$MCP_PROXY_ENVS --env BRAVE_API_KEY $BRAVE_API_KEY"
      fi

      if [ "$srv" = "$(echo $SRVS | awk '{print $NF}')" ]; then
          # Debug before exec
          # echo "[DEBUG] Environment before exec:"
          # env | sort
          exec mcp-proxy --sse-port "$port" --sse-host 0.0.0.0 $MCP_PROXY_ENVS -- $cmd $args
      else
          # echo "[DEBUG] Environment before background run:"
          # env | sort
          echo "[DEBUG] Background command: mcp-proxy --sse-port $port --sse-host 0.0.0.0 $MCP_PROXY_ENVS -- $cmd $args"
          (mcp-proxy --sse-port "$port" --sse-host 0.0.0.0 $MCP_PROXY_ENVS -- $cmd $args) &
          wait $!
      fi
    done
    ;;
  *)
    echo "Command $COMMAND not implemented yet."
    ;;
esac