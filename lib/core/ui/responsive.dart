import 'package:flutter/material.dart';

/// Single source of responsive breakpoints.
/// mobile: < 768, tablet: 768–1024, desktop: > 1024
class Breakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  // Legacy aliases for compatibility
  static const double sm = 600;
  static const double md = 840;
  static const double lg = 1200;
}

/// Layout constants for desktop/SaaS UI.
class ResponsiveLayout {
  static const double contentMaxWidth = 1100;
  static const double sidebarWidth = 260;
}

/// Responsive helpers. Use [BuildContext] for MediaQuery width.
abstract final class Responsive {
  static double _width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) =>
      _width(context) < Breakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final w = _width(context);
    return w >= Breakpoints.mobile && w < Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      _width(context) >= Breakpoints.tablet;
}

/// Centers content with a max width constraint. Use for page content.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
