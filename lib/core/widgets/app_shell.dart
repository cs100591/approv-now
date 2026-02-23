import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../routing/route_names.dart';
import '../../modules/workspace/workspace_ui/dashboard_screen.dart';
import '../../modules/template/template_ui/templates_list_screen.dart';
import '../../modules/request/request_ui/my_requests_screen.dart';
import '../../modules/auth/auth_ui/profile_screen.dart';
import '../../modules/notification/notification_ui/notification_badge.dart';
import '../../modules/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onNavigationEvent(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildScreen(int index, {bool showAppBar = true}) {
    switch (index) {
      case 0:
        return DashboardScreen(showAppBar: showAppBar);
      case 1:
        return const TemplatesListScreen();
      case 2:
        return const MyRequestsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return DashboardScreen(showAppBar: showAppBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;

        if (isDesktop) {
          final authProvider = context.read<AuthProvider>();
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(_desktopTitle(context, _currentIndex)),
              actions: [
                const NotificationBadge(),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.profile),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _onDesktopMenuSelected(context, value, authProvider),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'manage',
                      child: Row(children: [
                        const Icon(Icons.business),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)?.manageWorkspaces ??
                            'Manage Workspaces'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'analytics',
                      child: Row(children: [
                        const Icon(Icons.analytics),
                        const SizedBox(width: 8),
                        const Text('Analytics'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'join',
                      child: Row(children: [
                        const Icon(Icons.group_add),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)?.joinWorkspace ??
                            'Join Workspace'),
                      ]),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(children: [
                        Icon(Icons.logout, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)?.logout ?? 'Logout',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: constraints.maxWidth > 1200 ? 200 : 72,
                  child: NavigationRail(
                    backgroundColor: AppColors.surface,
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onNavigationEvent,
                    extended: constraints.maxWidth > 1200,
                    minExtendedWidth: 200,
                    selectedIconTheme:
                        const IconThemeData(color: AppColors.primary),
                    unselectedIconTheme:
                        const IconThemeData(color: AppColors.textSecondary),
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.dashboard_outlined),
                        selectedIcon: const Icon(Icons.dashboard),
                        label: Text(AppLocalizations.of(context)?.dashboard ??
                            'Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.description_outlined),
                        selectedIcon: const Icon(Icons.description),
                        label: Text(AppLocalizations.of(context)?.templates ??
                            'Templates'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.inbox_outlined),
                        selectedIcon: const Icon(Icons.inbox),
                        label: const Text('My Requests'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.person_outline),
                        selectedIcon: const Icon(Icons.person),
                        label: Text(
                            AppLocalizations.of(context)?.profile ?? 'Profile'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildScreen(_currentIndex, showAppBar: false),
                ),
              ],
            ),
          );
        }

        // Mobile layout — each screen owns its own AppBar
        return Scaffold(
          body: _buildScreen(_currentIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onNavigationEvent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: AppLocalizations.of(context)?.dashboard ?? 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.description_outlined),
                activeIcon: const Icon(Icons.description),
                label: AppLocalizations.of(context)?.templates ?? 'Templates',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.inbox_outlined),
                activeIcon: Icon(Icons.inbox),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: AppLocalizations.of(context)?.profile ?? 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  String _desktopTitle(BuildContext context, int index) {
    switch (index) {
      case 0:
        return AppLocalizations.of(context)?.dashboard ?? 'Dashboard';
      case 1:
        return AppLocalizations.of(context)?.templates ?? 'Templates';
      case 2:
        return 'My Requests';
      case 3:
        return AppLocalizations.of(context)?.profile ?? 'Profile';
      default:
        return 'Approv Now';
    }
  }

  void _onDesktopMenuSelected(
      BuildContext context, String value, AuthProvider authProvider) {
    switch (value) {
      case 'manage':
        Navigator.pushNamed(context, RouteNames.workspaceManage);
        break;
      case 'analytics':
        Navigator.pushNamed(context, RouteNames.analytics);
        break;
      case 'join':
        Navigator.pushNamed(context, RouteNames.joinWorkspace);
        break;
      case 'logout':
        authProvider.logout();
        break;
    }
  }
}
