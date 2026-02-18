#!/bin/bash
set -e

echo "🚀 Initializing Flutter Project Environment"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Create Flutter project if it doesn't exist
if [ ! -d "lib" ]; then
    echo "📦 Creating Flutter project..."
    flutter create --project-name app . --platforms=ios,android
fi

# Start Android emulator if available (optional)
echo "📱 To run on Android emulator, start it manually:"
echo "   flutter emulators --launch <emulator_id>"
echo "   flutter run"

# Check for hot reload capability
echo "✅ Flutter project ready!"
echo ""
echo "To run the app:"
echo "  - Android: flutter emulators --launch <id> && flutter run"
echo "  - iOS Simulator: open -a Simulator && flutter run"
echo "  - Hot reload: Press 'r' in terminal"
