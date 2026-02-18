import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'responsive.dart';

/// Use for main app navigation. On web (wide) uses [context.go], on mobile uses [context.push].
void goOrPush(BuildContext context, String path) {
  if (kIsWeb && Responsive.isWebWide(context)) {
    context.go(path);
  } else {
    context.push(path);
  }
}

/// True when AppBar should show back/leading (mobile). False on web wide layout.
bool shouldShowAppBarLeading(BuildContext context) {
  return !(kIsWeb && Responsive.isWebWide(context));
}

/// Returns a page with no transition on web (wide), normal Material transition on mobile.
/// Use in GoRoute [pageBuilder] so web has no slide/open animations.
Page<void> buildAppPage(BuildContext context, GoRouterState state, Widget child) {
  if (kIsWeb && Responsive.isWebWide(context)) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (_, __, ___, c) => c,
    );
  }
  return MaterialPage<void>(key: state.pageKey, child: child);
}
