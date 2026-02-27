import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/app_logger.dart';
import '../notification_service.dart';

/// Debug page for notification system
class NotificationDebugPage extends StatefulWidget {
  const NotificationDebugPage({super.key});

  @override
  State<NotificationDebugPage> createState() => _NotificationDebugPageState();
}

class _NotificationDebugPageState extends State<NotificationDebugPage> {
  String _logs = '';
  bool _isLoading = false;
  final SupabaseService _supabase = SupabaseService();

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toIso8601String()}: $message\n';
    });
    AppLogger.info(message);
  }

  Future<void> _checkDatabaseTokens() async {
    setState(() => _isLoading = true);
    _addLog('=== Checking Database Tokens ===');

    try {
      final userId = _supabase.currentUserId;
      _addLog('Current User ID: $userId');

      if (userId == null) {
        _addLog('❌ ERROR: User not logged in');
        return;
      }

      final response = await _supabase.client
          .from('user_push_tokens')
          .select('*')
          .eq('user_id', userId);

      _addLog('Found ${response.length} tokens:');
      for (final token in response) {
        _addLog('  - Player ID: ${token['player_id']}');
        _addLog('    Platform: ${token['platform']}');
        _addLog('    Enabled: ${token['enabled']}');
        _addLog('    Updated: ${token['updated_at']}');
      }

      if (response.isEmpty) {
        _addLog('❌ WARNING: No push tokens found!');
        _addLog(
            '   This means the device is not registered for push notifications.');
        _addLog('   Solution: Reinstall app and allow notifications.');
      }
    } catch (e) {
      _addLog('❌ ERROR checking tokens: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSendNotification() async {
    setState(() => _isLoading = true);
    _addLog('=== Testing Push Notification ===');

    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        _addLog('❌ ERROR: User not logged in');
        return;
      }

      _addLog('Sending test notification to user: $userId');

      final pushService = PushService();
      await pushService.sendPushNotification(
        userId: userId,
        title: 'Test Notification',
        body: 'This is a test push notification at ${DateTime.now()}',
        data: {'type': 'test', 'timestamp': DateTime.now().toIso8601String()},
      );

      _addLog('✅ Notification sent! Check your device.');
    } catch (e) {
      _addLog('❌ ERROR sending notification: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkEdgeFunction() async {
    setState(() => _isLoading = true);
    _addLog('=== Testing Edge Function ===');

    try {
      final userId = _supabase.currentUserId ?? 'test-user-id';

      _addLog('Invoking Edge Function with test data...');

      final response = await _supabase.client.functions.invoke(
        'send-push-notification',
        body: {
          'userId': userId,
          'title': 'Edge Function Test',
          'body': 'Testing from debug page',
          'data': {'test': true},
        },
      );

      _addLog('Response Status: ${response.status}');
      _addLog('Response Data: ${response.data}');

      if (response.status == 200) {
        _addLog('✅ Edge Function responded successfully');
      } else {
        _addLog('❌ Edge Function returned error');
      }
    } catch (e) {
      _addLog('❌ ERROR calling Edge Function: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forceSavePlayerId() async {
    setState(() => _isLoading = true);
    _addLog('=== Force Save Player ID ===');

    try {
      // This would need OneSignal import
      _addLog('Please check OneSignal Test page for Player ID');
      _addLog('Current implementation saves automatically on login');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification System Diagnostics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            _buildButton(
              '1. Check Database Tokens',
              _checkDatabaseTokens,
              Icons.storage,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '2. Test Send Notification',
              _testSendNotification,
              Icons.send,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '3. Test Edge Function',
              _checkEdgeFunction,
              Icons.cloud,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '4. Clear Logs',
              () => setState(() => _logs = ''),
              Icons.clear,
            ),
            const SizedBox(height: 24),
            Text(
              'Logs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _logs.isEmpty ? 'No logs yet. Run a test above.' : _logs,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
