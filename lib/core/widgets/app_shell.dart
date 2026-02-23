import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../../modules/workspace/workspace_ui/dashboard_screen.dart';
import '../../modules/template/template_ui/templates_list_screen.dart';
import '../../modules/request/request_ui/my_requests_screen.dart';
import '../../modules/auth/auth_ui/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TemplatesListScreen(),
    const MyRequestsScreen(),
    const ProfileScreen(),
  ];

  void _onNavigationEvent(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;

        if (isDesktop) {
          return Scaffold(
            body: Row(
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
                  child: _screens[_currentIndex],
                ),
              ],
            ),
          );
        }

        // Mobile layout
        return Scaffold(
          body: _screens[_currentIndex],
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
              BottomNavigationBarItem(
                icon: const Icon(Icons.inbox_outlined),
                activeIcon: const Icon(Icons.inbox),
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
}
