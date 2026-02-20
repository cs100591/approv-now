import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for parsing Firestore data types
class FirestoreParser {
  /// Parse DateTime from various formats (Timestamp, String, DateTime, null)
  static DateTime parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// Parse nullable DateTime
  static DateTime? parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return null;
  }

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

  /// Parse double with default value
  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Parse bool with default value
  static bool parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    return defaultValue;
  }

  /// Parse List<String> safely
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
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
