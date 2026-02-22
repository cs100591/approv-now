import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    Widget? tablet,
    Widget? desktop,
  })  : tablet = tablet ?? mobile,
        desktop = desktop ?? tablet ?? mobile;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A standard split view widget for tablet/desktop
class SplitView extends StatelessWidget {
  final Widget menu;
  final Widget content;
  final double menuWidth;
  final double contentMaxWidth;

  const SplitView({
    super.key,
    required this.menu,
    required this.content,
    this.menuWidth = 350.0,
    this.contentMaxWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: menuWidth,
          child: menu,
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}
