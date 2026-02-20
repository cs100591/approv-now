import 'package:logger/logger.dart';

/// AppLogger - Centralized logging system
///
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error message', error, stackTrace);
/// ```

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug, // Change to Level.info in production
  );

  /// Log debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log verbose message
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log wtf message (What a Terrible Failure)
  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log analytics event
  static void analytics(String eventName, [Map<String, dynamic>? parameters]) {
    _logger.i(
        '📊 ANALYTICS: $eventName ${parameters != null ? '- $parameters' : ''}');
  }

  /// Log navigation
  static void navigation(String from, String to) {
    _logger.i('🧭 NAVIGATION: $from → $to');
  }

  /// Log API call
  static void api(String method, String endpoint,
      {int? statusCode, dynamic data}) {
    final status = statusCode != null ? ' [$statusCode]' : '';
    final dataStr = data != null ? ' - Data: $data' : '';
    _logger.d('🌐 API: $method $endpoint$status$dataStr');
  }

  /// Log database operation
  static void database(String operation, String table, {dynamic data}) {
    final dataStr = data != null ? ' - Data: $data' : '';
    _logger.d('💾 DATABASE: $operation $table$dataStr');
  }

  /// Log user action
  static void userAction(String action, {String? userId, dynamic details}) {
    final userStr = userId != null ? ' [User: $userId]' : '';
    final detailsStr = details != null ? ' - $details' : '';
    _logger.i('👤 USER ACTION: $action$userStr$detailsStr');
  }

  /// Close the logger and release resources
  static void close() {
    _logger.close();
  }
}
