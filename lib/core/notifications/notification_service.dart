import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Daily reminder: local notifications on mobile only. Web uses in-app banner.
class NotificationService {
  NotificationService();

  static const int _dailyReminderId = 0;
  static const String _channelId = 'xpire_reminder';
  static const String _channelName = 'Xpire Reminders';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Initialize and request permissions. Call once at app start (mobile only).
  Future<void> initialize() async {
    if (!isSupported) return;
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Daily reminder to complete your goals',
          importance: Importance.defaultImportance,
        ),
      );
    }

    try {
      tz_data.initializeTimeZones();
      final localName = tz.local.name;
      if (localName.isEmpty) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (_) {}

    _initialized = true;
  }

  /// Request notification permission (iOS). No-op on Android.
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    if (!_initialized) await initialize();
    if (Platform.isIOS) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final result = await impl?.requestPermissions(alert: true, badge: true);
      return result == true;
    }
    return true;
  }

  /// Build body text: include streak when > 0 (Phase 6).
  static String bodyForStreak(int streak) {
    if (streak > 0) {
      return "You're on a $streak-day streak. Keep it alive.";
    }
    return "You have XP waiting today. Don't break your streak.";
  }

  /// Schedule daily reminder at given time (HH:mm). Replaces any existing.
  Future<void> scheduleDailyReminder({
    required String reminderTime,
    int streak = 0,
  }) async {
    if (!isSupported) return;
    if (!_initialized) await initialize();

    await cancelDailyReminder();

    final parts = reminderTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 20 : 20;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily reminder to complete your goals',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Xpire Reminder',
      bodyForStreak(streak),
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel the daily reminder.
  Future<void> cancelDailyReminder() async {
    if (!isSupported) return;
    await _plugin.cancel(_dailyReminderId);
  }
}
