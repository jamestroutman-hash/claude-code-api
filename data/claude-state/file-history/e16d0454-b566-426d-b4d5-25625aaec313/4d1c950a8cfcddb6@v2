#!/bin/bash
# Test multi-turn conversation with session management

set -e

API_URL="${API_URL:-http://localhost:8000}"
MODEL="claude-3-5-haiku-20241022"

echo "=== Testing Multi-Turn Conversation ==="
echo ""

# First message - create new session
echo "1. First message (creating new session)..."
echo "   User: What is 2+2?"
RESPONSE_1=$(curl -s -X POST "$API_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$MODEL"'",
    "messages": [
      {"role": "user", "content": "What is 2+2? Just give me the number."}
    ],
    "stream": false
  }')

echo "   Response:"
echo "$RESPONSE_1" | python3 -m json.tool

# Extract session_id
SESSION_ID=$(echo "$RESPONSE_1" | python3 -c "import sys, json; print(json.load(sys.stdin).get('session_id', ''))")
FIRST_ANSWER=$(echo "$RESPONSE_1" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])")

if [ -z "$SESSION_ID" ]; then
  echo "   ❌ ERROR: No session_id returned in response"
  exit 1
fi

echo ""
echo "   ✓ Session ID: $SESSION_ID"
echo "   ✓ First answer: $FIRST_ANSWER"
echo ""

# Second message - continue conversation
echo "2. Second message (resuming session)..."
echo "   User: What was my previous question?"
RESPONSE_2=$(curl -s -X POST "$API_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$MODEL"'",
    "messages": [
      {"role": "user", "content": "What is 2+2? Just give me the number."},
      {"role": "assistant", "content": "'"${FIRST_ANSWER//\"/\\\"}"'"},
      {"role": "user", "content": "What was my previous question?"}
    ],
    "session_id": "'"$SESSION_ID"'",
    "stream": false
  }')

echo "   Response:"
echo "$RESPONSE_2" | python3 -m json.tool

SECOND_ANSWER=$(echo "$RESPONSE_2" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])")
echo ""
echo "   ✓ Second answer: $SECOND_ANSWER"
echo ""

# Test streaming with session_id
echo "3. Testing streaming response with session_id..."
echo "   User: What is 5+5?"
echo "   Response (streaming):"

curl -s -X POST "$API_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$MODEL"'",
    "messages": [
      {"role": "user", "content": "What is 5+5? Just give me the number."}
    ],
    "stream": true
  }' | while IFS= read -r line; do
    # Skip empty lines and heartbeats
    if [[ "$line" =~ ^data:\ \{.*session_id.*\} ]]; then
      # Extract and display session_id from first chunk
      SESSION_FROM_STREAM=$(echo "$line" | python3 -c "import sys, json; data=sys.stdin.read()[6:]; print(json.loads(data).get('session_id', 'N/A'))" 2>/dev/null || echo "N/A")
      if [ "$SESSION_FROM_STREAM" != "N/A" ]; then
        echo "   ✓ Session ID in stream: $SESSION_FROM_STREAM"
      fi
    elif [[ "$line" =~ ^data:\ \{.*delta.*content.*\} ]]; then
      # Extract and display content
      CONTENT=$(echo "$line" | python3 -c "import sys, json; data=sys.stdin.read()[6:]; print(json.loads(data)['choices'][0]['delta'].get('content', ''), end='')" 2>/dev/null || echo "")
      echo -n "$CONTENT"
    elif [[ "$line" =~ ^data:\ \[DONE\] ]]; then
      echo ""
      echo "   ✓ Stream completed"
    fi
done

echo ""
echo "=== Multi-Turn Conversation Test Complete ==="
echo ""
echo "Summary:"
echo "  - Non-streaming responses include 'session_id' in JSON body"
echo "  - Streaming responses include 'session_id' in:"
echo "    * X-Session-ID header"
echo "    * SSE chunk data (initial and final chunks)"
echo "  - Clients should store session_id and send it in follow-up requests"
echo "  - Include full conversation history in messages array"
