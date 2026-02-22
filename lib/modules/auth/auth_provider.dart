import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_models.dart';
import 'auth_service.dart';
import 'biometric_service.dart';
import '../../core/utils/app_logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authStateSubscription;

  // Track whether a login/register operation is in-flight so we can
  // surface loading state and capture errors originating from those calls.
  bool _operationLoading = false;
  String? _operationError;

  // The canonical auth state is driven ENTIRELY by the Supabase auth stream.
  // login()/register()/logout() only trigger the Supabase operations; the
  // resulting state change arrives through the stream listener below.
  AuthState _state = const AuthState();

  AuthProvider(this._authService) {
    _listenToAuthChanges();
  }

  AuthState get state => _state;

  // ─── Stream-driven state ──────────────────────────────────────────────────

  void _listenToAuthChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      AppLogger.info('Auth state changed: ${user?.email ?? "null"}');

      if (user != null) {
        // Authenticated (login, register, or session restored on app start).
        _operationLoading = false;
        _operationError = null;
        _state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        // Signed out, session expired, or intermediate null during account-switch.
        // Always transition to unauthenticated — never stay in loading/initial.
        _operationLoading = false;
        _state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: _operationError, // surface any error from the operation
        );
        _operationError = null;
      }

      notifyListeners();
    });
  }

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Called once by AuthWrapper after the first frame.
  /// Supabase restores the session automatically; this just moves us out of
  /// the initial state while we wait for the stream to fire.
  Future<void> initialize() async {
    // Only run from the initial state—re-runs are a no-op.
    if (_state.status != AuthStatus.initial) return;

    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      // Check if there is already a valid current user (server-side session).
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // Session already valid — the stream may or may not fire again.
        // Set authenticated directly so the UI doesn't flicker.
        _state = AuthState(status: AuthStatus.authenticated, user: user);
        AppLogger.info('Auth initialized: authenticated as ${user.email}');
      } else {
        // No current session. The stream will set unauthenticated if/when
        // Supabase fires a signedOut event; we set it here as a fallback.
        _state = const AuthState(status: AuthStatus.unauthenticated);
        AppLogger.info('Auth initialized: no user');
      }
    } catch (e) {
      AppLogger.error('Auth initialization error', e);
      _state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  // ─── Actions (trigger Supabase operations only) ───────────────────────────

  Future<void> login(LoginRequest request) async {
    // Show loading optimistically; the stream will confirm the outcome.
    _operationLoading = true;
    _operationError = null;
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final result = await _authService.signInWithEmailAndPassword(request);
      if (!result.success) {
        // Login call failed (wrong password, network error, etc.) — the stream
        // will NOT fire with a new user, so we must set the error here.
        _operationLoading = false;
        _operationError = null;
        _state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.error ?? 'Login failed',
        );
        notifyListeners();
      }
      // On success: Supabase fires the stream → _listenToAuthChanges sets authenticated.
    } catch (e) {
      _operationLoading = false;
      _operationError = null;
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequest request) async {
    _operationLoading = true;
    _operationError = null;
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final result = await _authService.registerWithEmailAndPassword(request);
      if (!result.success) {
        _operationLoading = false;
        _operationError = null;
        _state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.error ?? 'Registration failed',
        );
        notifyListeners();
      }
      // On success: stream fires → authenticated.
    } catch (e) {
      _operationLoading = false;
      _operationError = null;
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await BiometricService().disableBiometric();
      await _authService.signOut();
      // Stream fires signedOut → _listenToAuthChanges sets unauthenticated.
    } catch (e) {
      AppLogger.error('Logout error', e);
      // Force unauthenticated even if signOut threw (e.g. network error).
      _operationLoading = false;
      _state = const AuthState(status: AuthStatus.unauthenticated);
      notifyListeners();
    }
  }

  // ─── Convenience helpers ──────────────────────────────────────────────────

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  bool get isLoading =>
      _state.status == AuthStatus.loading || _operationLoading;
  bool get isAuthenticated => _state.status == AuthStatus.authenticated;
  bool get hasError => _state.status == AuthStatus.error;
  String? get error => _state.errorMessage;
  User? get user => _state.user;

  Future<bool> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    await login(LoginRequest(email: email, password: password));
    return isAuthenticated;
  }

  Future<void> updateProfile({required String displayName}) async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final updatedUser =
          await _authService.updateProfile(displayName: displayName);
      _state = _state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        errorMessage: null,
      );
      notifyListeners();
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        user: _state.user,
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> registerWithCredentials({
    required String name,
    required String email,
    required String password,
  }) async {
    await register(RegisterRequest(
      displayName: name,
      email: email,
      password: password,
    ));
    return isAuthenticated;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
