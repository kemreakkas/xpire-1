import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLog {
  static void debug(String message, [Object? data]) {
    if (kReleaseMode) return;
    _log('DEBUG', message, data);
  }

  static void info(String message, [Object? data]) {
    _log('INFO', message, data);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace: stackTrace);
  }

  static void _log(
    String level,
    String message,
    Object? data, {
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[$level] $message',
      name: 'Xpire',
      error: data,
      stackTrace: stackTrace,
    );
  }
}
