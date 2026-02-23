import 'package:supabase/supabase.dart';
import 'dart:io';

Future<void> main() async {
  final client = SupabaseClient(
    'https://poaontiyougqfzmzxerf.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYW9udGl5b3VncWZ6bXp4ZXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2MDQ2ODQsImV4cCI6MjA4NzE4MDY4NH0.o0xQNrVDzly3B2rvbE5y12Sazd6HVct148Z-mJRKn8M',
  );

  print('Fetching requests...');
  try {
    final response = await client.from('requests').select('*');
    for (var req in response) {
      print('ID: ${req['id']}');
      print('Status: ${req['status']}');
      print('Level: ${req['current_level']}');
      print('Approvers: ${req['current_approver_ids']}');
      print('Submitter: ${req['submitted_by']}');
      print('---');
    }
  } catch (e) {
    print(e);
  }
}
