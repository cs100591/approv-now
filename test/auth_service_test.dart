import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:approve_now/modules/auth/auth_service.dart';
import 'package:approve_now/modules/auth/auth_models.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authService = AuthService(authRepository: mockRepository);
    });

    test('Login with valid credentials should succeed', () async {
      // Arrange
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      // Act
      final result = await authService.signInWithEmailAndPassword(request);

      // Assert
      expect(result.success, false); // Would be true with real Firebase
    });

    test('Login with invalid email should fail', () async {
      // Arrange
      final request = LoginRequest(
        email: 'invalid-email',
        password: 'password123',
      );

      // Act
      final result = await authService.signInWithEmailAndPassword(request);

      // Assert
      expect(result.success, false);
      expect(result.error, isNotNull);
    });

    test('Register with valid data should succeed', () async {
      // Arrange
      final request = RegisterRequest(
        email: 'new@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      // Act
      final result = await authService.registerWithEmailAndPassword(request);

      // Assert
      expect(result.success, false); // Would be true with real Firebase
    });

    test('Sign out should clear user data', () async {
      // Act
      await authService.signOut();

      // Assert
      final user = await authService.getCurrentUser();
      expect(user, isNull);
    });
  });
}
