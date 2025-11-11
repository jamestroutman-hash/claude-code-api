# Claude Code API - Model Mappings

**Last Updated**: November 11, 2025
**Claude Code Version**: 2.0.37

## Overview

The Claude Code API Gateway now supports the latest Claude models from Claude Code 2.0.37, with flexible alias support for both Claude Code native aliases and OpenAI-style compatibility.

## Current Model Mappings

### Latest Models (Recommended)

| Model ID | Name | Description | Default |
|----------|------|-------------|---------|
| `claude-sonnet-4-5-20250929` | Sonnet 4.5 | Smartest model for daily use | ✅ Yes |
| `claude-haiku-4-5-20251001` | Haiku 4.5 | Fastest model for simple tasks | |
| `claude-opus-4-20250514` | Opus 4 | Legacy: Most powerful (reaches limits faster) | |

### Legacy Models (Still Supported)

| Model ID | Name | Description |
|----------|------|-------------|
| `claude-sonnet-4-20250514` | Sonnet 4 | Previous Sonnet version |
| `claude-3-7-sonnet-20250219` | Sonnet 3.7 | Advanced Sonnet |
| `claude-3-5-haiku-20241022` | Haiku 3.5 | Previous Haiku version |

## Alias Support

### Claude Code Native Aliases

These match Claude Code CLI's built-in aliases:

```bash
# Use simple aliases
curl -X POST http://localhost:8000/v1/chat/completions \
  -d '{"model": "sonnet", ...}'   # → claude-sonnet-4-5-20250929
  -d '{"model": "haiku", ...}'    # → claude-haiku-4-5-20251001
  -d '{"model": "opus", ...}'     # → claude-opus-4-20250514
```

### OpenAI Compatibility Aliases

For seamless migration from OpenAI:

```bash
# Drop-in replacement for OpenAI API
curl -X POST http://localhost:8000/v1/chat/completions \
  -d '{"model": "gpt-4", ...}'         # → claude-sonnet-4-5-20250929
  -d '{"model": "gpt-4-turbo", ...}'   # → claude-sonnet-4-5-20250929
  -d '{"model": "gpt-3.5-turbo", ...}' # → claude-haiku-4-5-20251001
```

### Legacy Claude API Aliases

For backward compatibility with Claude API naming:

```bash
# Legacy Claude names
curl -X POST http://localhost:8000/v1/chat/completions \
  -d '{"model": "claude-3-opus", ...}'      # → claude-opus-4-20250514
  -d '{"model": "claude-3-sonnet", ...}'    # → claude-sonnet-4-5-20250929
  -d '{"model": "claude-3-haiku", ...}'     # → claude-haiku-4-5-20251001
  -d '{"model": "claude-3-5-sonnet", ...}'  # → claude-sonnet-4-5-20250929
  -d '{"model": "claude-3-5-haiku", ...}'   # → claude-3-5-haiku-20241022
```

## Complete Alias Reference

| Alias | Maps To | Use Case |
|-------|---------|----------|
| `sonnet` | `claude-sonnet-4-5-20250929` | Default, balanced performance |
| `haiku` | `claude-haiku-4-5-20251001` | Speed and cost optimization |
| `opus` | `claude-opus-4-20250514` | Complex reasoning (use sparingly) |
| `gpt-4` | `claude-sonnet-4-5-20250929` | OpenAI migration |
| `gpt-4-turbo` | `claude-sonnet-4-5-20250929` | OpenAI migration |
| `gpt-3.5-turbo` | `claude-haiku-4-5-20251001` | OpenAI migration |
| `claude-3-opus` | `claude-opus-4-20250514` | Legacy apps |
| `claude-3-sonnet` | `claude-sonnet-4-5-20250929` | Legacy apps |
| `claude-3-haiku` | `claude-haiku-4-5-20251001` | Legacy apps |
| `claude-3-5-sonnet` | `claude-sonnet-4-5-20250929` | Legacy apps |
| `claude-3-5-haiku` | `claude-3-5-haiku-20241022` | Legacy apps |

## Model Selection Guide

### When to Use Sonnet 4.5 (Default)

```bash
# General-purpose AI assistant
{"model": "sonnet", "messages": [...]}

# Code generation and review
{"model": "claude-sonnet-4-5-20250929", "messages": [...]}

# Complex reasoning tasks
{"model": "gpt-4", "messages": [...]}  # OpenAI compatibility
```

**Best for:**
- Daily development tasks
- Code generation and review
- Complex problem solving
- Balanced cost and performance

**Pricing:** $3/MTok input, $15/MTok output

### When to Use Haiku 4.5 (Fastest)

```bash
# Quick tasks
{"model": "haiku", "messages": [...]}

# Simple questions
{"model": "claude-haiku-4-5-20251001", "messages": [...]}

# High-volume requests
{"model": "gpt-3.5-turbo", "messages": [...]}  # OpenAI compatibility
```

**Best for:**
- Simple code questions
- Quick responses
- High-volume applications
- Cost-sensitive workloads

**Pricing:** $0.25/MTok input, $1.25/MTok output

### When to Use Opus 4 (Legacy)

```bash
# Complex reasoning (use sparingly)
{"model": "opus", "messages": [...]}

# Maximum capability needed
{"model": "claude-opus-4-20250514", "messages": [...]}
```

**Best for:**
- Highly complex reasoning
- Critical decisions
- Maximum model capability

**Note:** Reaches usage limits faster. Consider Sonnet 4.5 first.

**Pricing:** $15/MTok input, $75/MTok output

## Testing Model Mappings

### List Available Models

