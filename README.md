# Flutter Mobile App

A feature-rich Flutter mobile application built with clean architecture and best practices.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration and MaterialApp
├── constants/
│   ├── app_constants.dart    # App-wide constants
│   └── theme.dart            # Theme definitions
├── models/
│   └── [data models]
├── screens/
│   └── [UI screens]
├── widgets/
│   └── [Reusable widgets]
├── services/
│   ├── api_service.dart      # HTTP API calls
│   └── local_storage_service.dart  # SharedPreferences
├── providers/
│   └── [State management]
└── utils/
    └── [Utility functions]
```

## Getting Started

1. **Initialize the project:**
   ```bash
   ./init.sh
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Features

See `feature_list.json` for comprehensive feature requirements and implementation status.

## Development Workflow

1. Check `feature_list.json` for incomplete features
2. Select the highest priority feature marked as `passes: false`
3. Implement the feature following the steps outlined
4. Write tests for the feature
5. Update `claude-progress.txt` with session notes
6. Commit changes with descriptive commit message
7. Mark feature as `passes: true` in `feature_list.json`

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```