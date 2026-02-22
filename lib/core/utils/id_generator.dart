import 'dart:math';

/// Utility class for generating secure unique IDs
class IdGenerator {
  static final Random _secureRandom = Random.secure();

  /// Generates a cryptographically secure random ID
  /// Format: timestamp + random suffix for uniqueness
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix =
        _secureRandom.nextInt(1000000).toString().padLeft(6, '0');
    return '${timestamp}_$randomSuffix';
  }

  /// Generates a short ID (for UI purposes only, not for database)
  static String generateShortId() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (_) => chars[_secureRandom.nextInt(chars.length)])
        .join();
  }

  /// Generates a prefixed ID for specific entity types
  static String generatePrefixedId(String prefix) {
    return '${prefix}_${generateId()}';
  }
}
