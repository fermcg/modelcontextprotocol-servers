# MCP Servers Backlog

## Environment Variable Mapping for MCP Proxy Architecture
> Note: Made obsolete by [Dynamic Container Startup for MCP Servers With Route-Based Orchestration](#dynamic-container-startup-for-mcp-servers-with-route-based-orchestration)
### Issue
When using the mcp-proxy to start servers in STDIO transport mode in the Docker container, there's a mismatch between environment variable naming conventions:

1. **Client-side configuration** (e.g., Cursor's mcp.json):
   - Uses unprefixed variables like `BRAVE_API_KEY`, `POSTGRES_CONNECTION_STRING`, etc.
   - Maps these variables directly to the tool parameters via the client

2. **Docker container environment**:
   - Uses MCP_-prefixed variables (e.g., `MCP_BRAVE_API_KEY`, `MCP_POSTGRES_CONNECTION_STRING`)
   - The entrypoint.sh script expects these prefixed variables but must pass unprefixed values to mcp-proxy

3. **Command-line parameters vs. environment variables**:
   - Some servers (like postgres) expect connection strings as command-line parameters
   - Others expect environment variables through mcp-proxy's --env flag

This causes servers to fail to start when variables aren't properly mapped between these different contexts.

### Current Workaround
Manually define environment variables in .env files or docker-compose.yml with the expected MCP_ prefix.

### Proposed Solutions

1. **Client-aware wrapper**:
   - Create a wrapper script that gets variables from the client configuration
   - Start private instances of each server for that specific client
   - Handle the variable name translation between client format and server expectations

2. **Standardized environment approach**:
   - Modify entrypoint.sh to accept either prefixed or unprefixed variables
   - Implement automatic variable mapping in the container startup

3. **Configuration mapping layer**:
   - Add a configuration layer that maps between client configurations and server expectations
   - Support multiple naming conventions through aliases

4. **Dynamic Container Startup for MCP Servers with Route-Based Orchestration**
   - Our current choice.
   - Detailed at [Dynamic Container Startup for MCP Servers with Route-Based Orchestration](#dynamic-container-startup-for-mcp-servers-with-route-based-orchestration)
   - Solves all the problems related on [Environment Variable Mapping for MCP Proxy Architecture](#environment-variable-mapping-for-mcp-proxy-architecture)

### Impact
This issue affects the ease of deployment and usage of MCP servers in containerized environments, especially when integrating with existing client configurations like Cursor.

### Priority
Medium - The system works with proper environment configuration, but usability could be improved.

## Dynamic Container Startup for MCP Servers with Route-Based Orchestration

### Summary
Analyze and implement a system where MCP server containers start only when a specific path is accessed via a routing NGINX server. Compare resource usage (disk space, CPU, memory) between this approach and the current single-image multi-process setup. Use multi-stage Docker builds (Alpine-based base, shared setup, Python/Node-specific setups, and runtime images) to optimize images. Evaluate NGINX or alternatives (e.g., Kubernetes, Docker Swarm) for route-based orchestration to potentially reduce resource consumption compared to the monolith.

### Key Points
- **Goal:** Start containers on-demand based on route demands to save resources.
- **Challenges:** Cold start latency, orchestration complexity, health checks.
- **Tools:** NGINX (reverse proxy), possibly Kubernetes/Docker Swarm for scaling.
- **Docker Strategy:** Multi-stage builds with shared base, language-specific stages, and minimal runtime images.
- **Comparison:** Multiple containers should offer better isolation and scalability than the current monolith, potentially using fewer resources when idle.

### Priority
High - Could significantly improve resource efficiency and scalability.
