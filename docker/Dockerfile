FROM alpine:latest

# Install packages needed for build
RUN apk add --no-cache nginx npm uv python3 chromium tzdata

# Set timezone data
ENV TZ=UTC
# Set uv tool bin directory to /usr/local/bin
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_INSTALL_DIR=/usr/local/bin

# Install mcp-proxy tool
RUN uv tool install mcp-proxy

RUN mkdir -p /root/mcp_servers
WORKDIR /root/mcp_servers

# Copy files first
COPY package*.json ./
COPY tsconfig.json ./
# Install dependencies
RUN npm install
# Then copy source code
COPY src/ ./src/
# Install dependencies in source code
RUN npm install 2>&1 | tee /tmp/npm_output.log
# Check for vulnerabilities in the saved output
RUN if grep -q "vulnerabilities" /tmp/npm_output.log; then \
        echo "Running npm audit fix..." && \
        npm audit fix; \
    else \
        echo "No vulnerabilities found. Skipping audit fix."; \
    fi
# Remove the output file
RUN rm -f /tmp/npm_output.log

# Set up uv tool directories for mcp-proxy 
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_INSTALL_DIR=/usr/local/bin

# Install mcp-proxy in runtime stage
RUN uv tool install mcp-proxy

# nginx config
#RUN mkdir -p /etc/nginx
# Forcefully replace the default nginx.conf
#RUN rm -f /etc/nginx/nginx.conf
#COPY docker/cfg/nginx.conf /etc/nginx/

# Copy and set up scripts and configs
COPY scripts/docker/run-brave-search.sh /usr/local/bin
COPY scripts/docker/run-context7.sh /usr/local/bin
COPY scripts/docker/run-everart.sh /usr/local/bin
COPY scripts/docker/run-fetch.sh /usr/local/bin
COPY scripts/docker/run-filesystem.sh /usr/local/bin
COPY scripts/docker/run-gdrive.sh /usr/local/bin
COPY scripts/docker/run-github.sh /usr/local/bin
COPY scripts/docker/run-gitlab.sh /usr/local/bin
COPY scripts/docker/run-git.sh /usr/local/bin
COPY scripts/docker/run-google-maps.sh /usr/local/bin
COPY scripts/docker/run-mcpunk.sh /usr/local/bin
COPY scripts/docker/run-memory.sh /usr/local/bin
COPY scripts/docker/run-postgres.sh /usr/local/bin
COPY scripts/docker/run-puppeteer.sh /usr/local/bin
COPY scripts/docker/run-redis.sh /usr/local/bin
COPY scripts/docker/run-sequential-thinking.sh /usr/local/bin
COPY scripts/docker/run-time.sh /usr/local/bin

# Create directories for MCP servers
RUN mkdir -p /var/lib/mcp-server/memory
RUN mkdir -p /var/lib/mcp-server/mcpunk

STOPSIGNAL SIGTERM
