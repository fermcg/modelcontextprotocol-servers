# MCP SSE Servers Daemon Initial Prompt for daemonizing Tasks Using Roo

**Use boomerang tasks to do this request.**

in this project we have a docker stack serving multiple mcp servers serving in
sse mode.

The project's full path in WSL is 

/home/docker-common/modelcontextprotocol/servers

There are some scripts in scripts/docker that start mcp servers.
create a new script called mcp-sse-servers.sh

Keep it in /bin/sh - don't use bash syntax.

## Usage message

```Text
Usage:

mcp-sse-ganeway.sh command <servers> [options]

Commands

run  (Run server or list of servers)
start (Starts a server or a list of servers in daemonized mode)
stop (Stops a server or a list of servers in daemonized mode)
restart (Restarts a server or a list of servers in daemonized mode)
status (Lists servers and their status)

       - Running
       - Stopped
       - Disabled

-s --settings: path to mcp settings file
      Default: $HOME/.vscode-server/data/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json
```

The Usage Message is basically your prompt.

If there is a need to keep extra configuration besides mcp_settings.json,
you can put it in ~/.mcp-sse-gateway/gateway.yaml

Evolve it from this idea:

```Yaml
mcp-servers:
  - brave-search:
    - sse-port: 8201
    - command: npx
    - command-args: [ '-y', '@modelcontextprotocol/server-brave-search' ]
    - env:
      BRAVE_API_KEY: xyz
...
```
sse-port and command are mandatory
command-args, sse-host, env-file and 'env' are optional
