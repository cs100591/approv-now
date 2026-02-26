# Firebase Cloud Messaging (FCM) Setup Guide

## Overview

Push notifications have been implemented using Firebase Cloud Messaging (FCM). Firebase is ONLY used for push notifications - all data storage continues to use Supabase.

## Architecture

```
┌─────────────────┐         ┌──────────────────┐
│   Flutter App   │────────▶│  Supabase DB     │
│  (FCM Client)   │         │  (FCM Tokens)    │
└─────────────────┘         └──────────────────┘
         │                            │
         │ FCM Token                  │ Trigger
         ▼                            ▼
┌─────────────────┐         ┌──────────────────┐
│ Firebase Cloud  │         │ Supabase Edge    │
│   Messaging     │◀────────│ Function         │
│   (FCM Server)  │  Send   │ (send-push-     │
└─────────────────┘         │ notification)   │
         │                  └──────────────────┘
         │ Push
         ▼ Notification
┌─────────────────┐
│  Target Device  │
└─────────────────┘
```

## Current Status

### ✅ Completed

1. **Flutter Code**
   - `fcm_service.dart` - FCM integration service
   - `notification_provider.dart` - Updated to initialize FCM
   - `notification_service.dart` - Updated PushService to call Edge Function
   - `main.dart` - Firebase initialization added
   - `pubspec.yaml` - Firebase dependencies enabled

2. **Backend Code**
   - `supabase/functions/send-push-notification/index.ts` - Edge Function to send FCM
   - `supabase/migrations/20250227_add_fcm_token_support.sql` - Database schema

3. **Configuration Files**
   - Android: `google-services.json` ✅ (already exists)
   - iOS: `GoogleService-Info.plist` ✅ (already exists)
   - Android Gradle: Google Services plugin ✅ (already configured)

### ⚠️ Required Steps

#### 1. Get FCM Server Key

You need to add the FCM Server Key to Supabase Edge Function secrets.

**Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your "approve-now" project
3. Go to Project Settings → Cloud Messaging
4. Copy the "Server key" (NOT the Sender ID)
5. Add it to Supabase:
   ```bash
   supabase secrets set FCM_SERVER_KEY=your_server_key_here
   ```

#### 2. Deploy Edge Function

```bash
cd /Users/cssee/Dev/Approve\ Now
supabase functions deploy send-push-notification
```

#### 3. Apply Database Migration

```bash
supabase db push
```

Or manually run the migration SQL in Supabase Dashboard.

#### 4. Install Flutter Dependencies

```bash
cd /Users/cssee/Dev/Approve\ Now
flutter pub get
```

#### 5. iOS Specific Setup

For iOS, you need to enable push notifications in your Apple Developer account and add the APNs key to Firebase.

**Steps:**
1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Certificates, Identifiers & Profiles → Keys
3. Create a new key with "Apple Push Notifications service (APNs)" enabled
4. Download the .p8 file
5. Go to Firebase Console → Project Settings → Cloud Messaging
6. Upload the APNs key under iOS app configuration

#### 6. Test the Implementation

After completing all steps:

1. **Build the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter build ios  # or flutter build apk
   ```

2. **Run the app on a physical device** (simulators don't support push notifications)

3. **Test notifications:**
   - Create a new approval request
   - Check if the approver receives a push notification
   - Check Firebase Console → Cloud Messaging → Notifications to see sent notifications

## How It Works

### 1. Token Registration

When user logs in:
1. `FCMService.initialize()` requests notification permissions
2. FCM generates a device token
3. Token is saved to Supabase `user_profiles.fcm_token`
4. Token refresh listener is set up

### 2. Sending Notifications

When a notification is triggered:
1. `PushService.sendPushNotification()` is called
2. It calls the Supabase Edge Function `send-push-notification`
3. Edge Function:
   - Reads user's FCM token from database
   - Calls Firebase FCM API
   - Sends notification to device

### 3. Receiving Notifications

**Foreground:**
- `FCMService` receives message via `onMessage` listener
- Displays local notification using `flutter_local_notifications`

**Background/Terminated:**
- Device receives push notification from FCM
- Tapping notification opens app
- `getInitialMessage()` or `onMessageOpenedApp` handles navigation

## File Structure

```
lib/
├── main.dart                           # Firebase initialization
└── modules/
    └── notification/
        ├── fcm_service.dart           # NEW: FCM integration
        ├── notification_provider.dart  # MODIFIED: FCM init
        ├── notification_service.dart   # MODIFIED: PushService calls Edge Function
        └── ...

supabase/
├── functions/
│   └── send-push-notification/
│       └── index.ts                   # NEW: Edge Function to send FCM
└── migrations/
    └── 20250227_add_fcm_token_support.sql  # NEW: DB schema

android/
├── build.gradle.kts                    # Firebase plugin (already configured)
└── app/
    ├── build.gradle.kts                # Google Services plugin (already configured)
    └── google-services.json            # Firebase config (already exists)

ios/
└── Runner/
    └── GoogleService-Info.plist        # Firebase config (already exists)
```

## Environment Variables

### Supabase Edge Function Secrets

```bash
# Required
FCM_SERVER_KEY=your_fcm_server_key_here

# Already exists
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Troubleshooting

### Issue: "No FCM token found"
**Cause:** User hasn't granted notification permissions or token wasn't saved.
**Solution:** Check that:
1. App requests notification permission on first launch
2. User granted permission
3. Token was saved to database

### Issue: "FCM send failed with 404"
**Cause:** Invalid FCM token.
**Solution:** The Edge Function automatically clears invalid tokens. User needs to re-open app to get new token.

### Issue: Notifications not received on iOS
**Cause:** APNs not configured properly.
**Solution:** 
1. Check Apple Developer portal for APNs key
2. Verify APNs key is uploaded to Firebase Console
3. Test on physical device (not simulator)

### Issue: "Missing FCM_SERVER_KEY"
**Cause:** Environment variable not set.
**Solution:** 
```bash
supabase secrets set FCM_SERVER_KEY=your_key_here
```

## Testing

### Unit Test
```dart
// Test token generation
final token = await FCMService.getToken();
expect(token, isNotNull);
```

### Integration Test
```dart
// Test notification sending
await pushService.sendPushNotification(
  userId: testUserId,
  title: 'Test',
  body: 'Test notification',
);
```

### Manual Test
1. Install app on device
2. Grant notification permission
3. Create a multi-level approval request
4. Verify notifications are received at each level

## Cost Considerations

- **Firebase Cloud Messaging**: Free up to 1 million notifications/day
- **Supabase Edge Functions**: 500,000 invocations/month on free tier
- **Your usage**: Likely well under limits

## Security Notes

1. FCM Server Key is stored in Supabase Secrets (encrypted)
2. FCM tokens are stored per-user in database
3. Edge Function validates user before sending
4. Invalid tokens are automatically cleared

## Next Steps

1. ✅ Run `flutter pub get` to download dependencies
2. ✅ Deploy Edge Function: `supabase functions deploy send-push-notification`
3. ✅ Apply database migration: `supabase db push`
4. ⚠️ Set FCM_SERVER_KEY secret
5. ⚠️ Configure iOS APNs if needed
6. ⚠️ Test on physical device

## Support

If you encounter issues:
1. Check Firebase Console → Cloud Messaging for delivery stats
2. Check Supabase Edge Function logs
3. Check device logs (`flutter logs`)
4. Verify FCM token is in database: `SELECT user_id, fcm_token FROM user_profiles;`
