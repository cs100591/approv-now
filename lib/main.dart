import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/error_boundary.dart';
import 'core/services/supabase_service.dart';

// Auth Module
import 'modules/auth/auth_provider.dart';
import 'modules/auth/auth_service.dart';
import 'modules/auth/auth_ui/auth_wrapper.dart';

// Workspace Module
import 'modules/workspace/workspace_provider.dart';
import 'modules/workspace/workspace_service.dart';
import 'modules/workspace/workspace_repository.dart';
import 'modules/workspace/workspace_ui/dashboard_screen.dart';
import 'modules/workspace/group_provider.dart';

// Template Module
import 'modules/template/template_provider.dart';
import 'modules/template/template_service.dart';
import 'modules/template/template_repository.dart';

// Request Module
import 'modules/request/request_provider.dart';
import 'modules/request/request_service.dart';
import 'modules/request/request_repository.dart';

// Approval Engine Module
import 'modules/approval_engine/approval_engine_provider.dart';
import 'modules/approval_engine/approval_engine_service.dart';

// Revision Module
import 'modules/revision/revision_provider.dart';
import 'modules/revision/revision_service.dart';

// Export Module
import 'modules/export/export_provider.dart';
import 'modules/export/pdf_service.dart';

// Verification Module
import 'modules/verification/verification_provider.dart';
import 'modules/verification/hash_service.dart';

// Subscription Module
import 'modules/subscription/subscription_provider.dart';
import 'modules/subscription/subscription_service.dart';
import 'modules/subscription/subscription_repository.dart';

// Notification Module
import 'modules/notification/notification_provider.dart';
import 'modules/notification/notification_service.dart';

// Analytics Module
import 'modules/analytics/analytics_service.dart';

// Plan Enforcement Module
import 'modules/plan_enforcement/plan_guard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling
  setupErrorHandling();

  // Initialize Supabase
  try {
    final supabaseService = SupabaseService();
    await supabaseService.initialize();
    AppLogger.info('✅ Supabase initialized successfully');
    AppLogger.info(
        '📱 Project: ${supabaseService.currentUserId ?? "Not logged in"}');
  } catch (e) {
    AppLogger.error('❌ Supabase initialization failed: $e');
    AppLogger.warning('⚠️ Continuing without Supabase...');
  }

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('❌ Uncaught platform error', error, stack);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Analytics Service (singleton, no provider needed)
        Provider(create: (_) => AnalyticsService()),

        // Plan Guard Service (singleton)
        Provider(create: (_) => PlanGuardService()),

        // Hash Service (singleton)
        Provider(create: (_) => HashService()),

        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),

        // Workspace Provider
        ChangeNotifierProvider(
          create: (_) => WorkspaceProvider(
            workspaceService: WorkspaceService(),
            workspaceRepository: WorkspaceRepository(),
          ),
        ),

        // Group Provider
        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
        ),

        // Template Provider
        ChangeNotifierProvider(
          create: (_) => TemplateProvider(
            templateService: TemplateService(),
            templateRepository: TemplateRepository(),
          ),
        ),

        // Request Provider
        ChangeNotifierProvider(
          create: (_) => RequestProvider(
            requestService: RequestService(),
            requestRepository: RequestRepository(),
          ),
        ),

        // Approval Engine Provider
        ChangeNotifierProvider(
          create: (_) => ApprovalEngineProvider(
            approvalEngineService: ApprovalEngineService(),
          ),
        ),

        // Revision Provider
        ChangeNotifierProvider(
          create: (_) => RevisionProvider(
            revisionService: RevisionService(),
          ),
        ),

        // Export Provider
        ProxyProvider<HashService, ExportProvider>(
          update: (_, hashService, __) => ExportProvider(
            pdfService: PdfService(),
            hashService: hashService,
          ),
        ),

        // Verification Provider
        ProxyProvider<HashService, VerificationProvider>(
          update: (_, hashService, __) => VerificationProvider(
            hashService: hashService,
          ),
        ),

        // Subscription Provider
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(
            subscriptionService: SubscriptionService(),
            subscriptionRepository: SubscriptionRepository(),
          ),
        ),

        // Notification Provider
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Approv Now',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AuthWrapper(
          child: const DashboardScreen(),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
