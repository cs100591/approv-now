import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Stub result class always available
class BiometricResult {
  final bool success;
  final String? email;
  final String? password;
  final String? error;

  BiometricResult({
    required this.success,
    this.email,
    this.password,
    this.error,
  });
}

/// BiometricService - Web-safe stub implementation
/// On web all methods return false/empty/unsupported.
/// For native builds with biometric support, re-enable
/// local_auth and flutter_secure_storage in pubspec.yaml
/// and replace this file with the full implementation.
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  Future<bool> get isDeviceSupported async => false;

  Future<bool> get canCheckBiometrics async => false;

  Future<List<dynamic>> get availableBiometrics async => [];

  Future<bool> get isBiometricEnabled async => false;

  Future<bool> get hasStoredCredentials async => false;

  Future<void> enableBiometric({
    required String email,
    required String password,
  }) async {}

  Future<void> disableBiometric() async {}

  Future<BiometricResult> authenticate() async {
    return BiometricResult(
      success: false,
      error: kIsWeb
          ? 'Biometric authentication is not supported on web'
          : 'Biometric authentication not available',
    );
  }

  /// Returns a placeholder — 'fingerprint' as default
  Future<dynamic> get primaryBiometricType async => 'fingerprint';
}
