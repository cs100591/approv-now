import 'package:flutter/material.dart';
import '../../core/utils/mock_data_generator.dart';
import '../../modules/template/template_repository.dart';
import '../../modules/request/request_repository.dart';
import '../../core/services/supabase_service.dart';

/// Screen to generate mock data for development
class MockDataScreen extends StatefulWidget {
  const MockDataScreen({super.key});

  @override
  State<MockDataScreen> createState() => _MockDataScreenState();
}

class _MockDataScreenState extends State<MockDataScreen> {
  bool _isGenerating = false;
  String _status = '';
  int _progress = 0;
  int _total = 0;

  Future<void> _generateMockData() async {
    setState(() {
      _isGenerating = true;
      _status = 'Generating templates...';
      _progress = 0;
    });

    try {
      final supabaseService = SupabaseService();
      final templateRepo = TemplateRepository(supabase: supabaseService);
      final requestRepo = RequestRepository(supabase: supabaseService);

      // Generate templates
      final templates = MockDataGenerator.generateTemplates();
      _total = templates.length;

      for (final template in templates) {
        await templateRepo.createTemplate(template);
        setState(() {
          _progress++;
          _status = 'Created template: ${template.name}';
        });
      }

      // Generate requests
      setState(() {
        _status = 'Generating approval requests...';
        _progress = 0;
      });

      final requests = MockDataGenerator.generateRequests(templates);
      _total = requests.length;

      for (final request in requests) {
        await requestRepo.createRequest(request);
        setState(() {
          _progress++;
          _status = 'Created request: ${request.templateName}';
        });
      }

      setState(() {
        _status = '✅ Mock data generated successfully!';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mock data generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Mock Data'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mock Data Generator',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate sample templates and approval requests for testing.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // What will be generated
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will create:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildItem('📋 5 Templates', [
                    '• Expense Reimbursement (2 approval levels)',
                    '• Leave Request (2 approval levels)',
                    '• Purchase Order (3 approval levels)',
                    '• Document Review (1 approval level)',
                    '• Travel Request (2 approval levels)',
                  ]),
                  const SizedBox(height: 16),
                  _buildItem('📄 12+ Sample Requests', [
                    '• Pending requests at different levels',
                    '• Approved requests with action history',
                    '• Rejected requests with comments',
                    '• Various statuses and scenarios',
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will add data to your current workspace. Make sure you\'re in a test environment.',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Progress indicator
            if (_isGenerating) ...[
              LinearProgressIndicator(
                value: _total > 0 ? _progress / _total : null,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateMockData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating...', style: TextStyle(fontSize: 18)),
                        ],
                      )
                    : const Text(
                        'Generate Mock Data',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Success/error status
            if (!_isGenerating && _status.isNotEmpty)
              Center(
                child: Text(
                  _status,
                  style: TextStyle(
                    fontSize: 16,
                    color: _status.contains('✅')
                        ? Colors.green
                        : _status.contains('❌')
                            ? Colors.red
                            : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...details.map((d) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                d,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            )),
      ],
    );
  }
}
