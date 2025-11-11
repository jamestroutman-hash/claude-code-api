#!/bin/bash
# Claude Code API Gateway - Test Scripts
# Usage: ./test-api.sh [test_name]
# Available tests: all, health, models, simple, math, streaming, haiku, sonnet

set -e

# Configuration
API_URL="http://localhost:8000"
# For remote testing, uncomment:
# API_URL="https://claude-code-api-302i.onrender.com"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function
print_test() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}TEST: $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_separator() {
    echo -e "${YELLOW}----------------------------------------${NC}\n"
}

# Test 1: Health Check
test_health() {
    print_test "Health Check"
    curl -s "${API_URL}/health" | python3 -m json.tool
    print_separator
}

# Test 2: List Models
test_models() {
    print_test "List Available Models"
    curl -s "${API_URL}/v1/models" | python3 -m json.tool
    print_separator
}

# Test 3: Simple Completion (Non-Streaming)
test_simple() {
    print_test "Simple Chat Completion (Non-Streaming)"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "Say hello in exactly 3 words"}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 4: Math Problem
test_math() {
    print_test "Math Problem (Testing Accuracy)"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "What is 127 + 349? Reply with just the number."}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 5: Streaming Response
test_streaming() {
    print_test "Streaming Chat Completion"
    echo -e "${YELLOW}Watch for SSE events...${NC}\n"
    curl -N -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "Count from 1 to 5, with a brief comment after each number."}
        ],
        "stream": true
      }'
    echo -e "\n"
    print_separator
}

# Test 6: Haiku Model (Fast)
test_haiku() {
    print_test "Claude Haiku 3.5 (Fastest)"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "Explain quantum computing in one sentence."}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 7: Sonnet Model (Balanced)
test_sonnet() {
    print_test "Claude Sonnet 4.5 (Most Capable)"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-sonnet-4-5-20250929",
        "messages": [
          {"role": "user", "content": "What are the key differences between Python and JavaScript?"}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 8: Multi-Turn Conversation
test_conversation() {
    print_test "Multi-Turn Conversation"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "What is the capital of France?"},
          {"role": "assistant", "content": "The capital of France is Paris."},
          {"role": "user", "content": "What is its population?"}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 9: Code Generation
test_code() {
    print_test "Code Generation"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "Write a Python function to check if a number is prime. Keep it simple."}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 10: JSON Response
test_json() {
    print_test "Structured JSON Output"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "Return a JSON object with three fields: name, age, and city. Use fictional data."}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 11: Error Handling - Invalid Model
test_error_model() {
    print_test "Error Handling: Invalid Model"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "invalid-model-name",
        "messages": [
          {"role": "user", "content": "test"}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 12: Error Handling - Empty Messages
test_error_empty() {
    print_test "Error Handling: Empty Messages"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 13: Long Context Test
test_long_context() {
    print_test "Long Context Test"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "Summarize this text in 2 sentences: The Industrial Revolution was a period of major industrialization and innovation during the late 1700s and early 1800s. It began in Great Britain and quickly spread throughout the world. Before the Industrial Revolution, most goods were made by hand. The Industrial Revolution saw the development of machines that could produce goods more efficiently. This led to the growth of factories and urbanization. Many people moved from rural areas to cities to work in factories. The Industrial Revolution had both positive and negative effects. It led to economic growth and improved living standards for some, but also resulted in poor working conditions and environmental problems."}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Test 14: Performance Test
test_performance() {
    print_test "Performance Test (5 sequential requests)"
    for i in {1..5}; do
        echo -e "${YELLOW}Request $i/5...${NC}"
        START=$(date +%s%N)
        curl -s -X POST "${API_URL}/v1/chat/completions" \
          -H "Content-Type: application/json" \
          -d "{
            \"model\": \"claude-3-5-haiku-20241022\",
            \"messages\": [{\"role\": \"user\", \"content\": \"Say: Test $i\"}],
            \"stream\": false
          }" > /dev/null
        END=$(date +%s%N)
        DURATION=$((($END - $START) / 1000000))
        echo -e "${GREEN}✓ Completed in ${DURATION}ms${NC}\n"
    done
    print_separator
}

# Test 15: MCP Tools Test (if Confluence is configured)
test_mcp() {
    print_test "MCP Tools Test"
    echo -e "${YELLOW}Note: This requires ATLASSIAN credentials to be configured${NC}\n"
    curl -s -X POST "${API_URL}/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "claude-3-5-haiku-20241022",
        "messages": [
          {"role": "user", "content": "List the available MCP tools you have access to."}
        ],
        "stream": false
      }' | python3 -m json.tool
    print_separator
}

# Run all tests
test_all() {
    echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Claude Code API - Full Test Suite  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    echo -e "API URL: ${GREEN}${API_URL}${NC}\n"

    test_health
    test_models
    test_simple
    test_math
    test_haiku
    test_sonnet
    test_conversation
    test_code
    test_json
    test_long_context
    test_streaming
    test_error_model
    test_error_empty

    echo -e "\n${GREEN}╔════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  All Tests Completed Successfully  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════╝${NC}\n"
}

# Main script
case "${1:-all}" in
    all)
        test_all
        ;;
    health)
        test_health
        ;;
    models)
        test_models
        ;;
    simple)
        test_simple
        ;;
    math)
        test_math
        ;;
    streaming)
        test_streaming
        ;;
    haiku)
        test_haiku
        ;;
    sonnet)
        test_sonnet
        ;;
    conversation)
        test_conversation
        ;;
    code)
        test_code
        ;;
    json)
        test_json
        ;;
    long)
        test_long_context
        ;;
    performance)
        test_performance
        ;;
    mcp)
        test_mcp
        ;;
    error)
        test_error_model
        test_error_empty
        ;;
    *)
        echo "Usage: $0 [test_name]"
        echo ""
        echo "Available tests:"
        echo "  all          - Run all tests (default)"
        echo "  health       - Health check endpoint"
        echo "  models       - List available models"
        echo "  simple       - Simple chat completion"
        echo "  math         - Math problem test"
        echo "  streaming    - Streaming response test"
        echo "  haiku        - Claude Haiku 3.5 test"
        echo "  sonnet       - Claude Sonnet 4.5 test"
        echo "  conversation - Multi-turn conversation"
        echo "  code         - Code generation test"
        echo "  json         - Structured JSON output"
        echo "  long         - Long context test"
        echo "  performance  - Performance test (5 requests)"
        echo "  mcp          - MCP tools test"
        echo "  error        - Error handling tests"
        exit 1
        ;;
esac
