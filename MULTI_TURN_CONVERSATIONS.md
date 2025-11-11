# Multi-Turn Conversations Guide

This guide explains how to maintain context across multiple requests using session management.

## Overview

The API supports multi-turn conversations through **session IDs**. Each conversation creates a session that tracks:
- Conversation history and context
- Token usage and costs
- Project context (working directory)
- Model and configuration

## How It Works

### 1. Start a New Conversation

Send a request **without** a `session_id`:

```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "My name is Alice. What is 2+2?"}
    ],
    "stream": false
  }'
```

**Response includes session_id:**

```json
{
  "id": "chatcmpl-abc123...",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "claude-3-5-haiku-20241022",
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "Hello Alice! 2+2 equals 4."
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 8,
    "total_tokens": 18
  }
}
```

### 2. Continue the Conversation

Include the `session_id` and **full conversation history** in subsequent requests:

```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-haiku-20241022",
    "messages": [
      {"role": "user", "content": "My name is Alice. What is 2+2?"},
      {"role": "assistant", "content": "Hello Alice! 2+2 equals 4."},
      {"role": "user", "content": "What is my name?"}
    ],
    "session_id": "550e8400-e29b-41d4-a716-446655440000",
    "stream": false
  }'
```

**Response continues with same session_id:**

```json
{
  "id": "chatcmpl-def456...",
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "Your name is Alice, as you mentioned at the start of our conversation."
    }
  }]
}
```

## Session ID Locations

The API returns `session_id` in multiple places for flexibility:

### Non-Streaming Responses
- **JSON body**: `response.session_id`

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "choices": [...]
}
```

### Streaming Responses
- **HTTP Header**: `X-Session-ID: 550e8400-e29b-41d4-a716-446655440000`
- **SSE chunks**: `data.session_id` (in first and last chunks)

```
data: {"id":"chatcmpl-...","session_id":"550e8400-...","choices":[{"delta":{"role":"assistant"}}]}

data: {"id":"chatcmpl-...","choices":[{"delta":{"content":"Hello"}}]}

