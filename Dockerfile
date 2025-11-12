# Multi-stage build for smaller final image with MCP support
# Builds from local code with Atlassian Confluence and Monday.com MCP servers

FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for Claude Code CLI and MCP servers)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY pyproject.toml setup.py ./
COPY claude_code_api ./claude_code_api

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install MCP servers and clean cache to reduce image size
RUN npm install -g @aashari/mcp-server-atlassian-confluence@latest && \
    npm install -g @mondaydotcomorg/agent-toolkit@latest && \
    npm install -g @mondaydotcomorg/monday-api-mcp@latest && \
    npm cache clean --force

# Final stage
FROM python:3.11-slim

# Install minimal runtime dependencies (removed git to save memory)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for Claude Code CLI and MCP servers)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for running Claude Code
RUN groupadd -r claudeuser && useradd -r -g claudeuser -m -d /home/claudeuser claudeuser

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy Claude Code CLI from builder
COPY --from=builder /usr/lib/node_modules/@anthropic-ai/claude-code /usr/lib/node_modules/@anthropic-ai/claude-code
RUN ln -s /usr/lib/node_modules/@anthropic-ai/claude-code/cli.js /usr/local/bin/claude && \
    chmod +x /usr/lib/node_modules/@anthropic-ai/claude-code/cli.js

# Copy MCP servers from builder
COPY --from=builder /usr/lib/node_modules/@aashari/mcp-server-atlassian-confluence /usr/lib/node_modules/@aashari/mcp-server-atlassian-confluence
COPY --from=builder /usr/lib/node_modules/@mondaydotcomorg/agent-toolkit /usr/lib/node_modules/@mondaydotcomorg/agent-toolkit
COPY --from=builder /usr/lib/node_modules/@mondaydotcomorg/monday-api-mcp /usr/lib/node_modules/@mondaydotcomorg/monday-api-mcp

# Set working directory
WORKDIR /app

# Copy application code from local repository (with correct ownership)
COPY --chown=claudeuser:claudeuser claude_code_api ./claude_code_api
COPY --chown=claudeuser:claudeuser pyproject.toml setup.py ./
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create necessary directories with correct ownership
RUN mkdir -p /app/data /home/claudeuser/.config/claude /home/claudeuser/.claude/debug && \
    chown -R claudeuser:claudeuser /app /home/claudeuser

# Copy persisted Claude state (credentials, settings, history) for CI/CD
COPY --chown=claudeuser:claudeuser data/claude-state /home/claudeuser/.claude

# Secure the credentials file
RUN chmod 600 /home/claudeuser/.claude/.credentials.json

# Set environment variables optimized for low memory
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
ENV HOST=0.0.0.0
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=256"
ENV PYTHONOPTIMIZE=1

# MCP Server Configuration
# Set these environment variables when running the container:
# - ATLASSIAN_SITE_NAME: Your Atlassian site name (e.g., mycompany)
# - ATLASSIAN_USER_EMAIL: Your Atlassian email
# - ATLASSIAN_API_TOKEN: Your Atlassian API token
# - MONDAY_TOKEN: Your Monday.com API token
# - ANTHROPIC_API_KEY: Your Anthropic API key (optional if using Claude Max)

# Expose port
EXPOSE 8000

# Health check with MCP verification
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health -o /tmp/health.json && \
        grep -q '"status".*"healthy\|degraded"' /tmp/health.json || exit 1

# Switch to non-root user
USER claudeuser

# Set entrypoint and command with memory-optimized settings
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["python", "-m", "uvicorn", "claude_code_api.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--limit-concurrency", "10"]
