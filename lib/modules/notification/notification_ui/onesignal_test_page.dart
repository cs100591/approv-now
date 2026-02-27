import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:approve_now/core/theme/app_colors.dart';
import 'package:approve_now/core/theme/app_text_styles.dart';

/// OneSignal test page for debugging push notifications
class OneSignalTestPage extends StatefulWidget {
  const OneSignalTestPage({super.key});

  @override
  State<OneSignalTestPage> createState() => _OneSignalTestPageState();
}

class _OneSignalTestPageState extends State<OneSignalTestPage> {
  String _status = 'Initializing...';
  String? _playerId;
  bool _permissionGranted = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkOneSignalStatus();
  }

  Future<void> _checkOneSignalStatus() async {
    try {
      // Check permission status
      final permission = await OneSignal.Notifications.permission;

      // Check subscription status
      final subscription = OneSignal.User.pushSubscription;

      setState(() {
        _permissionGranted = permission;
        _isSubscribed = subscription.optedIn ?? false;
        _playerId = subscription.id;
        _status = 'Status checked successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _status = 'Requesting permission...';
    });

    try {
      final granted = await OneSignal.Notifications.requestPermission(true);
      setState(() {
        _permissionGranted = granted;
        _status = granted ? 'Permission granted!' : 'Permission denied';
      });

      // Re-check status after permission change
      await _checkOneSignalStatus();
    } catch (e) {
      setState(() {
        _status = 'Error requesting permission: $e';
      });
    }
  }

  Future<void> _getPlayerId() async {
    setState(() {
      _status = 'Getting Player ID...';
    });

    try {
      final subscription = OneSignal.User.pushSubscription;
      setState(() {
        _playerId = subscription.id;
        _status = 'Player ID retrieved';
      });
    } catch (e) {
      setState(() {
        _status = 'Error getting Player ID: $e';
      });
    }
  }

  Future<void> _optIn() async {
    try {
      OneSignal.User.pushSubscription.optIn();
      setState(() {
        _status = 'Opted in to push notifications';
      });
      await _checkOneSignalStatus();
    } catch (e) {
      setState(() {
        _status = 'Error opting in: $e';
      });
    }
  }

  Future<void> _optOut() async {
    try {
      OneSignal.User.pushSubscription.optOut();
      setState(() {
        _status = 'Opted out of push notifications';
      });
      await _checkOneSignalStatus();
    } catch (e) {
      setState(() {
        _status = 'Error opting out: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneSignal Test'),
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
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
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Player ID Card
            if (_playerId != null) ...[
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
                      'Player ID (OneSignal)',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _playerId!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Status',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _permissionGranted ? Icons.check_circle : Icons.cancel,
                        color: _permissionGranted ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Permission: ${_permissionGranted ? "Granted" : "Not Granted"}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _isSubscribed ? Icons.check_circle : Icons.cancel,
                        color: _isSubscribed ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Subscribed: ${_isSubscribed ? "Yes" : "No"}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildButton(
              '1. Request Permission',
              _requestPermission,
              Icons.notifications_active,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '2. Get Player ID',
              _getPlayerId,
              Icons.vpn_key,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '3. Opt In',
              _optIn,
              Icons.notifications_on,
            ),
            const SizedBox(height: 8),
            _buildButton(
              '4. Opt Out',
              _optOut,
              Icons.notifications_off,
            ),
            const SizedBox(height: 8),
            _buildButton(
              'Refresh Status',
              _checkOneSignalStatus,
              Icons.refresh,
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
        onPressed: onPressed,
        icon: Icon(icon),
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
