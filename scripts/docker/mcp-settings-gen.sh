#!/bin/bash

# mcp-settings-gen.sh
# Generate RooCode-compatible MCP server settings JSON from gateway.yaml
# Usage: ./mcp-settings-gen.sh [output_path]
# Default output path:
#   \$HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json

set -euo pipefail

GATEWAY_YAML="\$HOME/.mcp-sse-gateway/gateway.yaml"
DEFAULT_OUTPUT_PATH="\$HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json"
OUTPUT_PATH="\${1:-\$DEFAULT_OUTPUT_PATH}"

# Check dependencies
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: 'yq' is required but not installed. Please install yq (https://mikefarah.gitbook.io/yq/)." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required but not installed. Please install jq (https://stedolan.github.io/jq/)." >&2
  exit 1
fi

if [ ! -f "\$GATEWAY_YAML" ]; then
  echo "Error: Gateway YAML config not found at \$GATEWAY_YAML" >&2
  exit 1
fi

# Parse YAML and generate JSON
# Assumes servers are under 'servers' key, adjust as needed
JSON_CONTENT=\$(yq -o=json '.servers' "\$GATEWAY_YAML" | jq 'to_entries | map({
  name: .key,
  port: (.value.port // null),
  command: (.value.command // null),
  disabled: (.value.disabled // false)
})')

# Wrap in RooCode-compatible structure
FINAL_JSON=\$(jq -n --argjson servers "\$JSON_CONTENT" '{servers: \$servers}')

# Create output directory if it doesn't exist
mkdir -p "\$(dirname "\$OUTPUT_PATH")"

# Write JSON to output path
echo "\$FINAL_JSON" | jq '.' > "\$OUTPUT_PATH"

echo "MCP settings generated at \$OUTPUT_PATH"