#!/bin/sh

set -e

# This script runs an nginx reverse proxy to route /fetch to the fetch MCP server SSE endpoint.

# Configurable ports
ROUTER_PORT=8109
FETCH_SERVER_PORT=8201

# Create a temporary nginx config file
NGINX_CONF=$(mktemp /tmp/nginx-mcp-router.XXXX.conf)

cat > "$NGINX_CONF" <<EOF
events {}

http {
    server {
        listen ${ROUTER_PORT};

        location /fetch {
            proxy_pass http://localhost:${FETCH_SERVER_PORT}/sse;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        location /messages/ {
            proxy_pass http://localhost:${FETCH_SERVER_PORT}/messages/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

echo "[nginx-mcp-router] Starting nginx reverse proxy on port ${ROUTER_PORT}, forwarding /fetch to fetch MCP server SSE endpoint on port ${FETCH_SERVER_PORT}..."

docker run \
    --name nginx-mcp-router \
    --network=host \
    -v "$NGINX_CONF":/etc/nginx/nginx.conf:ro \
    nginx:alpine

echo "[nginx-mcp-router] Nginx reverse proxy is running."