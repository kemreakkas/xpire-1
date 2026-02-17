import 'package:flutter/foundation.dart';

class AppEnv {
  static const String appName = 'Xpire';

  static const String baseUrl = '';

  static bool get isWeb => kIsWeb;

  static String get buildMode {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }
}
