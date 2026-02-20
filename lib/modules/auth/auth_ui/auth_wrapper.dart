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
  bool _hasNavigated = false;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
      _setupTimeout();
    });
  }

  void _checkAuthState() {
    final authProvider = context.read<AuthProvider>();
    final workspaceProvider = context.read<WorkspaceProvider>();

    if (authProvider.isAuthenticated) {
      final userId = authProvider.user?.id;
      if (userId != null) {
        workspaceProvider.setCurrentUser(userId);
      }
    }
  }

  void _setupTimeout() {
    // If auth state doesn't resolve in 10 seconds, show retry
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_hasNavigated) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.state.status == AuthStatus.loading ||
            authProvider.state.status == AuthStatus.initial) {
          setState(() => _isTimedOut = true);
        }
      }
    });
  }

  void _retry() {
    setState(() => _isTimedOut = false);
    context.read<AuthProvider>().initialize();
    _setupTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_hasNavigated) {
          return widget.child;
        }

        if (_isTimedOut) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connection Timeout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unable to connect to the server.\nPlease check your internet connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        switch (authProvider.state.status) {
          case AuthStatus.loading:
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );

          case AuthStatus.authenticated:
            final userId = authProvider.user?.id;
            if (userId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final workspaceProvider = context.read<WorkspaceProvider>();
                workspaceProvider.setCurrentUser(userId);
              });
            }
            _hasNavigated = true;
            return widget.child;

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_hasNavigated) {
                _hasNavigated = true;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.login,
                  (route) => false,
                );
              }
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return child;
      },
    );
  }
}
