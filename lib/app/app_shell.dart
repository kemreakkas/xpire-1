import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/responsive.dart';
import 'shells/mobile_shell.dart';
import 'shells/web_shell.dart';

/// Chooses layout by breakpoint. No business logic.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.routerState,
    required this.child,
  });

  final GoRouterState routerState;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return WebShell(routerState: routerState, child: child);
    }
    return MobileShell(routerState: routerState, child: child);
  }
}
