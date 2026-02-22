#!/bin/bash

# Script to run Playwright E2E tests for Approve Now

echo "🚀 Approve Now E2E Test Runner"
echo "================================"

# Check if Flutter web is already running
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Flutter web server already running on port 8080"
else
    echo "⚠️  Flutter web server not running"
    echo "📦 Building Flutter web app first..."
    
    # Build web app
    flutter build web
    if [ $? -ne 0 ]; then
        echo "❌ Flutter build failed"
        exit 1
    fi
    
    echo "🌐 Starting web server..."
    flutter run -d web-server --web-port 8080 --release &
    SERVER_PID=$!
    
    # Wait for server to be ready
    echo "⏳ Waiting for server to start..."
    for i in {1..60}; do
        if curl -s http://localhost:8080 > /dev/null; then
            echo "✅ Server ready!"
            break
        fi
        sleep 2
        echo -n "."
    done
    
    if ! curl -s http://localhost:8080 > /dev/null; then
        echo "❌ Server failed to start"
        kill $SERVER_PID 2>/dev/null
        exit 1
    fi
fi

cd e2e

# Run tests
echo ""
echo "🧪 Running Playwright tests..."
npx playwright test "$@"

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
else
    echo ""
    echo "❌ Some tests failed"
    echo "📸 Screenshots saved in: e2e/test-results/"
fi

exit $TEST_EXIT_CODE
