# RevenueCat Configuration Guide

## Problem
RevenueCat integration is not working properly:
1. Buttons are not clickable (SDK not initialized)
2. Prices are different from expected
3. Products not loading

## Solution

### 1. SDK Initialization (✅ Fixed)
- Added RevenueCat initialization in `AuthProvider` when user logs in
- Added logout handling when user signs out

### 2. API Keys Configuration

You need to configure your actual RevenueCat API keys in `lib/modules/subscription/revenuecat_service.dart`:

```dart
if (Platform.isIOS) {
  apiKey = 'YOUR_IOS_API_KEY'; // Starts with 'appl_'
} else if (Platform.isAndroid) {
  apiKey = 'YOUR_ANDROID_API_KEY'; // Starts with 'goog_'
}
```

Get your API keys from: https://app.revenuecat.com/settings/api-keys

### 3. Product Configuration in RevenueCat Dashboard

You need to configure these products in your RevenueCat Dashboard:

**Current product IDs in code:**
- `approv_now_starter_monthly` - Starter Monthly
- `approvnow_starter_yearly` - Starter Yearly  
- `approv_now_pro_monthly` - Pro Monthly
- `approv_now_pro_yearly` - Pro Yearly

**Setup steps:**
1. Go to https://app.revenuecat.com
2. Create your project
3. Add your app (iOS/Android)
4. Create offerings with these product IDs
5. Link them to your actual App Store / Play Store products

### 4. Offering Configuration

Make sure you have an offering named `default` with these packages:
- Starter Monthly
- Starter Yearly
- Pro Monthly
- Pro Yearly

### 5. Web Platform Note

RevenueCat does not support web purchases. The app now shows a message on web directing users to mobile apps.

## Testing

1. Run on iOS/Android simulator or device
2. Login to the app
3. Navigate to subscription screen
4. Products should load and buttons should be clickable
5. Test purchases in sandbox mode

## Common Issues

1. **Products not loading**: Check that products are configured in RevenueCat Dashboard and linked to App Store/Play Store
2. **Wrong prices**: Prices come from App Store/Play Store, not RevenueCat. Update prices there.
3. **Cannot click buttons**: Make sure RevenueCat is initialized (user must be logged in)
4. **Web not working**: RevenueCat doesn't support web - this is expected

## Files Modified

- `lib/modules/auth/auth_provider.dart` - Added RevenueCat initialization
- `lib/modules/subscription/subscription_screen.dart` - Added web platform support
- `lib/modules/subscription/revenuecat_service.dart` - Added platform detection and better logging
