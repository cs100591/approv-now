import 'package:flutter/material.dart';

/// App Spacing following 8-point grid system
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4dp)
  static const double unit = 4;

  // Spacing values
  static const double xxs = unit; // 4
  static const double xs = unit * 2; // 8
  static const double sm = unit * 3; // 12
  static const double md = unit * 4; // 16
  static const double lg = unit * 6; // 24
  static const double xl = unit * 8; // 32
  static const double xxl = unit * 12; // 48

  // Common paddings
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // Horizontal padding
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: md,
  );

  // Vertical padding
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(
    vertical: md,
  );
}
