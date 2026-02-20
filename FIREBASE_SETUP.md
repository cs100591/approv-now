# Firebase Setup Guide for Approve Now

Complete step-by-step guide to integrate Firebase with the Flutter app.

## Prerequisites

- Firebase account (Google account)
- Flutter SDK installed
- Android Studio / Xcode for mobile development
- The Flutter project already created

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `approve-now` (or your preferred name)
4. Enable Google Analytics (recommended) → Select your Analytics account
5. Click **"Create project"**
6. Wait for project creation to complete, then click **"Continue"**

---

## Step 2: Add Android App

### 2.1 Get Android Package Name

Open `android/app/build.gradle` and find:
```gradle
android {
    defaultConfig {
        applicationId "com.example.approve_now"  // This is your package name
    }
}
```

Copy this package name (e.g., `com.example.approve_now`)

### 2.2 Register Android App in Firebase

1. In Firebase Console, click the **Android icon** (</>)
2. Register app:
   - **Android package name**: Paste your package name
   - **App nickname**: Approve Now Android
   - **Debug signing certificate SHA-1**: (Optional for now, needed for Auth later)
3. Click **"Register app"**

### 2.3 Download Config File

1. Download `google-services.json`
2. Move it to: `android/app/google-services.json`

### 2.4 Add Firebase SDK to Android

Open `android/build.gradle` (project level):

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.1'
    }
}
```

Open `android/app/build.gradle` (app level):

```gradle
// Add at the bottom of the file
apply plugin: 'com.google.gms.google-services'

dependencies {
    // Firebase BOM (Bill of Materials)
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

---

## Step 3: Add iOS App

### 3.1 Get iOS Bundle ID

Open `ios/Runner.xcworkspace` in Xcode, or check:
- `ios/Runner/Info.plist` → `CFBundleIdentifier`
- Usually: `com.example.approveNow`

### 3.2 Register iOS App in Firebase

1. In Firebase Console, click **"Add app"** → **iOS icon**
2. Register app:
   - **iOS bundle ID**: Your bundle ID (e.g., `com.example.approveNow`)
   - **App nickname**: Approve Now iOS
3. Click **"Register app"**

### 3.3 Download Config File

1. Download `GoogleService-Info.plist`
2. Open Xcode: `ios/Runner.xcworkspace`
3. Drag `GoogleService-Info.plist` into the `Runner` folder
4. Ensure **"Copy items if needed"** is checked
5. Ensure target **Runner** is selected

### 3.4 Add Firebase SDK to iOS

Open `ios/Podfile` and ensure this line exists at the top:
```ruby
platform :ios, '13.0'
```

Run in terminal:
```bash
cd ios
pod install --repo-update
```

---

## Step 4: Install Flutter Firebase Dependencies

Open `pubspec.yaml` and add/update dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  provider: ^6.1.1
  
  # Firebase Core
  firebase_core: ^2.24.2
  
  # Firebase Auth
  firebase_auth: ^4.16.0
  
  # Cloud Firestore
  cloud_firestore: ^4.14.0
  
  # Firebase Messaging (Push Notifications)
  firebase_messaging: ^14.7.10
  
  # Firebase Analytics
  firebase_analytics: ^10.8.0
  
  # Firebase Storage (File uploads)
  firebase_storage: ^11.6.0
  
  # Other existing dependencies...
```

Then run:
```bash
flutter pub get
```

---

## Step 5: Initialize Firebase in Flutter

### 5.1 Update main.dart

Replace the main.dart content:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'firebase_options.dart';  // Will be generated

// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ... your existing providers
      child: MaterialApp(
        title: 'Approve Now',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
```

### 5.2 Generate Firebase Options

Run the FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure --project=approve-now  # Use your project ID
```

This will generate `lib/firebase_options.dart` automatically.

If you get errors, you can manually create `lib/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'approve-now',
    storageBucket: 'approve-now.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'approve-now',
    storageBucket: 'approve-now.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.approveNow',
  );
}
```

**Get these values from Firebase Console:**
- Project settings → General → Your apps → SDK setup and configuration

---

## Step 6: Update Auth Repository to Use Firebase Auth

### 6.1 Update AuthRepository

Replace `lib/modules/auth/auth_repository.dart`:

```dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_models.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SharedPreferences _prefs;

  AuthRepository(this._prefs);

  /// Get current user from Firebase
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Sign in with email/password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = credential.user!;
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUser(user);
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Register with email/password
  Future<User> registerWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name if provided
      if (displayName != null) {
        await credential.user?.updateDisplayName(displayName);
      }
      
      final firebaseUser = credential.user!;
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: displayName ?? firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUser(user);
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUser();
  }

  /// Save user to local storage
  Future<void> _saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  /// Clear user from local storage
  Future<void> _clearUser() async {
    await _prefs.remove('user');
  }

  /// Handle Firebase Auth errors
  String _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
