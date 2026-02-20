import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';

/// Service to handle deep links for invitations and other actions
class DeepLinkService {
  static const MethodChannel _channel =
      MethodChannel('app.approvenow/deeplink');
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final StreamController<Uri> _deepLinkController =
      StreamController<Uri>.broadcast();
  Stream<Uri> get deepLinks => _deepLinkController.stream;

  /// Initialize deep link handling
  Future<void> initialize() async {
    try {
      // Handle initial deep link when app starts
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Listen for deep links while app is running
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onDeepLink') {
          final String link = call.arguments as String;
          _handleDeepLink(link);
        }
      });

      AppLogger.info('Deep link service initialized');
    } catch (e) {
      AppLogger.error('Error initializing deep links', e);
    }
  }

  /// Handle incoming deep link
  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      AppLogger.info('Received deep link: $uri');
      _deepLinkController.add(uri);
    } catch (e) {
      AppLogger.error('Error parsing deep link', e);
    }
  }

  /// Dispose
  void dispose() {
    _deepLinkController.close();
  }
}

/// Deep link router to handle different deep link types
class DeepLinkRouter {
  static String? getWorkspaceId(Uri uri) {
    return uri.queryParameters['workspace'];
  }

  static String? getInvitationId(Uri uri) {
    return uri.queryParameters['invitation'];
  }

  static String? getInvitationToken(Uri uri) {
    return uri.queryParameters['token'];
  }

  static DeepLinkAction getAction(Uri uri) {
    final action = uri.queryParameters['action'] ?? 'accept';
    switch (action) {
      case 'reject':
        return DeepLinkAction.reject;
      case 'accept':
      default:
        return DeepLinkAction.accept;
    }
  }

  static bool isInvitationLink(Uri uri) {
    return uri.path.contains('/invite') ||
        (uri.queryParameters.containsKey('workspace') &&
            uri.queryParameters.containsKey('invitation') &&
            uri.queryParameters.containsKey('token'));
  }
}

enum DeepLinkAction {
  accept,
  reject,
}
