import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/supabase_config.dart';
import '../../core/utils/app_logger.dart';

/// Direct HTTP test for push notification
class PushNotificationTester {
  static Future<void> testDirectHttpCall(String userId) async {
    AppLogger.info('🧪 ==================================================');
    AppLogger.info('🧪 TESTING DIRECT HTTP CALL TO EDGE FUNCTION');
    AppLogger.info('🧪 ==================================================');

    try {
      final url =
          '${SupabaseConfig.supabaseUrl}/functions/v1/send-push-notification';
      final anonKey = SupabaseConfig.supabaseAnonKey;

      AppLogger.info('🧪 URL: $url');
      AppLogger.info('🧪 Anon Key: ${anonKey.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'title': 'Direct HTTP Test',
          'body': 'This is a test from direct HTTP call at ${DateTime.now()}',
          'data': {'type': 'test', 'source': 'http_client'},
        }),
      );

      AppLogger.info('🧪 HTTP Response Status: ${response.statusCode}');
      AppLogger.info('🧪 HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        AppLogger.info('✅ Direct HTTP call SUCCESS');
      } else {
        AppLogger.error('❌ Direct HTTP call FAILED');
        AppLogger.error('Status: ${response.statusCode}');
        AppLogger.error('Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Exception in direct HTTP call');
      AppLogger.error('Error: $e');
      AppLogger.error('StackTrace: $stackTrace');
    }

    AppLogger.info('🧪 ==================================================');
    AppLogger.info('🧪 DIRECT HTTP TEST COMPLETED');
    AppLogger.info('🧪 ==================================================');
  }
}
