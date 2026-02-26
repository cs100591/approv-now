import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';

/// Model for user notification settings
class NotificationSettings {
  final String userId;
  final bool emailNotificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettings({
    required this.userId,
    required this.emailNotificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      userId: json['user_id'] as String,
      emailNotificationsEnabled:
          json['email_notifications_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email_notifications_enabled': emailNotificationsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationSettings copyWith({
    String? userId,
    bool? emailNotificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      userId: userId ?? this.userId,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Repository for managing user notification settings
class NotificationSettingsRepository {
  final SupabaseService _supabase;

  NotificationSettingsRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Get notification settings for a user
  /// Returns null if settings don't exist (user hasn't set preferences yet)
  Future<NotificationSettings?> getUserSettings(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_notification_settings')
          .select()
          .eq('user_id', userId)
          .single();

      return NotificationSettings.fromJson(response);
    } catch (e) {
      // Settings not found - this is normal for new users
      AppLogger.info('No notification settings found for user: $userId');
      return null;
    }
  }

  /// Create or update notification settings for a user
  Future<NotificationSettings> updateSettings({
    required String userId,
    required bool emailNotificationsEnabled,
  }) async {
    try {
      final response = await _supabase.client
          .from('user_notification_settings')
          .upsert({
            'user_id': userId,
            'email_notifications_enabled': emailNotificationsEnabled,
          })
          .select()
          .single();

      AppLogger.info(
          'Updated notification settings for user: $userId, email_enabled: $emailNotificationsEnabled');

      return NotificationSettings.fromJson(response);
    } catch (e) {
      AppLogger.error(
          'Failed to update notification settings for user: $userId', e);
      rethrow;
    }
  }

  /// Check if email notifications are enabled for a user
  /// Returns false if settings don't exist or are disabled
  Future<bool> isEmailNotificationsEnabled(String userId) async {
    try {
      final settings = await getUserSettings(userId);
      return settings?.emailNotificationsEnabled ?? false;
    } catch (e) {
      AppLogger.warning(
          'Error checking email notification settings for user: $userId', e);
      return false;
    }
  }

  /// Create default settings for a new user (email disabled by default)
  Future<NotificationSettings> createDefaultSettings(String userId) async {
    return await updateSettings(
      userId: userId,
      emailNotificationsEnabled: false,
    );
  }
}
