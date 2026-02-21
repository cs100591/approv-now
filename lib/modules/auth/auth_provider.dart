import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_models.dart';
import 'auth_service.dart';
import '../../core/utils/app_logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authStateSubscription;

  AuthState _state = const AuthState();

  AuthProvider(this._authService) {
    _listenToAuthChanges();
  }

  AuthState get state => _state;

  void _listenToAuthChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      AppLogger.info('Auth state changed: ${user?.email ?? "null"}');
      if (user != null) {
        _state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else if (_state.status != AuthStatus.initial &&
          _state.status != AuthStatus.loading) {
        _state = const AuthState(status: AuthStatus.unauthenticated);
      }
      notifyListeners();
    });
  }

  Future<void> initialize() async {
    if (_state.status != AuthStatus.initial) return;

    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
        AppLogger.info('Auth initialized: authenticated as ${user.email}');
      } else {
        _state = const AuthState(status: AuthStatus.unauthenticated);
        AppLogger.info('Auth initialized: no user');
      }
    } catch (e) {
      AppLogger.error('Auth initialization error', e);
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> login(LoginRequest request) async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final result = await _authService.signInWithEmailAndPassword(request);
      if (!result.success) {
        _state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.error ?? 'Login failed',
        );
        notifyListeners();
      }
      // On success, the auth state listener will update the state
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequest request) async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final result = await _authService.registerWithEmailAndPassword(request);
      if (!result.success) {
        _state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.error ?? 'Registration failed',
        );
        notifyListeners();
      }
      // On success, the auth state listener will update the state
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      await _authService.signOut();
      _state = const AuthState(status: AuthStatus.unauthenticated);
      notifyListeners();
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  bool get isLoading => _state.status == AuthStatus.loading;
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
