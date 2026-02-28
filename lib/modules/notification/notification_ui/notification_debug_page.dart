import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/app_logger.dart';

/// Debug page for notification system - with full OneSignal integration
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
      _logs +=
          '[${DateTime.now().toLocal().toString().substring(11, 19)}] $message\n';
    });
    AppLogger.info(message);
  }

  void _clearLogs() => setState(() => _logs = '');

  // ── STEP 1: Check OneSignal SDK status ─────────────────────────────────────
  Future<void> _checkOneSignalStatus() async {
    setState(() => _isLoading = true);
    _addLog('════════════════════════════════');
    _addLog('STEP 1: OneSignal SDK Status');
    _addLog('════════════════════════════════');

    try {
      final permission = await OneSignal.Notifications.permission;
      final sub = OneSignal.User.pushSubscription;
      final playerId = sub.id;
      final optedIn = sub.optedIn;

      _addLog('Permission granted: $permission');
      _addLog('Opted in: $optedIn');
      _addLog('Subscription ID: ${playerId ?? "❌ NULL - NOT REGISTERED"}');

      if (playerId == null || playerId.isEmpty) {
        _addLog('');
        _addLog('⚠️  NO SUBSCRIPTION ID!');
        _addLog('   Possible causes:');
        _addLog('   1. Push permission was denied');
        _addLog('   2. APNs key not configured in OneSignal');
        _addLog('   3. App running in simulator (no push support)');
        _addLog('   → Try STEP 2: Request Permission');
      } else {
        _addLog('');
        _addLog('✅ Subscription ID found: $playerId');
        _addLog('   → Proceed to STEP 3: Save Token to DB');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── STEP 2: Request notification permission ────────────────────────────────
  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);
    _addLog('════════════════════════════════');
    _addLog('STEP 2: Requesting Permission');
    _addLog('════════════════════════════════');

    try {
      final granted = await OneSignal.Notifications.requestPermission(true);
      _addLog('Permission result: $granted');

      if (granted) {
        _addLog('✅ Permission granted! Opting in...');
        OneSignal.User.pushSubscription.optIn();
        await Future.delayed(const Duration(seconds: 3));
        final playerId = OneSignal.User.pushSubscription.id;
        _addLog(
            'Subscription ID after grant: ${playerId ?? "still null, wait..."}');
      } else {
        _addLog('❌ Permission denied by user');
        _addLog(
            '   Go to iPhone Settings → Approv Now → Notifications → Allow');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── STEP 3: Force save token to DB ─────────────────────────────────────────
  Future<void> _forceSaveToken() async {
    setState(() => _isLoading = true);
    _addLog('════════════════════════════════');
    _addLog('STEP 3: Force Save Token to DB');
    _addLog('════════════════════════════════');

    try {
      final userId = _supabase.currentUserId;
      _addLog('Current user ID: $userId');

      if (userId == null) {
        _addLog('❌ Not logged in! Log in first.');
        return;
      }

      // Get subscription ID from OneSignal SDK
      final sub = OneSignal.User.pushSubscription;
      String? playerId = sub.id;
      _addLog('OneSignal subscription ID: ${playerId ?? "NULL"}');

      if (playerId == null || playerId.isEmpty) {
        _addLog('❌ No subscription ID available from OneSignal SDK');
        _addLog(
            '   → Make sure you allowed notifications and are on a real device');
        return;
      }

      _addLog('Saving to user_push_tokens table...');
      await _supabase.client.from('user_push_tokens').upsert({
        'user_id': userId,
        'player_id': playerId,
        'platform': 'ios',
        'enabled': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,player_id');

      _addLog('✅ Token saved! Verifying...');

      // Verify it was saved
      final saved = await _supabase.client
          .from('user_push_tokens')
          .select('player_id, enabled')
          .eq('user_id', userId);

      _addLog('Tokens in DB for this user: ${saved.length}');
      for (final t in saved) {
        _addLog('  - ${t['player_id']} (enabled: ${t['enabled']})');
      }
    } catch (e) {
      _addLog('❌ Error saving token: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── STEP 4: Check DB tokens ────────────────────────────────────────────────
  Future<void> _checkDatabaseTokens() async {
    setState(() => _isLoading = true);
    _addLog('════════════════════════════════');
    _addLog('STEP 4: DB Token Check');
    _addLog('════════════════════════════════');

    try {
      final userId = _supabase.currentUserId;
      _addLog('User ID: $userId');

      if (userId == null) {
        _addLog('❌ Not logged in');
        return;
      }

      final response = await _supabase.client
          .from('user_push_tokens')
          .select('*')
          .eq('user_id', userId);

      _addLog('Tokens found in DB: ${response.length}');
      for (final token in response) {
        _addLog('  player_id: ${token['player_id']}');
        _addLog('  platform: ${token['platform']}');
        _addLog('  enabled: ${token['enabled']}');
        _addLog('  updated: ${token['updated_at']}');
        _addLog('  ---');
      }

      if (response.isEmpty) {
        _addLog('❌ NO TOKENS IN DB!');
        _addLog('   → Run STEP 1 → STEP 2 → STEP 3');
      } else {
        _addLog('✅ Tokens found → Proceed to STEP 5: Send Test');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── STEP 5: Send test push ─────────────────────────────────────────────────
  Future<void> _sendTestPush() async {
    setState(() => _isLoading = true);
    _addLog('════════════════════════════════');
    _addLog('STEP 5: Send Test Push');
    _addLog('════════════════════════════════');

    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        _addLog('❌ Not logged in');
        return;
      }

      _addLog('Calling Edge Function for user: $userId');

      final response = await _supabase.client.functions.invoke(
        'send-push-notification',
        body: {
          'userId': userId,
          'title': '🔔 Test Notification',
          'body':
              'Push is working! Time: ${DateTime.now().toLocal().toString().substring(11, 19)}',
          'data': {'type': 'test'},
        },
      );

      _addLog('HTTP Status: ${response.status}');
      _addLog('Response: ${response.data}');

      final data = response.data as Map<String, dynamic>? ?? {};
      final recipients = data['recipients'];
      final errors = data['errors'];
      final notifId = data['notificationId'];

      _addLog('');
      _addLog('OneSignal Result:');
      _addLog('  recipients: $recipients');
      _addLog('  notificationId: $notifId');
      _addLog('  errors: $errors');

      if (recipients != null && recipients > 0) {
        _addLog('');
        _addLog('✅ SUCCESS! Notification sent to $recipients device(s)');
        _addLog('   Check your phone for the notification!');
      } else if (errors != null) {
        _addLog('');
        _addLog('❌ FAILED: $errors');
        _addLog('   → This means OneSignal has no valid subscriptions');
        _addLog('   → Re-run STEP 1 → 3 first');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Re-login OneSignal ─────────────────────────────────────────────────────
  Future<void> _reloginOneSignal() async {
    setState(() => _isLoading = true);
    _addLog('════════════════════════════════');
    _addLog('Re-login OneSignal');
    _addLog('════════════════════════════════');

    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        _addLog('❌ Not logged in');
        return;
      }

      _addLog('Calling OneSignal.logout()...');
      await OneSignal.logout();
      await Future.delayed(const Duration(seconds: 1));

      _addLog('Calling OneSignal.login($userId)...');
      await OneSignal.login(userId);
      await Future.delayed(const Duration(seconds: 2));

      final playerId = OneSignal.User.pushSubscription.id;
      _addLog('Subscription ID after re-login: ${playerId ?? "null"}');

      if (playerId != null && playerId.isNotEmpty) {
        _addLog('✅ Got subscription ID! Now saving to DB...');
        await _supabase.client.from('user_push_tokens').upsert({
          'user_id': userId,
          'player_id': playerId,
          'platform': 'ios',
          'enabled': true,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,player_id');
        _addLog('✅ Saved! Now try STEP 5: Send Test Push');
      } else {
        _addLog('❌ Still no subscription ID after login');
        _addLog('   → Check OneSignal Dashboard for this App ID:');
        _addLog('   → 21617a87-ab08-4adb-8551-840f1e7d534a');
        _addLog('   → Confirm APNs Auth Key is uploaded there');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy logs',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _logs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade100,
            child: const Text(
              '⚠️  Run steps 1→5 in order to diagnose the issue',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Buttons panel
                SizedBox(
                  width: 200,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildStepButton('1. SDK Status', _checkOneSignalStatus,
                            Colors.blue),
                        const SizedBox(height: 6),
                        _buildStepButton('2. Request Permission',
                            _requestPermission, Colors.orange),
                        const SizedBox(height: 6),
                        _buildStepButton('3. Force Save Token', _forceSaveToken,
                            Colors.purple),
                        const SizedBox(height: 6),
                        _buildStepButton('4. Check DB Tokens',
                            _checkDatabaseTokens, Colors.teal),
                        const SizedBox(height: 6),
                        _buildStepButton(
                            '5. Send Test Push', _sendTestPush, Colors.green),
                        const Divider(height: 16),
                        _buildStepButton('Re-login OneSignal',
                            _reloginOneSignal, Colors.red),
                        const SizedBox(height: 6),
                        _buildStepButton('Clear Logs', _clearLogs, Colors.grey),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                // Log output
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: const Color(0xFF1A1A2E),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            _logs.isEmpty
                                ? 'Tap a button on the left to start diagnosis...'
                                : _logs,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF00FF88),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
