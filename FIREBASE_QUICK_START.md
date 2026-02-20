# Firebase Setup - Quick Reference

## TL;DR - 5 Minute Setup

### 1. Firebase Console Setup (2 min)
```bash
# 1. Create project at https://console.firebase.google.com
# 2. Add Android app with package name from android/app/build.gradle
# 3. Download google-services.json → put in android/app/
# 4. Add iOS app with bundle ID from ios/Runner/Info.plist  
# 5. Download GoogleService-Info.plist → add to Xcode Runner folder
```

### 2. Android Configuration (1 min)

**android/build.gradle** (add to dependencies):
```gradle
classpath 'com.google.gms:google-services:4.4.1'
```

**android/app/build.gradle** (add at bottom):
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. iOS Configuration (1 min)

```bash
cd ios
pod install --repo-update
```

### 4. Flutter Dependencies (1 min)

**pubspec.yaml**:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
```

```bash
flutter pub get
```

### 5. Initialize Firebase (30 sec)

**main.dart**:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### 6. Enable Auth in Console (30 sec)

Firebase Console → Authentication → Get Started → Enable Email/Password

---

## Quick Commands

```bash
# After adding google-services.json
flutter clean
flutter pub get

# iOS issues
cd ios && pod deintegrate && pod install --repo-update

# Generate firebase_options.dart (optional)
dart pub global activate flutterfire_cli
flutterfire configure --project=your-project-id
```

---

## File Locations

| File | Location |
|------|----------|
| google-services.json | `android/app/google-services.json` |
| GoogleService-Info.plist | `ios/Runner/GoogleService-Info.plist` |
| firebase_options.dart | `lib/firebase_options.dart` |

---

## Test It Works

1. Run app: `flutter run`
2. Register a new user
3. Check Firebase Console → Authentication → Users
4. Should see the new user listed

---

## Common Errors

| Error | Fix |
|-------|-----|
| "Firebase not initialized" | Call `Firebase.initializeApp()` before `runApp()` |
| "google-services.json not found" | Put file in correct location, run `flutter clean` |
| "API key not valid" | Check package name matches Firebase registration |
| iOS build fails | Run `pod install --repo-update` in ios folder |
| "Network error" | Enable Firebase Auth in console, check internet |

---

## Next Steps

1. ✅ Auth working? → Move to Firestore database
2. Create collections in Firestore Console
3. Update repositories to use Firestore instead of SharedPreferences
4. Set up Security Rules

See **FIREBASE_SETUP.md** for detailed instructions.