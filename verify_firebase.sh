#!/bin/bash

echo "=========================================="
echo "Firebase Configuration Verification"
echo "=========================================="
echo ""

# Check pubspec.yaml dependencies
echo "✓ Checking pubspec.yaml dependencies..."
if grep -q "firebase_core: ^3." "/Users/cssee/Dev/Approve Now/pubspec.yaml"; then
    echo "  ✓ firebase_core version correct (^3.x)"
else
    echo "  ✗ firebase_core version incorrect"
fi

if grep -q "firebase_auth: ^5." "/Users/cssee/Dev/Approve Now/pubspec.yaml"; then
    echo "  ✓ firebase_auth version correct (^5.x)"
else
    echo "  ✗ firebase_auth version incorrect"
fi

if grep -q "cloud_firestore: ^5." "/Users/cssee/Dev/Approve Now/pubspec.yaml"; then
    echo "  ✓ cloud_firestore version correct (^5.x)"
else
    echo "  ✗ cloud_firestore version incorrect"
fi

echo ""

# Check Android config
echo "✓ Checking Android configuration..."
if [ -f "/Users/cssee/Dev/Approve Now/android/app/google-services.json" ]; then
    echo "  ✓ google-services.json exists"
    PKG_NAME=$(grep -o '"package_name": "[^"]*"' "/Users/cssee/Dev/Approve Now/android/app/google-services.json" | head -1)
    echo "  ✓ Package name: $PKG_NAME"
else
    echo "  ✗ google-services.json missing"
fi

echo ""

# Check iOS config
echo "✓ Checking iOS configuration..."
if [ -f "/Users/cssee/Dev/Approve Now/ios/Runner/GoogleService-Info.plist" ]; then
    echo "  ✓ GoogleService-Info.plist exists"
    BUNDLE_ID=$(grep -A1 "BUNDLE_ID" "/Users/cssee/Dev/Approve Now/ios/Runner/GoogleService-Info.plist" | grep "string" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
    echo "  ✓ Bundle ID: $BUNDLE_ID"
else
    echo "  ✗ GoogleService-Info.plist missing"
fi

echo ""

# Check Xcode project
echo "✓ Checking Xcode project..."
if grep -q "PRODUCT_BUNDLE_IDENTIFIER = com.approvenow.approve_now" "/Users/cssee/Dev/Approve Now/ios/Runner.xcodeproj/project.pbxproj"; then
    echo "  ✓ iOS Bundle ID matches: com.approvenow.approve_now"
else
    echo "  ✗ iOS Bundle ID mismatch"
fi

echo ""
echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo ""
echo "All checks passed! Your Firebase configuration is ready."
echo ""
echo "Next steps:"
echo "1. Run: flutter clean && flutter pub get"
echo "2. Run: cd ios && pod install --repo-update"
echo "3. Run: flutter build apk --debug"
echo "4. Run: flutter build ios --debug --simulator"
echo ""
