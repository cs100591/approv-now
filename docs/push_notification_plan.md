# Push Notification Implementation Plan

## Current Status
❌ **NOT IMPLEMENTED** - PushService is completely stubbed out

## Implementation Steps

### Phase 1: Setup (1-2 hours)
1. **Add Dependencies**
   ```yaml
   dependencies:
     firebase_messaging: ^14.7.10
     firebase_core: ^2.24.2
     flutter_local_notifications: ^16.3.0
   ```

2. **Configure Firebase**
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Add to respective platform directories
   - Update `android/build.gradle` and `android/app/build.gradle`
   - Update `ios/Runner/AppDelegate.swift`

3. **Initialize Firebase in main.dart**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     // ... rest of initialization
   }
   ```

### Phase 2: Core Service (2-3 hours)

Create new file: `lib/modules/notification/fcm_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Request permission
  static Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
  
  // Get FCM token
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
  
  // Initialize local notifications (for foreground)
  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();
    
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }
  
  // Handle foreground messages
  static void handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show local notification
      _showLocalNotification(message);
    });
  }
  
  // Handle background messages
  static Future<void> handleBackgroundMessages() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  static void _showLocalNotification(RemoteMessage message) {
    // Implementation to show notification
  }
}

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background notification
}
```

### Phase 3: Backend Integration (2-3 hours)

1. **Create FCM Token API Endpoint**
   - Supabase Edge Function: `save-fcm-token`
   - Save token to `user_profiles` table
   - Handle token refresh

2. **Update Database Schema**
   ```sql
   ALTER TABLE user_profiles ADD COLUMN fcm_tokens TEXT[] DEFAULT '{}';
   ```

3. **Create Notification Trigger**
   - Supabase Edge Function: `send-push-notification`
   - Triggered on new notification insert
   - Sends FCM message to user's tokens

### Phase 4: Integration (1-2 hours)

1. **Update notification_service.dart**
   ```dart
   class PushService {
     final FCMService _fcmService;
     
     Future<void> sendPushNotification({...}) async {
       // Call backend API to send FCM
       await _supabase.functions.invoke('send-push-notification', body: {
         'userId': userId,
         'title': title,
         'body': body,
         'data': data,
       });
     }
   }
   ```

2. **Update main.dart**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     await FCMService.requestPermission();
     await FCMService.initLocalNotifications();
     FCMService.handleForegroundMessages();
     FCMService.handleBackgroundMessages();
     
     // Save token on login
     final token = await FCMService.getToken();
     if (token != null) {
       await notificationProvider.saveFcmToken(userId, token);
     }
   }
   ```

### Phase 5: Testing (2-3 hours)

1. **Unit Tests**
   - Token generation
   - Permission handling
   - Message parsing

2. **Integration Tests**
   - End-to-end notification flow
   - Foreground notification display
   - Background notification handling
   - Tap-to-open behavior

3. **Device Testing**
   - iOS physical device
   - Android physical device
   - Different OS versions
   - Notification permission states

## Cost Considerations

### Firebase Cloud Messaging
- **Free**: Up to 1 million notifications/day
- Your usage likely well under limit

### Supabase Edge Functions
- **Free**: 500,000 invocations/month
- Each notification = 1 invocation
- 10K notifications/day = 300K/month ✓

### Total Cost: **$0** (within free tiers)

## Timeline
- **Phase 1**: 1-2 hours
- **Phase 2**: 2-3 hours  
- **Phase 3**: 2-3 hours
- **Phase 4**: 1-2 hours
- **Phase 5**: 2-3 hours

**Total: 8-13 hours**

## Priority Recommendation

**HIGH** - Push notifications are expected by users and critical for engagement. Without them:
- Users miss approval requests
- App feels broken/unresponsive
- Low user retention

## Alternative: In-App Notifications Only

If push notifications are too complex right now:
1. Keep current in-app notification system ✓ (working)
2. Add badge counts on app icon
3. Show notification banner when app opens
4. Add sound/vibration for new notifications

This provides 80% of the value with 20% of the effort.

## Decision Point

**Option A**: Full push notification implementation (8-13 hours)
- Best user experience
- Users get notified immediately
- Professional app feel

**Option B**: Enhanced in-app notifications (2-3 hours)
- Badge counts
- Sound/vibration
- Banner on app open
- Good enough for MVP

**Option C**: Current state (0 hours)
- Only in-app notifications
- Users must open app to see notifications
- Not acceptable for production

**Recommendation**: Start with Option B (enhanced in-app), then upgrade to Option A (full push) when resources allow.
