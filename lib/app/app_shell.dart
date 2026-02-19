import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/responsive.dart';
import '../state/providers.dart';
import 'shells/mobile_shell.dart';
import 'shells/web_shell.dart';

/// Chooses layout by viewport width. Responsive on web: resizing the browser
/// switches the shell (wide → WebShell, narrow → MobileShell).
/// - kIsWeb && width >= 768: WebShell (sidebar, topbar, no back arrow).
/// - Otherwise: MobileShell (bottom nav, AppBar).
/// No native desktop — mobile (Android/iOS) + web (browser) only.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.routerState, required this.child});

  final GoRouterState routerState;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncReminder());
  }

  void _syncReminder() {
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;
    final notificationService = ref.read(notificationServiceProvider);
    if (!notificationService.isSupported) return;
    if (profile.reminderEnabled) {
      notificationService.scheduleDailyReminder(
        reminderTime: profile.reminderTime,
        streak: profile.streak,
      );
    } else {
      notificationService.cancelDailyReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileControllerProvider, (prev, next) {
      next.whenData((_) => _syncReminder());
    });
    if (kIsWeb && Responsive.isWebWide(context)) {
      return WebShell(routerState: widget.routerState, child: widget.child);
    }
    return MobileShell(routerState: widget.routerState, child: widget.child);
  }
}
