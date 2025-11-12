#!/bin/bash
set -e

# Generate MCP configuration from environment variables in ~/.claude.json
cat > /root/.claude.json <<EOF
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
    },
    "monday-api": {
      "command": "npx",
      "args": ["-y", "@mondaydotcomorg/monday-api-mcp@latest", "-t", "${MONDAY_TOKEN:-}"],
      "env": {
        "monday_token": "${MONDAY_TOKEN:-}"
      }
    }
  }
}
EOF

echo "MCP configuration generated at ~/.claude.json"
cat /root/.claude.json

# Execute the main command
exec "$@"
