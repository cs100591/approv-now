import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/widgets/app_shell.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/error_boundary.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/supabase_service.dart';

// Auth Module
import 'modules/auth/auth_provider.dart';
import 'modules/auth/auth_service.dart';
import 'modules/auth/auth_ui/auth_wrapper.dart';

// Workspace Module
import 'modules/workspace/workspace_provider.dart';
import 'modules/workspace/workspace_service.dart';
import 'modules/workspace/workspace_repository.dart';
import 'modules/workspace/group_provider.dart';

// Template Module
import 'modules/template/template_provider.dart';
import 'modules/template/template_service.dart';
import 'modules/template/template_repository.dart';

// Request Module
import 'modules/request/request_provider.dart';
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
import 'modules/notification/fcm_service.dart';

// Analytics Module
import 'modules/analytics/analytics_service.dart';

// Plan Enforcement Module
import 'modules/plan_enforcement/plan_guard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (for push notifications only)
  // Note: Firebase is only used for FCM, all data storage is via Supabase
  if (!kIsWeb) {
    try {
      // Add a small delay to ensure native side is ready
      await Future.delayed(Duration(milliseconds: 100));

      // Initialize Firebase FIRST
      await Firebase.initializeApp();
      AppLogger.info('✅ Firebase initialized for push notifications');

      // Then register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      AppLogger.info('✅ FCM background handler registered');

      // Initialize FCM Service
      final fcmInitialized = await FCMService.initialize();
      if (fcmInitialized) {
        AppLogger.info('✅ FCM Service initialized successfully');
      } else {
        AppLogger.warning('⚠️ FCM Service initialization had issues');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to initialize Firebase/FCM: $e');
      AppLogger.error('❌ Stack trace: $stackTrace');
      // Continue without Firebase - app will still work with in-app notifications
    }
  }

  // Setup global error handling
  setupErrorHandling();

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('❌ Uncaught platform error', error, stack);
    return true;
  };

  // Initialize Supabase with timeout protection
  Timer? initTimeout;
  bool initializationCompleted = false;

  try {
    // Set up a safety timeout (10 seconds) to prevent watchdog termination
    initTimeout = Timer(Duration(seconds: 10), () {
      if (!initializationCompleted) {
        AppLogger.error(
            '⚠️ App initialization timeout - Watchdog may terminate app');
        runApp(InitializationTimeoutApp());
      }
    });

    final supabaseService = SupabaseService();

    // Initialize with 8-second timeout
    await supabaseService.initialize().timeout(Duration(seconds: 8),
        onTimeout: () {
      throw TimeoutException(
          'Supabase initialization timed out after 8 seconds. '
          'This may be due to poor network connectivity.');
    });

    initializationCompleted = true;
    initTimeout.cancel();

    AppLogger.info('✅ Supabase initialized successfully');
    AppLogger.info(
        '📱 Project: ${supabaseService.currentUserId ?? "Not logged in"}');

    runApp(const MyApp());
  } catch (e) {
    initializationCompleted = true;
    initTimeout?.cancel();
    AppLogger.error('❌ Supabase initialization failed: $e');
    runApp(InitializationErrorApp(error: e.toString()));
  }
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

        // Locale Provider
        ChangeNotifierProvider(create: (_) => LocaleProvider()),

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
            requestRepository: RequestRepository(),
            notificationService: NotificationService(),
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
        ChangeNotifierProxyProvider<HashService, ExportProvider>(
          create: (context) => ExportProvider(
            pdfService: PdfService(),
            hashService: context.read<HashService>(),
          ),
          update: (_, hashService, previous) =>
              previous ??
              ExportProvider(
                pdfService: PdfService(),
                hashService: hashService,
              ),
        ),

        // Verification Provider
        ChangeNotifierProxyProvider<HashService, VerificationProvider>(
          create: (context) => VerificationProvider(
            hashService: context.read<HashService>(),
          ),
          update: (_, hashService, previous) =>
              previous ??
              VerificationProvider(
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
      child: Builder(builder: (context) {
        final localeProvider = context.watch<LocaleProvider>();
        return MaterialApp(
          title: 'Approv Now',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AuthWrapper(
            child: const AppShell(),
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      }),
    );
  }
}

class SupabaseInitializationErrorApp extends StatelessWidget {
  final Object error;

  const SupabaseInitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  'Fatal Application Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The application could not start due to a critical error during initialization.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error details: $error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red[800]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// App shown when initialization times out (prevents watchdog crash)
class InitializationTimeoutApp extends StatelessWidget {
  const InitializationTimeoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Connection Timeout',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The app is taking longer than expected to initialize. '
                    'This may be due to poor network connectivity.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Restart the app
                      main();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Continue in offline mode
                      runApp(const MyApp());
                    },
                    child: const Text('Continue Offline'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// App shown when initialization fails with specific error
class InitializationErrorApp extends StatelessWidget {
  final String error;

  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Initialization Error',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      main();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
