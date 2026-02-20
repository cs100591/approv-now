import 'package:flutter/foundation.dart';
import 'auth_models.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthState _state = const AuthState();

  AuthProvider(this._authService);

  AuthState get state => _state;

  Future<void> initialize() async {
    _setLoading(true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        _state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> login(LoginRequest request) async {
    _setLoading(true);

    try {
      final result = await _authService.signInWithEmailAndPassword(request);
      if (result.success && result.user != null) {
        _state = AuthState(
          status: AuthStatus.authenticated,
          user: result.user,
        );
      } else {
        _state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.error ?? 'Login failed',
        );
      }
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> register(RegisterRequest request) async {
    _setLoading(true);

    try {
      final result = await _authService.registerWithEmailAndPassword(request);
      if (result.success && result.user != null) {
        _state = AuthState(
          status: AuthStatus.authenticated,
          user: result.user,
        );
      } else {
        _state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.error ?? 'Registration failed',
        );
      }
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      _state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _state = _state.copyWith(
      status: loading ? AuthStatus.loading : _state.status,
    );
    notifyListeners();
  }

  // Helper getters for UI
  bool get isLoading => _state.status == AuthStatus.loading;
  bool get isAuthenticated => _state.status == AuthStatus.authenticated;
  bool get hasError => _state.status == AuthStatus.error;
  String? get error => _state.errorMessage;
  User? get user => _state.user;

  // Helper methods for UI with named parameters
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
}
