import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../modules/auth/auth_ui/auth_screens.dart';
import '../../modules/auth/auth_ui/profile_screen.dart';
import '../../modules/workspace/workspace_ui/dashboard_screen.dart';
import '../../modules/workspace/workspace_ui/workspace_switch_screen.dart';
import '../../modules/workspace/workspace_ui/team_members_screen.dart';
import '../../modules/workspace/workspace_ui/join_workspace_screen.dart';
import '../../modules/workspace/workspace_ui/workspace_settings_screen.dart';
import '../../modules/workspace/workspace_ui/workspace_manage_screen.dart';
import '../../modules/workspace/workspace_ui/workspace_detail_screen.dart';
import '../../modules/template/template_ui/templates_list_screen.dart';
import '../../modules/template/template_ui/create_template_screen.dart';
import '../../modules/template/template_ui/edit_template_screen.dart';
import '../../modules/template/template_models.dart';
import '../../modules/request/request_ui/create_request_screen.dart';
import '../../modules/request/request_ui/my_requests_screen.dart';
import '../../modules/request/request_ui/approval_view_screen.dart';
import '../../modules/request/request_ui/request_detail_screen.dart';
import '../../modules/notification/notification_ui/notifications_screen.dart';
import '../../modules/analytics/analytics_ui/analytics_screen.dart';
import 'route_names.dart';

/// AppRouter - Handles all app routing
class AppRouter {
  static const String initialRoute = RouteNames.login;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case RouteNames.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case RouteNames.templates:
        return MaterialPageRoute(
          builder: (_) => const TemplatesListScreen(),
          settings: settings,
        );

      case RouteNames.createTemplate:
        return MaterialPageRoute(
          builder: (_) => const CreateTemplateScreen(),
          settings: settings,
        );

      case '/edit-template':
        final args = settings.arguments as Map<String, dynamic>?;
        final template = args?['template'] as Template?;
        if (template == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('No template provided')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => EditTemplateScreen(template: template),
          settings: settings,
        );

      case RouteNames.createRequest:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateRequestScreen(
            templateId: args?['templateId'] as String?,
          ),
          settings: settings,
        );

      case RouteNames.approvalView:
        return MaterialPageRoute(
          builder: (_) => const ApprovalViewScreen(),
          settings: settings,
        );

      case RouteNames.myRequests:
        return MaterialPageRoute(
          builder: (_) => const MyRequestsScreen(),
          settings: settings,
        );

      case RouteNames.workspaceSwitch:
        return MaterialPageRoute(
          builder: (_) => const WorkspaceSwitchScreen(),
          settings: settings,
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case RouteNames.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      case RouteNames.analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsScreen(),
          settings: settings,
        );

      case RouteNames.teamMembers:
        return MaterialPageRoute(
          builder: (_) => const TeamMembersScreen(),
          settings: settings,
        );

      case RouteNames.joinWorkspace:
        return MaterialPageRoute(
          builder: (_) => const JoinWorkspaceScreen(),
          settings: settings,
        );

      case RouteNames.workspaceSettings:
        return MaterialPageRoute(
          builder: (_) => const WorkspaceSettingsScreen(),
          settings: settings,
        );

      case RouteNames.workspaceManage:
        return MaterialPageRoute(
          builder: (_) => const WorkspaceManageScreen(),
          settings: settings,
        );

      case RouteNames.workspaceDetail:
        String workspaceId = '';
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          workspaceId = args['workspaceId'] ?? '';
        } else if (args is String) {
          workspaceId = args;
        }
        return MaterialPageRoute(
          builder: (_) => WorkspaceDetailScreen(workspaceId: workspaceId),
          settings: settings,
        );

      case RouteNames.requestDetails:
        String requestId = '';
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          requestId = args['requestId'] ?? '';
        } else if (args is String) {
          requestId = args;
        }
        return MaterialPageRoute(
          builder: (_) => RequestDetailScreen(requestId: requestId),
          settings: settings,
        );
      case RouteNames.forgotPassword:
      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Coming Soon')),
            body: Center(
              child: Text('${settings.name} - Coming Soon'),
            ),
          ),
          settings: settings,
        );

      case '/':
        // Handle root route - redirect to login
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Route not found: ${settings.name}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(_, RouteNames.login),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
}
