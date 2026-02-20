/// Utility class for parsing data from various formats
class DataParser {
  /// Parse String with default value
  static String parseString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return defaultValue;
  }

  /// Parse int with default value
  static int parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse bool with default value
  static bool parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    return defaultValue;
  }

  /// Parse DateTime
  static DateTime parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  /// Parse nullable DateTime
  static DateTime? parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.parse(value);
    return null;
  }

  /// Parse List<String>
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Parse enum from string
  static T? parseEnum<T>(dynamic value, List<T> enumValues) {
    if (value == null) return null;
    if (value is T) return value;
    if (value is String) {
      try {
        final index =
            enumValues.indexWhere((e) => e.toString().split('.').last == value);
        if (index != -1) return enumValues[index];
      } catch (_) {}
    }
    return null;
  }

  /// Parse enum with default value
  static T parseEnumWithDefault<T>(
      dynamic value, List<T> enumValues, T defaultValue) {
    return parseEnum(value, enumValues) ?? defaultValue;
  }
}
