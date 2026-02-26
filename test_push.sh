#!/bin/bash

# Test push notification via Supabase Edge Function

echo "🔔 Testing Push Notification..."
echo ""

# Get Supabase URL and Key
SUPABASE_URL="https://poaontiyougqfzmzxerf.supabase.co"

# Test user ID (replace with your actual user ID)
USER_ID="${1:-YOUR_USER_ID}"

echo "Sending to User ID: $USER_ID"
echo ""

# Call Edge Function directly
curl -X POST "${SUPABASE_URL}/functions/v1/send-push-notification" \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"title\": \"Test Notification\",
    \"body\": \"This is a test push notification from curl!\",
    \"data\": {
      \"type\": \"test\",
      \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
    }
  }" \
  -s | jq .

echo ""
echo "✅ Request sent! Check your phone."
