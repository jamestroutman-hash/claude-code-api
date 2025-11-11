#!/bin/bash
set -e

# Generate MCP configuration from environment variables in ~/.claude.json
cat > ~/.claude.json <<EOF
{
  "mcpServers": {
    "atlassian-confluence": {
      "command": "npx",
      "args": ["-y", "@aashari/mcp-server-atlassian-confluence@latest"],
      "env": {
        "ATLASSIAN_SITE_NAME": "${ATLASSIAN_SITE_NAME:-}",
        "ATLASSIAN_USER_EMAIL": "${ATLASSIAN_USER_EMAIL:-}",
        "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN:-}"
      }
    }
  }
}
EOF

echo "MCP configuration generated at ~/.claude.json"
cat ~/.claude.json

# Execute the main command
exec "$@"
