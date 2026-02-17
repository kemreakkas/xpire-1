import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_env.dart';
import '../core/ui/app_theme.dart';
import '../state/providers.dart';

class XpireApp extends ConsumerWidget {
  const XpireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppEnv.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light, // not used for MVP (dark-only)
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
