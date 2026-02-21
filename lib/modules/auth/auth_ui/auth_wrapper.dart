import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../auth_models.dart';
import '../../workspace/workspace_provider.dart';
import '../../notification/notification_provider.dart';
import 'login_screen.dart';
import '../../../core/theme/app_colors.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthStatus? _lastStatus;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  void _initializeAuth() {
    final authProvider = context.read<AuthProvider>();
    authProvider.initialize();
  }

  void _onAuthenticated(String userId) {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    workspaceProvider.setCurrentUser(userId);
    notificationProvider.initialize(userId);
  }

  void _onLogout() {
    final workspaceProvider = context.read<WorkspaceProvider>();
    workspaceProvider.clearCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final status = authProvider.state.status;
        final userId = authProvider.user?.id;

        if (status == AuthStatus.authenticated && userId != null) {
          if (_lastStatus != AuthStatus.authenticated ||
              _lastUserId != userId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onAuthenticated(userId);
            });
          }
        } else if (status == AuthStatus.unauthenticated &&
            _lastStatus == AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onLogout();
          });
        }

        _lastStatus = status;
        _lastUserId = userId;

        switch (status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const _LoadingScreen();

          case AuthStatus.authenticated:
            return widget.child;

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}
