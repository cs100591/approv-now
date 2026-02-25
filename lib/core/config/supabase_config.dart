// Supabase Configuration
// Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
//
// IMPORTANT: For production builds, you MUST set these via --dart-define:
//
// Production build:
//   flutter build ios --release \
//     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=your_anon_key
//
// For development, you can use the fallback values below.
// WARNING: Remove fallback values before production release!

class SupabaseConfig {
  /// Supabase project URL
  static String get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    // Fallback for development only
    // TODO: Remove this fallback before production release!
    if (url.isEmpty) {
      return 'https://poaontiyougqfzmzxerf.supabase.co';
    }
    return url;
  }

  /// Supabase anon key (public key)
  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    // Fallback for development only
    // TODO: Remove this fallback before production release!
    if (key.isEmpty) {
      return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYW9udGl5b3VncWZ6bXp4ZXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2MDQ2ODQsImV4cCI6MjA4NzE4MDY4NH0.o0xQNrVDzly3B2rvbE5y12Sazd6HVct148Z-mJRKn8M';
    }
    return key;
  }

  /// Verify configuration is properly set
  /// Returns true if using environment variables (production mode)
  static bool get isProductionConfig {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    return url.isNotEmpty && key.isNotEmpty;
  }

  /// Log configuration status
  static void logConfiguration() {
    if (isProductionConfig) {
      print('✅ Supabase: Using production configuration from environment');
    } else {
      print('⚠️  Supabase: Using fallback configuration (DEVELOPMENT MODE)');
    }
  }

  // Table names
  static const String workspacesTable = 'workspaces';
  static const String templatesTable = 'templates';
  static const String requestsTable = 'requests';
  static const String profilesTable = 'profiles';
  static const String subscriptionsTable = 'subscriptions';
  static const String notificationsTable = 'notifications';

  // Storage buckets
  static const String attachmentsBucket = 'attachments';
  static const String logosBucket = 'logos';

  // Timeouts (in seconds)
  static const int defaultTimeout = 10;
  static const int uploadTimeout = 30;
}
