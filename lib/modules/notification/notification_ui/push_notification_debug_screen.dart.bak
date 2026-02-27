import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/supabase_service.dart';
import '../fcm_service.dart';
import '../push_notification_tester.dart';

/// Debug screen for testing push notifications
class PushNotificationDebugScreen extends StatefulWidget {
  const PushNotificationDebugScreen({super.key});

  @override
  State<PushNotificationDebugScreen> createState() =>
      _PushNotificationDebugScreenState();
}

class _PushNotificationDebugScreenState
    extends State<PushNotificationDebugScreen> {
  String _status = 'Ready to test';
  String? _fcmToken;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentToken();
  }

  Future<void> _checkCurrentToken() async {
    try {
      final supabase = SupabaseService();
      final userId = supabase.currentUserId;

      if (userId != null) {
        final result = await supabase.client
            .from('profiles')
            .select('fcm_token, fcm_token_updated_at')
            .eq('id', userId)
            .single();

        setState(() {
          _fcmToken = result['fcm_token'];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to check token: $e';
      });
    }
  }

  Future<void> _testDirectHttp() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing direct HTTP call...';
      _error = null;
    });

    try {
      final supabase = SupabaseService();
      final userId = supabase.currentUserId;

      if (userId == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      await PushNotificationTester.testDirectHttpCall(userId);

      setState(() {
        _status = 'Direct HTTP test completed! Check Xcode logs.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _status = 'Direct HTTP test failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _getToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Getting FCM token...';
      _error = null;
    });

    try {
      final token = await FCMService.getToken();

      setState(() {
        _fcmToken = token;
        _status =
            token != null ? 'Token retrieved successfully!' : 'Token is null';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _status = 'Failed to get token';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Saving token to database...';
      _error = null;
    });

    try {
      final supabase = SupabaseService();
      final userId = supabase.currentUserId;

      if (userId == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      if (_fcmToken == null) {
        setState(() {
          _error = 'No token to save';
          _isLoading = false;
        });
        return;
      }

      await FCMService.saveTokenToBackend(userId, _fcmToken!);

      setState(() {
        _status = 'Token saved successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error saving token: $e';
        _status = 'Failed to save token';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking permission...';
      _error = null;
    });

    try {
      final hasPermission = await FCMService.checkPermission();

      setState(() {
        _status = 'Permission: ${hasPermission ? "Granted" : "Not granted"}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _status = 'Failed to check permission';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _status = 'Requesting permission...';
      _error = null;
    });

    try {
      final granted = await FCMService.requestPermission();

      setState(() {
        _status = 'Permission ${granted ? "granted" : "denied"}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _status = 'Failed to request permission';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _error != null ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _error != null
                      ? Colors.red.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: $_error',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Token Display
            if (_fcmToken != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FCM Token (Database)',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_fcmToken!.substring(0, _fcmToken!.length > 50 ? 50 : _fcmToken!.length)}...',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      'Length: ${_fcmToken!.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            _buildButton(
              '1. Check Permission',
              _checkPermission,
              Icons.security,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '2. Request Permission',
              _requestPermission,
              Icons.notifications_active,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '3. Get FCM Token',
              _getToken,
              Icons.vpn_key,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '4. Save Token to Database',
              _saveToken,
              Icons.save,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '5. Refresh from Database',
              _checkCurrentToken,
              Icons.refresh,
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),
            _buildButton(
              '🔴 TEST: Direct HTTP Call (CRITICAL)',
              _testDirectHttp,
              Icons.http,
            ),
            const SizedBox(height: 8),
            Text(
              'This bypasses Supabase client and calls Edge Function directly via HTTP',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
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
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
