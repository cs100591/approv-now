import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../auth_models.dart';
import '../../workspace/workspace_provider.dart';
import '../../../core/routing/route_names.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_hasNavigated) {
          return widget.child;
        }

        switch (authProvider.state.status) {
          case AuthStatus.loading:
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
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
