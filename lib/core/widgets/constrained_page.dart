import 'package:flutter/material.dart';

/// A widget that constrains its child's width while allowing it to expand vertically.
/// Use this to create centered, width-constrained content for larger screens.
class ConstrainedPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedPage({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
