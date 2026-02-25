#!/bin/bash
set -e

echo "Building Flutter Web App..."
echo "SUPABASE_URL: ${SUPABASE_URL:0:20}..."
echo "REVENUECAT_IOS_KEY: ${REVENUECAT_IOS_KEY:0:10}..."

# Build with environment variables
flutter build web \
  --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=REVENUECAT_IOS_KEY="$REVENUECAT_IOS_KEY" \
  --dart-define=REVENUECAT_ANDROID_KEY="$REVENUECAT_ANDROID_KEY"

echo "Build completed successfully!"
