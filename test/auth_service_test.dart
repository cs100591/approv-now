import 'package:flutter_test/flutter_test.dart';
import 'package:approve_now/modules/auth/auth_models.dart';

void main() {
  group('Auth Models Tests', () {
    test('LoginRequest should be created correctly', () {
      const request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(request.email, 'test@example.com');
      expect(request.password, 'password123');
      expect(request.rememberMe, false);
    });

    test('LoginRequest with rememberMe should work', () {
      const request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      );

      expect(request.rememberMe, true);
    });

    test('RegisterRequest should be created correctly', () {
      const request = RegisterRequest(
        email: 'new@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      expect(request.email, 'new@example.com');
      expect(request.password, 'password123');
      expect(request.displayName, 'Test User');
    });

    test('User should be created correctly', () {
      final now = DateTime.now();
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        workspaceId: 'workspace123',
        createdAt: now,
        lastLoginAt: now,
      );

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.workspaceId, 'workspace123');
      expect(user.createdAt, now);
      expect(user.lastLoginAt, now);
    });

    test('User copyWith should work correctly', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        displayName: 'Updated Name',
        workspaceId: 'new_workspace',
      );

      expect(updatedUser.id, 'user123');
      expect(updatedUser.email, 'test@example.com');
      expect(updatedUser.displayName, 'Updated Name');
      expect(updatedUser.workspaceId, 'new_workspace');
    });

    test('User toJson and fromJson should work', () {
      final now = DateTime.now();
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: now,
      );

      final json = user.toJson();
      final restoredUser = User.fromJson(json);

      expect(restoredUser.id, user.id);
      expect(restoredUser.email, user.email);
      expect(restoredUser.displayName, user.displayName);
    });

    test('AuthState initial should work', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
    });

    test('AuthState authenticated should work', () {
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      expect(state.status, AuthStatus.authenticated);
      expect(state.user, user);
      expect(state.isAuthenticated, true);
      expect(state.isLoading, false);
    });

    test('AuthState loading should work', () {
      const state = AuthState(status: AuthStatus.loading);

      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('AuthState copyWith should work', () {
      const state = AuthState();
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final updatedState = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );

      expect(updatedState.status, AuthStatus.authenticated);
      expect(updatedState.user, user);
    });

    test('AuthStatus enum should have all values', () {
      expect(AuthStatus.values.length, 5);
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.loading));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });
}
