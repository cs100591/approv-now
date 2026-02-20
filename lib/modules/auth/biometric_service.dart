import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';
  static const String _enabledKey = 'biometric_enabled';

  Future<bool> get isDeviceSupported async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      return isSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> get canCheckBiometrics async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> get isBiometricEnabled async {
    try {
      final enabled = await _secureStorage.read(key: _enabledKey);
      return enabled == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<bool> get hasStoredCredentials async {
    try {
      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      return email != null && password != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> enableBiometric({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
    await _secureStorage.write(key: _enabledKey, value: 'true');
  }

  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
    await _secureStorage.write(key: _enabledKey, value: 'false');
  }

  Future<BiometricResult> authenticate() async {
    try {
      final isAvailable = await canCheckBiometrics;
      if (!isAvailable) {
        return BiometricResult(
          success: false,
          error: 'Biometric authentication not available',
        );
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        final email = await _secureStorage.read(key: _emailKey);
        final password = await _secureStorage.read(key: _passwordKey);

        if (email != null && password != null) {
          return BiometricResult(
            success: true,
            email: email,
            password: password,
          );
        }
        return BiometricResult(
          success: false,
          error: 'No stored credentials found',
        );
      }

      return BiometricResult(
        success: false,
        error: 'Authentication failed',
      );
    } on PlatformException catch (e) {
      String errorMessage = 'Authentication error';

      if (e.code == auth_error.notAvailable) {
        errorMessage = 'Biometric authentication not available';
      } else if (e.code == auth_error.notEnrolled) {
        errorMessage =
            'No biometrics enrolled. Please set up fingerprint or face ID';
      } else if (e.code == auth_error.lockedOut) {
        errorMessage = 'Too many attempts. Please try again later';
      } else if (e.code == auth_error.permanentlyLockedOut) {
        errorMessage =
            'Biometric authentication is disabled. Please unlock your device';
      }

      return BiometricResult(
        success: false,
        error: errorMessage,
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<BiometricType> get primaryBiometricType async {
    final biometrics = await availableBiometrics;
    if (biometrics.isEmpty) return BiometricType.fingerprint;

    if (biometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (biometrics.contains(BiometricType.weak)) {
      return BiometricType.weak;
    } else if (biometrics.contains(BiometricType.iris)) {
      return BiometricType.iris;
    }

    return biometrics.first;
  }
}

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
