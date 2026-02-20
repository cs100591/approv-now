import 'package:flutter/material.dart';

/// App Colors following the design system
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Soft White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark Charcoal
  static const Color textSecondary = Color(0xFF64748B); // Slate Grey
  static const Color textHint = Color(0xFF94A3B8); // Light Grey

  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Emerald Green
  static const Color accentLight = Color(0xFF34D399);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Shadow
  static const Color shadow = Color(0x1F000000); // 12% opacity black

  // Dark mode colors (for future use)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
}
