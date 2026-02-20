import '../../core/utils/app_logger.dart';
import '../../core/services/supabase_service.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

/// AuthService - Supabase Authentication implementation
class AuthService {
  final SupabaseService _supabase;
  final AuthRepository _authRepository;

  AuthService({
    SupabaseService? supabase,
    AuthRepository? authRepository,
  })  : _supabase = supabase ?? SupabaseService(),
        _authRepository = authRepository ?? AuthRepository();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    return _supabase.authStateChanges.map((event) {
      final supabaseUser = event.session?.user;
      if (supabaseUser == null) return null;
      return _mapSupabaseUser(supabaseUser);
    });
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(LoginRequest request) async {
    try {
      AppLogger.info('Attempting login for: ${request.email}');

      final response = await _supabase.signIn(
        email: request.email,
        password: request.password,
      );

      if (response.user == null) {
        throw AuthException('Login failed: No user returned');
      }

      final user = _mapSupabaseUser(response.user!);
      await _authRepository.saveUser(user);

      final session = response.session;
      if (session != null) {
        await _authRepository.saveToken(session.accessToken);
      }

      AppLogger.info('Login successful for: ${request.email}');
      return AuthResult.success(user);
    } on AuthException catch (e) {
      AppLogger.error('Auth error during login', e);
      return AuthResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Unexpected error during login', e);
      final message = _getErrorMessage(e);
      return AuthResult.failure(message);
    }
  }

  /// Register with email and password
  Future<AuthResult> registerWithEmailAndPassword(
      RegisterRequest request) async {
    try {
      AppLogger.info('Attempting registration for: ${request.email}');

      final response = await _supabase.signUp(
        email: request.email,
        password: request.password,
        displayName: request.displayName,
      );

      if (response.user == null) {
        throw AuthException('Registration failed: No user returned');
      }

      final user = _mapSupabaseUser(response.user!);
      await _authRepository.saveUser(user);

      final session = response.session;
      if (session != null) {
        await _authRepository.saveToken(session.accessToken);
      }

      AppLogger.info('Registration successful for: ${request.email}');
      return AuthResult.success(user);
    } on AuthException catch (e) {
      AppLogger.error('Auth error during registration', e);
      return AuthResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Unexpected error during registration', e);
      final message = _getErrorMessage(e);
      return AuthResult.failure(message);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
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
      final supabaseUser = _supabase.currentUser;
      if (supabaseUser == null) return null;
      return _mapSupabaseUser(supabaseUser);
    } catch (e) {
      AppLogger.error('Error getting current user', e);
      return null;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.resetPassword(email);
      AppLogger.info('Password reset email sent to: $email');
    } catch (e) {
      AppLogger.error('Error sending password reset email', e);
      throw AuthException(_getErrorMessage(e));
    }
  }

  /// Update user profile
  Future<User> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _supabase.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      final updatedUser = _supabase.currentUser;
      if (updatedUser == null) {
        throw AuthException('No user is currently signed in');
      }

      final user = _mapSupabaseUser(updatedUser);
      await _authRepository.saveUser(user);

      AppLogger.info('User profile updated');
      return user;
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      throw AuthException('Failed to update profile. Please try again.');
    }
  }

  /// Map Supabase User to app User model
  User _mapSupabaseUser(dynamic supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: metadata['display_name'] as String?,
      photoUrl: metadata['photo_url'] as String?,
      createdAt: DateTime.parse(supabaseUser.createdAt),
      lastLoginAt: supabaseUser.lastSignInAt != null
          ? DateTime.parse(supabaseUser.lastSignInAt!)
          : null,
    );
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorString.contains('email not confirmed')) {
      return 'Please check your email and confirm your account first.';
    } else if (errorString.contains('user already registered') ||
        errorString.contains('already been registered')) {
      return 'An account already exists with this email address.';
    } else if (errorString.contains('password') &&
        errorString.contains('weak')) {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (errorString.contains('invalid email')) {
      return 'Invalid email address format.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'An error occurred. Please try again.';
  }

  /// Get Supabase access token (for API calls)
  Future<String?> getIdToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
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
