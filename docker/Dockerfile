FROM alpine:latest

# Install packages needed for build
RUN apk add --no-cache nginx npm uv python3 chromium tzdata

# Set timezone data
ENV TZ=UTC

RUN mkdir -p /root/mcp_servers
WORKDIR /root/mcp_servers

# Copy files first
COPY package*.json ./
COPY tsconfig.json ./
# Install dependencies
RUN npm install
# Then copy source code
COPY src/ ./src/
# Copy 3rd party npm MCP servers

## Archimedes Crypto Excel MCP Reader Server
COPY 3rdparty/excel-reader-mcp ./src/ac-excel

# Install main packages
WORKDIR /root/mcp_servers
# Install dependencies in source code
RUN npm install 2>&1 | tee /tmp/npm_output.log
# Install 3rd party MCP servers

## Archimedes Crypto Excel MCP Reader Server
WORKDIR /root/mcp_servers/src/ac-excel
RUN npm install && npm run build | tee /tmp/npm_output2.log

# Check for vulnerabilities in the saved output
RUN if grep -q "vulnerabilities" /tmp/npm_output.log /tmp/npm_output2.log; then \
        echo "Running npm audit fix..." && \
        npm audit fix; \
    else \
        echo "No vulnerabilities found. Skipping audit fix."; \
    fi
# Remove the output file
RUN rm -f /tmp/npm_output.log /tmp/npm_output2.log

# Set uv tool bin directory to /usr/local/bin
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_INSTALL_DIR=/usr/local/bin

# Install mcp-proxy tool
RUN uv tool install mcp-proxy

## Haris-Musa Excel (con: no sheet colors)
WORKDIR /root/mcp_servers
COPY 3rdparty/excel-mcp-server ./src/hm-excel
WORKDIR /root/mcp_servers/src/hm-excel
RUN uv venv
RUN . .venv/bin/activate && uv pip install -e .
WORKDIR /root/mcp_servers

# Copy and set up scripts and configs
COPY scripts/docker/run-ac-excel.sh /usr/local/bin
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
COPY scripts/docker/run-hm-excel.sh /usr/local/bin
COPY scripts/docker/run-mcpunk.sh /usr/local/bin
COPY scripts/docker/run-memory.sh /usr/local/bin
COPY scripts/docker/run-postgres.sh /usr/local/bin
COPY scripts/docker/run-puppeteer.sh /usr/local/bin
COPY scripts/docker/run-redis.sh /usr/local/bin
COPY scripts/docker/run-sequential-thinking.sh /usr/local/bin
COPY scripts/docker/run-time.sh /usr/local/bin

# Make sure all scripts are executable
RUN chmod +x /usr/local/bin/run-*.sh

# Create directories for MCP servers
RUN mkdir -p /var/lib/mcp-server/memory
RUN mkdir -p /var/lib/mcp-server/mcpunk
RUN mkdir -p /var/lib/mcp-server/excel

STOPSIGNAL SIGTERM
