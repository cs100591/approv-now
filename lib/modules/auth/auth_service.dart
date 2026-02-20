import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../core/utils/app_logger.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

/// AuthService - Firebase Authentication implementation
class AuthService {
  final firebase.FirebaseAuth _firebaseAuth;
  final AuthRepository _authRepository;

  AuthService({
    firebase.FirebaseAuth? firebaseAuth,
    AuthRepository? authRepository,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _authRepository = authRepository ?? AuthRepository();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _mapFirebaseUser(firebaseUser);
    });
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(LoginRequest request) async {
    try {
      AppLogger.info('Attempting login for: ${request.email}');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      if (credential.user == null) {
        throw AuthException('Login failed: No user returned');
      }

      final user = _mapFirebaseUser(credential.user!);
      await _authRepository.saveUser(user);
      await _authRepository
          .saveToken(await credential.user!.getIdToken() ?? '');

      AppLogger.info('Login successful for: ${request.email}');
      return AuthResult.success(user);
    } on firebase.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during login', e);
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('Unexpected error during login', e);
      return AuthResult.failure(
          'An unexpected error occurred. Please try again.');
    }
  }

  /// Register with email and password
  Future<AuthResult> registerWithEmailAndPassword(
      RegisterRequest request) async {
    try {
      AppLogger.info('Attempting registration for: ${request.email}');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      if (credential.user == null) {
        throw AuthException('Registration failed: No user returned');
      }

      // Update display name if provided
      if (request.displayName != null && request.displayName!.isNotEmpty) {
        await credential.user!.updateDisplayName(request.displayName);
      }

      // Reload user to get updated info
      await credential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser;

      if (updatedUser == null) {
        throw AuthException('Failed to get updated user info');
      }

      final user = _mapFirebaseUser(updatedUser);
      await _authRepository.saveUser(user);
      await _authRepository.saveToken(await updatedUser.getIdToken() ?? '');

      AppLogger.info('Registration successful for: ${request.email}');
      return AuthResult.success(user);
    } on firebase.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during registration', e);
      return AuthResult.failure(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('Unexpected error during registration', e);
      return AuthResult.failure(
          'An unexpected error occurred. Please try again.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _authRepository.clearUser();
      AppLogger.info('User signed out');
    } catch (e) {
      AppLogger.error('Error during sign out', e);
      rethrow;
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Skip reload on web to avoid hanging
      // Just return the cached user data
      return _mapFirebaseUser(firebaseUser);
    } catch (e) {
      AppLogger.error('Error getting current user', e);
      return null;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to: $email');
    } on firebase.FirebaseAuthException catch (e) {
      AppLogger.error('Error sending password reset email', e);
      throw AuthException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('Unexpected error sending password reset', e);
      throw AuthException(
          'Failed to send password reset email. Please try again.');
    }
  }

  /// Update user profile
  Future<User> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw AuthException('No user is currently signed in');
      }

      if (displayName != null) {
        await currentUser.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await currentUser.updatePhotoURL(photoUrl);
      }

      await currentUser.reload();
      final updatedUser = _firebaseAuth.currentUser!;

      final user = _mapFirebaseUser(updatedUser);
      await _authRepository.saveUser(user);

      AppLogger.info('User profile updated');
      return user;
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      throw AuthException('Failed to update profile. Please try again.');
    }
  }

  /// Map Firebase User to app User model
  User _mapFirebaseUser(firebase.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  /// Get user-friendly error message from Firebase error
  String _getFirebaseAuthErrorMessage(firebase.FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return error.message ??
            'An authentication error occurred. Please try again.';
    }
  }

  /// Get Firebase ID token (for API calls)
  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }
}

/// Auth result wrapper
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  const AuthResult._({required this.success, this.user, this.error});

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}

/// Auth exception
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
