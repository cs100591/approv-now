import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/app_logger.dart';

/// Edge Function Test Page
class EdgeFunctionTestPage extends StatefulWidget {
  const EdgeFunctionTestPage({super.key});

  @override
  State<EdgeFunctionTestPage> createState() => _EdgeFunctionTestPageState();
}

class _EdgeFunctionTestPageState extends State<EdgeFunctionTestPage> {
  String _logs = '';
  bool _isLoading = false;
  final SupabaseService _supabase = SupabaseService();

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toIso8601String()}: $message\n';
    });
    AppLogger.info(message);
  }

  Future<void> _testEdgeFunctionDirectly() async {
    setState(() => _isLoading = true);
    _addLog('=== Testing Edge Function Directly ===');

    try {
      final userId = _supabase.currentUserId ?? 'test-user-id';
      _addLog('Current User ID: $userId');
      _addLog('Calling Edge Function: send-push-notification...');

      final response = await _supabase.client.functions.invoke(
        'send-push-notification',
        body: {
          'userId': userId,
          'title': 'Test Notification',
          'body': 'This is a test at ${DateTime.now()}',
          'data': {'test': true, 'timestamp': DateTime.now().toIso8601String()},
        },
      );

      _addLog('Response Status: ${response.status}');
      _addLog('Response Data: ${response.data}');

      if (response.status == 200) {
        _addLog('✅ SUCCESS: Edge Function called successfully');
      } else {
        _addLog('❌ FAILED: Status ${response.status}');
      }
    } catch (e, stackTrace) {
      _addLog('❌ ERROR: $e');
      _addLog('StackTrace: $stackTrace');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkDatabaseTokens() async {
    setState(() => _isLoading = true);
    _addLog('=== Checking Database Tokens ===');

    try {
      final userId = _supabase.currentUserId;
      _addLog('Current User ID: $userId');

      if (userId == null) {
        _addLog('❌ Not logged in');
        return;
      }

      final response = await _supabase.client
          .from('user_push_tokens')
          .select('*')
          .eq('user_id', userId);

      _addLog('Found ${response.length} tokens:');
      for (final token in response) {
        _addLog('  Player ID: ${token['player_id']}');
        _addLog('  Enabled: ${token['enabled']}');
        _addLog('  Updated: ${token['updated_at']}');
      }

      if (response.isEmpty) {
        _addLog('❌ WARNING: No push tokens found!');
        _addLog('   You need to re-login to save your Player ID.');
      }
    } catch (e) {
      _addLog('❌ ERROR: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testOneSignalPlayerId() async {
    setState(() => _isLoading = true);
    _addLog('=== Checking OneSignal Player ID ===');

    try {
      // This would need OneSignal import
      _addLog('Please check OneSignal Test Page for Player ID');
      _addLog('Profile → OneSignal Test');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edge Function Diagnostic'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edge Function & Push Notification Diagnostics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            _buildButton(
              '1. Test Edge Function Directly',
              _testEdgeFunctionDirectly,
              Icons.cloud,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '2. Check Database Tokens',
              _checkDatabaseTokens,
              Icons.storage,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '3. Clear Logs',
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
