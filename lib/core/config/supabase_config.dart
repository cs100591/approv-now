// Supabase Configuration
// Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
// IMPORTANT: For production, set these values via --dart-define or environment variables

class SupabaseConfig {
  // Supabase project URL - Loaded from environment
  static String get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    // Fallback to default for development
    return url.isNotEmpty ? url : 'https://poaontiyougqfzmzxerf.supabase.co';
  }

  // Supabase anon key (public key) - Loaded from environment
  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    // Fallback to default for development
    return key.isNotEmpty
        ? key
        : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYW9udGl5b3VncWZ6bXp4ZXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2MDQ2ODQsImV4cCI6MjA4NzE4MDY4NH0.o0xQNrVDzly3B2rvbE5y12Sazd6HVct148Z-mJRKn8M';
  }

  // Table names
  static const String workspacesTable = 'workspaces';
  static const String templatesTable = 'templates';
  static const String requestsTable = 'requests';
  static const String profilesTable = 'profiles';

  // Storage buckets
  static const String attachmentsBucket = 'attachments';
  static const String logosBucket = 'logos';

  // Timeouts (in seconds)
  static const int defaultTimeout = 10;
  static const int uploadTimeout = 30;
}
