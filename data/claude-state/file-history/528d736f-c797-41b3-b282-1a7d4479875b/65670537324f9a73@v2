# Claude Code API - cURL Examples

Quick reference for testing the Claude Code API Gateway with curl.

## Configuration

```bash
# Local testing
export API_URL="http://localhost:8000"

# Remote testing (Render)
export API_URL="https://claude-code-api-302i.onrender.com"
```

---

## Basic Endpoints

### Health Check
```bash
curl -s ${API_URL}/health | python3 -m json.tool
```

### List Available Models
```bash
curl -s ${API_URL}/v1/models | python3 -m json.tool
```

---

## Chat Completions (Non-Streaming)

### Simple Question
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "What is the capital of France?"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Math Problem
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "What is 127 + 349? Reply with just the number."}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Code Generation
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Write a Python function to calculate factorial"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Multi-Turn Conversation
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "What is React?"},
      {"role": "assistant", "content": "React is a JavaScript library for building user interfaces."},
      {"role": "user", "content": "Who created it?"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

---

## Streaming Responses

### Basic Streaming
```bash
curl -N -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Count from 1 to 5"}
    ],
    "stream": true
  }'
```

### Streaming with Long Response
```bash
curl -N -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Explain the solar system in detail"}
    ],
    "stream": true
  }'
```

---

## Different Models

### Claude Haiku 3.5 (Fastest, Cheapest)
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Explain quantum computing in one sentence"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Claude Sonnet 3.7 (Advanced)
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-7-sonnet-20250219",
    "messages": [
      {"role": "user", "content": "Compare Python and JavaScript"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Claude Sonnet 4 (Latest)
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "messages": [
      {"role": "user", "content": "Explain advanced async patterns in JavaScript"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Claude Sonnet 4.5 (Most Capable)
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "messages": [
      {"role": "user", "content": "Design a scalable microservices architecture"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Claude Opus 4 (Most Powerful)
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-opus-4-20250514",
    "messages": [
      {"role": "user", "content": "Solve this complex algorithmic problem: ..."}
    ],
    "stream": false
  }' | python3 -m json.tool
```

---

## Advanced Use Cases

### Structured JSON Output
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Return a JSON object with user data: name, email, age"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Text Summarization
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Summarize this in 2 sentences: [long text here]"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Code Review
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Review this code for bugs and improvements:\n\nfunction add(a, b) {\n  return a + b\n}"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Translation
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Translate to Spanish: Hello, how are you today?"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

---

## Error Handling Tests

### Invalid Model
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "invalid-model",
    "messages": [
      {"role": "user", "content": "test"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Empty Messages
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [],
    "stream": false
  }' | python3 -m json.tool
```

### Missing Required Fields
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022"
  }' | python3 -m json.tool
```

---

## Performance Testing

### Sequential Requests
```bash
for i in {1..5}; do
  echo "Request $i..."
  curl -s -X POST ${API_URL}/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"claude-3-5-haiku-20241022\",
      \"messages\": [{\"role\": \"user\", \"content\": \"Test $i\"}],
      \"stream\": false
    }" | python3 -m json.tool
done
```

### Parallel Requests (requires GNU parallel)
```bash
seq 1 5 | parallel -j 5 'curl -s -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-3-5-haiku-20241022\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Test {}\"}],
    \"stream\": false
  }"'
```

---

## MCP Tools Testing

### List Available Tools
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "What MCP tools do you have access to?"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

### Confluence Search (requires ATLASSIAN credentials)
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Search Confluence for documentation about authentication"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

---

## Debugging

### Verbose Health Check with Timing
```bash
time curl -v ${API_URL}/health 2>&1 | tee health-check.log
```

### Save Response to File
```bash
curl -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Test"}
    ],
    "stream": false
  }' -o response.json
cat response.json | python3 -m json.tool
```

### Show Response Headers
```bash
curl -i ${API_URL}/health
```

### Show Timing Information
```bash
curl -w "\nTime Total: %{time_total}s\nTime Connect: %{time_connect}s\n" \
  -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "Quick test"}
    ],
    "stream": false
  }' | python3 -m json.tool
```

---

## Integration Examples

### Python Requests
```python
import requests

response = requests.post(
    "http://localhost:8000/v1/chat/completions",
    json={
        "model": "claude-3-5-haiku-20241022",
        "messages": [
            {"role": "user", "content": "Hello!"}
        ],
        "stream": False
    }
)
print(response.json())
```

### JavaScript Fetch
```javascript
fetch('http://localhost:8000/v1/chat/completions', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    model: 'claude-3-5-haiku-20241022',
    messages: [{role: 'user', content: 'Hello!'}],
    stream: false
  })
})
.then(r => r.json())
.then(console.log);
```

### Using OpenAI SDK
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="not-needed"  # API key not required for local
)

response = client.chat.completions.create(
    model="claude-3-5-haiku-20241022",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

---

## Quick Test Script

Save this as `quick-test.sh`:

```bash
#!/bin/bash
export API_URL="http://localhost:8000"

echo "=== Health Check ==="
curl -s ${API_URL}/health | python3 -m json.tool

echo -e "\n=== Simple Test ==="
curl -s -X POST ${API_URL}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [{"role": "user", "content": "Say hello"}],
    "stream": false
  }' | python3 -m json.tool

echo -e "\n✅ Tests complete!"
```

Then run: `chmod +x quick-test.sh && ./quick-test.sh`

---

## Tips

1. **Use `-s` flag** for silent output (no progress bars)
2. **Use `-N` flag** for streaming to disable buffering
3. **Pipe to `python3 -m json.tool`** for pretty JSON formatting
4. **Set `API_URL` environment variable** to switch between local/remote
5. **Save responses** with `-o filename.json` for analysis
6. **Add timing** with `-w` flag for performance metrics

## Common Issues

- **Connection refused**: Check if container is running with `docker ps`
- **503 errors**: Claude Code process failed, check `docker logs claude-code-api`
- **Slow responses**: First request may be slow due to initialization
- **Empty responses**: Check logs for errors in Claude CLI execution
