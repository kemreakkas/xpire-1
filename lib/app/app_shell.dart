import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/responsive.dart';
import 'shells/mobile_shell.dart';
import 'shells/web_shell.dart';

/// Chooses layout: WebShell only on web in wide screens; else MobileShell.
/// No native desktop — mobile (Android/iOS) + web (browser) only.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.routerState, required this.child});

  final GoRouterState routerState;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && Responsive.isWebWide(context)) {
      return WebShell(routerState: routerState, child: child);
    }
    return MobileShell(routerState: routerState, child: child);
  }
}
