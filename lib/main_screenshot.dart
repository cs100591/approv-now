import 'package:flutter/material.dart';
import 'modules/subscription/mock_subscription_screen.dart';

/// Simplified app entry point for taking App Store screenshots
/// This bypasses auth and directly shows the subscription screen
void main() {
  runApp(const ScreenshotApp());
}

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approv Now',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
        ),
      ),
      home: const MockSubscriptionScreen(),
    );
  }
}