```

---

## Step 7: Update Main.dart for Firebase

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

// Auth Module
import 'modules/auth/auth_provider.dart';
import 'modules/auth/auth_repository.dart';

// Other imports...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider with Firebase
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthRepository(prefs),
          )..initialize(),
        ),
        
        // ... other providers
      ],
      child: MaterialApp(
        title: 'Approve Now',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
```

---

## Step 8: Enable Authentication in Firebase Console

1. Go to Firebase Console → Authentication
2. Click **"Get started"**
3. Enable **Email/Password** provider
4. Click **Save**

---

## Step 9: Test the Setup

### 9.1 Clean and Rebuild

```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 9.2 Test Registration

1. Go to Register screen
2. Create a new account
3. Check Firebase Console → Authentication → Users
4. You should see the new user

### 9.3 Test Login

1. Logout
2. Login with the credentials
3. Should work without errors

---

## Step 10: Optional - Enable Firestore Database

### 10.1 Create Database

1. Firebase Console → Firestore Database
2. Click **"Create database"**
3. Choose **"Start in production mode"** or **"Start in test mode"**
4. Select location (choose closest to your users)
5. Click **Enable**

### 10.2 Update Repository to Use Firestore

Example for TemplateRepository:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'template_models.dart';

class TemplateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<Template>> getTemplatesByWorkspace(String workspaceId) async {
    final snapshot = await _firestore
        .collection('templates')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('isActive', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Template.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
  
  Future<void> addTemplate(Template template) async {
    await _firestore
        .collection('templates')
        .doc(template.id)
        .set(template.toJson());
  }
  
  // ... other methods
}
```

---

## Common Issues & Solutions

### Issue 1: "Firebase has not been initialized"

**Solution**: Ensure you call `Firebase.initializeApp()` in main() before `runApp()`

### Issue 2: "google-services.json not found"

**Solution**: 
- Ensure file is at `android/app/google-services.json`
- Run `flutter clean` and rebuild

### Issue 3: iOS build fails with Firebase errors

**Solution**:
```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter run
```

### Issue 4: "API key not valid"

**Solution**: 
- Check that `google-services.json` is the correct one from Firebase Console
- Ensure package name in Android matches Firebase registration

### Issue 5: "Network error"

**Solution**: 
- Enable Firebase Authentication in console
- Check internet connection
- For emulators, use 10.0.2.2 (Android) or localhost (iOS)

---

## Next Steps

After Firebase Auth is working:

1. **Migrate other repositories** to use Firestore
2. **Set up Security Rules** for Firestore
3. **Enable Push Notifications** (FCM)
4. **Set up Firebase Analytics** for tracking
5. **Configure Firebase Storage** for file uploads

---

## Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth/flutter/start)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore/quickstart)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

---

**You're all set!** 🎉

Your app now has Firebase integration for authentication. Users can register and login with Firebase Auth.