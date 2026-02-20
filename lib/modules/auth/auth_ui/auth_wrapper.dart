import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../auth_models.dart';
import '../../workspace/workspace_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasInitialized = false;

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

  void _onAuthenticated() {
    final authProvider = context.read<AuthProvider>();
    final workspaceProvider = context.read<WorkspaceProvider>();

    final userId = authProvider.user?.id;
    if (userId != null) {
      workspaceProvider.setCurrentUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final status = authProvider.state.status;

        switch (status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const _LoadingScreen();

          case AuthStatus.authenticated:
            if (!_hasInitialized) {
              _hasInitialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _onAuthenticated();
              });
            }
            return widget.child;

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.login,
                (route) => false,
              );
            });
            return const _LoadingScreen();
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
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.login,
              (route) => false,
            );
          });
          return const _LoadingScreen();
        }
        return child;
      },
    );
  }
}
