import 'package:flutter/material.dart';

/// Single source of responsive breakpoints.
/// Mobile (phones) vs Web-wide (browser at large width). No native desktop.
class Breakpoints {
  /// Below this width: mobile UI (phones, narrow browser).
  static const double mobile = 768;
}

/// Layout constants for web SaaS UI (wide browser only).
abstract final class Responsive {
  /// Max width for main content area in WebShell.
  static const double maxContentWidth = 1100;

  /// Fixed width of the web sidebar (side nav).
  static const double sideNavWidth = 260;

  static double _width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// True when viewport width < 768 (phones, narrow browser).
  static bool isMobile(BuildContext context) =>
      _width(context) < Breakpoints.mobile;

  /// True when viewport width >= 768 (wide browser; web SaaS layout).
  static bool isWebWide(BuildContext context) =>
      _width(context) >= Breakpoints.mobile;
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
