import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Firebase 测试组件
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Initializing...';
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  Future<void> _testFirebase() async {
    try {
      // 1. 测试 Firebase Core 初始化
      setState(() => _status = 'Testing Firebase Core...');
      await Future.delayed(const Duration(seconds: 1));

      if (Firebase.apps.isEmpty) {
        setState(() {
          _status = '❌ Firebase not initialized';
          _error = 'Firebase.apps is empty';
        });
        return;
      }

      final app = Firebase.app();
      setState(() => _status = '✅ Firebase Core initialized\n'
          'App: ${app.name}\n'
          'Options: ${app.options.projectId}');

      // 2. 测试 Firebase Auth
      setState(() => _status += '\n\nTesting Firebase Auth...');
      await Future.delayed(const Duration(seconds: 1));

      final auth = FirebaseAuth.instance;
      setState(() => _status += '\n✅ Firebase Auth available');

      // 3. 检查当前用户
      final user = auth.currentUser;
      if (user != null) {
        setState(
            () => _status += '\n📱 Current user: ${user.email ?? user.uid}');
      } else {
        setState(() => _status += '\n📱 No user logged in');
      }

      setState(() => _isInitialized = true);
    } catch (e, stackTrace) {
      setState(() {
        _status = '❌ Error occurred';
        _error = '$e\n\n$stackTrace';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testFirebase,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isInitialized)
              const LinearProgressIndicator()
            else
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 20),
            Text(
              'Status:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                'Error:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.red,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (_isInitialized)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back to App'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