```bash
curl http://localhost:8000/v1/models | python3 -m json.tool
```

**Response:**
```json
{
  "object": "list",
  "data": [
    {"id": "claude-sonnet-4-5-20250929", "owned_by": "anthropic-claude-2.0.37"},
    {"id": "claude-haiku-4-5-20251001", "owned_by": "anthropic-claude-2.0.37"},
    {"id": "claude-opus-4-20250514", "owned_by": "anthropic-claude-2.0.37"},
    ...
  ]
}
```

### Test Alias Resolution

```bash
# Test sonnet alias
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonnet",
    "messages": [{"role": "user", "content": "Hello"}]
  }' | jq '.model'
# Returns: "claude-sonnet-4-5-20250929"

# Test haiku alias
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "haiku",
    "messages": [{"role": "user", "content": "Hello"}]
  }' | jq '.model'
# Returns: "claude-haiku-4-5-20251001"

# Test OpenAI compatibility
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello"}]
  }' | jq '.model'
# Returns: "claude-sonnet-4-5-20250929"
```

## Implementation Details

### Code Location

Model mappings are defined in:
- `claude_code_api/models/claude.py` - Model definitions and aliases
- `claude_code_api/core/config.py` - Default model configuration

### Validation Logic

```python
from claude_code_api.models.claude import validate_claude_model

# Accepts full model IDs
model = validate_claude_model("claude-sonnet-4-5-20250929")

# Accepts aliases
model = validate_claude_model("sonnet")        # → claude-sonnet-4-5-20250929
model = validate_claude_model("haiku")         # → claude-haiku-4-5-20251001
model = validate_claude_model("gpt-4")         # → claude-sonnet-4-5-20250929

# Invalid models default to Sonnet 4.5
model = validate_claude_model("unknown-model") # → claude-sonnet-4-5-20250929
```

### Environment Variables

```bash
# Override default model
export DEFAULT_MODEL="claude-haiku-4-5-20251001"

# Or in docker-compose.yml
environment:
  - DEFAULT_MODEL=haiku
```

## Migration Guide

### From Older Claude Code API

If you were using the previous model IDs:

```bash
# Old → New
"claude-3-5-sonnet-20241022" → "claude-sonnet-4-5-20250929"
"claude-3-5-haiku-20241022"  → "claude-haiku-4-5-20251001" or "claude-3-5-haiku-20241022"
```

**Action Required:**
- Update your `model` parameter in API requests
- Or use aliases: `sonnet`, `haiku`
- Legacy model IDs still work but are not recommended

### From OpenAI API

If migrating from OpenAI:

```bash
# No changes needed! Use existing model names:
"gpt-4"         → Works (maps to Sonnet 4.5)
"gpt-4-turbo"   → Works (maps to Sonnet 4.5)
"gpt-3.5-turbo" → Works (maps to Haiku 4.5)
```

**Benefits:**
- Drop-in replacement
- Better performance (Sonnet 4.5 > GPT-4)
- Lower costs (Haiku 4.5 < GPT-3.5)

## Testing Tools

### Automated Test Suite

```bash
# Run all model tests
./test-api.sh

# Test specific models
./test-api.sh haiku
./test-api.sh sonnet

# Performance comparison
./test-api.sh performance
```

### Manual cURL Tests

See `CURL_EXAMPLES.md` for copy-paste examples of:
- All model aliases
- Streaming vs non-streaming
- Different use cases
- Error handling

## Troubleshooting

### Invalid Model Error

**Problem:**
```json
{"error": {"message": "Invalid model", "code": "invalid_model"}}
```

**Solution:**
- Use one of the supported model IDs or aliases listed above
- Check spelling and case sensitivity
- Use `/v1/models` endpoint to see available models

### Model Not Responding

**Problem:**
```json
{"error": {"message": "Failed to start Claude Code", "code": "claude_unavailable"}}
```

**Solution:**
1. Verify Claude Code is authenticated: `docker exec claude-code-api claude --version`
2. Check API key: `ANTHROPIC_API_KEY` environment variable
3. Check container logs: `docker logs claude-code-api`

### Unexpected Model Used

**Problem:** Requesting "haiku" but getting Sonnet 4.5

**Solution:**
- Check if using old docker image (rebuild: `docker build -t claude-code-api .`)
- Verify alias mapping in logs
- Use full model ID instead of alias

## Performance Comparison

Based on typical development tasks:

| Model | Speed | Quality | Cost | Best For |
|-------|-------|---------|------|----------|
| Haiku 4.5 | ⚡⚡⚡ | ⭐⭐ | 💰 | Quick Q&A, simple code |
| Sonnet 4.5 | ⚡⚡ | ⭐⭐⭐⭐ | 💰💰 | Daily development (default) |
| Opus 4 | ⚡ | ⭐⭐⭐⭐⭐ | 💰💰💰💰 | Complex reasoning (sparingly) |

## References

- [Claude Code CLI Docs](https://docs.anthropic.com/claude/docs/claude-code)
- [Anthropic Model Pricing](https://www.anthropic.com/pricing)
- [OpenAI to Claude Migration Guide](https://docs.anthropic.com/claude/docs/migrating-from-openai)

## Changelog

### 2025-11-11
- Updated to Claude Code 2.0.37 models
- Added Sonnet 4.5 as default (was Haiku 3.5)
- Added Haiku 4.5 support
- Added OpenAI compatibility aliases
- Added comprehensive alias mapping
- Created test suite and documentation

---

**Status**: ✅ Production Ready
**Testing**: All aliases validated
**Documentation**: Complete