data: {"id":"chatcmpl-...","session_id":"550e8400-...","choices":[{"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

## Client Implementation Examples

### Python Example

```python
import requests
import json

API_URL = "http://localhost:8000/v1/chat/completions"
MODEL = "claude-3-5-haiku-20241022"

class ChatSession:
    def __init__(self):
        self.session_id = None
        self.messages = []

    def send_message(self, content: str) -> str:
        """Send a message and maintain conversation history."""
        # Add user message
        self.messages.append({"role": "user", "content": content})

        # Prepare request
        payload = {
            "model": MODEL,
            "messages": self.messages,
            "stream": False
        }

        # Include session_id if this is a follow-up
        if self.session_id:
            payload["session_id"] = self.session_id

        # Send request
        response = requests.post(API_URL, json=payload)
        data = response.json()

        # Extract session_id from first response
        if not self.session_id:
            self.session_id = data.get("session_id")
            print(f"Session started: {self.session_id}")

        # Extract assistant response
        assistant_message = data["choices"][0]["message"]["content"]

        # Add to history
        self.messages.append({"role": "assistant", "content": assistant_message})

        return assistant_message

# Usage
session = ChatSession()

response1 = session.send_message("My name is Alice")
print(f"Assistant: {response1}")

response2 = session.send_message("What is my name?")
print(f"Assistant: {response2}")
```

### JavaScript Example

```javascript
class ChatSession {
  constructor(apiUrl = 'http://localhost:8000/v1/chat/completions') {
    this.apiUrl = apiUrl;
    this.sessionId = null;
    this.messages = [];
    this.model = 'claude-3-5-haiku-20241022';
  }

  async sendMessage(content) {
    // Add user message
    this.messages.push({ role: 'user', content });

    // Prepare request
    const payload = {
      model: this.model,
      messages: this.messages,
      stream: false,
    };

    // Include session_id if this is a follow-up
    if (this.sessionId) {
      payload.session_id = this.sessionId;
    }

    // Send request
    const response = await fetch(this.apiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    // Extract session_id from first response
    if (!this.sessionId && data.session_id) {
      this.sessionId = data.session_id;
      console.log(`Session started: ${this.sessionId}`);
    }

    // Extract assistant response
    const assistantMessage = data.choices[0].message.content;

    // Add to history
    this.messages.push({ role: 'assistant', content: assistantMessage });

    return assistantMessage;
  }
}

// Usage
const session = new ChatSession();

const response1 = await session.sendMessage('My name is Alice');
console.log(`Assistant: ${response1}`);

const response2 = await session.sendMessage('What is my name?');
console.log(`Assistant: ${response2}`);
```

### Streaming Example (Python)

```python
import requests
import json

def chat_streaming(messages, session_id=None):
    """Send a streaming request and extract session_id."""
    payload = {
        "model": "claude-3-5-haiku-20241022",
        "messages": messages,
        "stream": True
    }

    if session_id:
        payload["session_id"] = session_id

    response = requests.post(
        "http://localhost:8000/v1/chat/completions",
        json=payload,
        stream=True
    )

    # Extract session_id from header or first chunk
    new_session_id = response.headers.get("X-Session-ID")
    content = ""

    for line in response.iter_lines():
        if not line:
            continue

        line = line.decode('utf-8')
        if line.startswith('data: '):
            data_str = line[6:]  # Remove 'data: ' prefix

            if data_str == '[DONE]':
                break

            try:
                chunk = json.loads(data_str)

                # Extract session_id from chunk if available
                if not new_session_id and 'session_id' in chunk:
                    new_session_id = chunk['session_id']

                # Extract content
                delta = chunk['choices'][0]['delta']
                if 'content' in delta:
                    content += delta['content']
                    print(delta['content'], end='', flush=True)
            except json.JSONDecodeError:
                pass

    print()  # New line
    return content, new_session_id

# Usage
messages = [{"role": "user", "content": "My name is Bob"}]
response1, session_id = chat_streaming(messages)

messages.append({"role": "assistant", "content": response1})
messages.append({"role": "user", "content": "What is my name?"})
response2, _ = chat_streaming(messages, session_id)
```

## Session Management

### Session Lifecycle

1. **Created**: When first request is made without `session_id`
2. **Active**: Session is available for follow-up requests
3. **Expired**: After timeout (default: 30 minutes of inactivity)
4. **Ended**: Explicitly stopped via DELETE request

### Check Session Status

```bash
curl http://localhost:8000/v1/chat/completions/{session_id}/status
```

Response:
```json
{
  "session_id": "550e8400-...",
  "project_id": "default-anonymous",
  "model": "claude-3-5-haiku-20241022",
  "is_running": false,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:35:00Z",
  "total_tokens": 150,
  "total_cost": 0.005,
  "message_count": 4
}
```

### Stop Session

```bash
curl -X DELETE http://localhost:8000/v1/chat/completions/{session_id}
```

## Best Practices

1. **Store session_id**: Always extract and store the `session_id` from the first response
2. **Send full history**: Include complete conversation history in each request
3. **Handle expiration**: Sessions expire after inactivity - be prepared to start a new session
4. **Check status**: Use the status endpoint to verify session availability
5. **Clean up**: Delete sessions when done to free resources

## Testing

Run the included test script to see multi-turn conversations in action:

```bash
./test-multi-turn.sh
```

Or set a custom API URL:

```bash
API_URL=https://your-api.com ./test-multi-turn.sh
```

## Common Issues

### Session Not Found (404)

**Problem**: The session has expired or doesn't exist

**Solution**: Start a new conversation without `session_id`

### Lost Context

**Problem**: Assistant doesn't remember previous messages

**Solution**: Ensure you're sending the **complete message history**, not just the latest message

### Different session_id in Response

**Problem**: Response has a different `session_id` than what you sent

**Solution**: This is expected for the first request. Use the returned `session_id` for follow-ups.

## Limitations

- Sessions expire after 30 minutes of inactivity (configurable)
- Maximum 10 concurrent sessions per API instance (configurable)
- Full conversation history must be sent with each request
- Project context is preserved but filesystem changes between sessions may not persist

## See Also

- [API Documentation](README.md)
- [OpenAI Compatibility](CLAUDE.md#openai-compatibility)
- [Model Mappings](MODEL_MAPPINGS.md)
