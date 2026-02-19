import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/goal.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

/// Profile repository: Supabase-first with Hive cache. When Supabase is not
/// configured, uses Hive only (offline mode).
class SupabaseProfileRepository implements IProfileRepository {
  SupabaseProfileRepository(this._box);

  static const String _cacheKey = 'me';

  final Box<UserProfile> _box;

  SupabaseClient get _client => Supabase.instance.client;

  Future<UserProfile> loadOrCreate() async {
    if (!SupabaseConfig.isConfigured) {
      final existing = _box.get(_cacheKey);
      if (existing != null) return existing;
      final created = UserProfile.initial();
      await _box.put(_cacheKey, created);
      AppLog.info('Profile created (offline)');
      return created;
    }

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      final existing = _box.get(_cacheKey);
      if (existing != null) return existing;
      final created = UserProfile.initial();
      await _box.put(_cacheKey, created);
      return created;
    }

    try {
      final res = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res != null) {
        final profile = _profileFromRow(res);
        await _box.put(_cacheKey, profile);
        return profile;
      }

      final email = _client.auth.currentUser?.email;
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'level': 1,
        'xp': 0,
        'total_xp': 0,
        'streak': 0,
        'last_active_date': null,
        'is_premium': false,
        'freeze_credits': 0,
        'last_freeze_reset': null,
        'subscription_status': 'free',
        'full_name': null,
        'username': null,
        'age': null,
        'occupation': null,
        'focus_category': null,
        'onboarding_completed': false,
        'reminder_enabled': true,
        'reminder_time': '20:00',
        'last_notification_sent': null,
      });
      final created = UserProfile.initial();
      await _box.put(_cacheKey, created);
      AppLog.info('User row created');
      return created;
    } catch (e, st) {
      AppLog.error('Profile fetch failed', e, st);
      final cached = _box.get(_cacheKey);
      if (cached != null) return cached;
      final fallback = UserProfile.initial();
      await _box.put(_cacheKey, fallback);
      return fallback;
    }
  }

  UserProfile? readSync() => _box.get(_cacheKey);

  Future<void> save(UserProfile profile) async {
    await _box.put(_cacheKey, profile);

    if (!SupabaseConfig.isConfigured) return;
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('users').update({
        'level': profile.level,
        'xp': profile.currentXp,
        'total_xp': profile.totalXp,
        'streak': profile.streak,
        'last_active_date': profile.lastActiveDate.millisecondsSinceEpoch == 0
            ? null
            : profile.lastActiveDate.toIso8601String(),
        'is_premium': profile.isPremium,
        'freeze_credits': profile.freezeCredits,
        'last_freeze_reset': profile.lastFreezeReset?.toIso8601String(),
        'full_name': profile.fullName,
        'username': profile.username,
        'age': profile.age,
        'occupation': profile.occupation,
        'focus_category': profile.focusCategory?.name,
        'onboarding_completed': profile.onboardingCompleted,
        'reminder_enabled': profile.reminderEnabled,
        'reminder_time': _toTimeString(profile.reminderTime),
        'last_notification_sent': profile.lastNotificationSent != null
            ? _toDateString(profile.lastNotificationSent!)
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e, st) {
      AppLog.error('Profile save failed', e, st);
      rethrow;
    }
  }

  UserProfile _profileFromRow(Map<String, dynamic> row) {
    final lastActive = row['last_active_date'];
    final lastFreeze = row['last_freeze_reset'];
    final focusCat = row['focus_category'] as String?;
    GoalCategory? focusCategory;
    if (focusCat != null && focusCat.isNotEmpty) {
      try {
        focusCategory = GoalCategory.values.byName(focusCat);
      } catch (_) {}
    }
    return UserProfile(
      level: (row['level'] as num?)?.toInt() ?? 1,
      currentXp: (row['xp'] as num?)?.toInt() ?? 0,
      totalXp: (row['total_xp'] as num?)?.toInt() ?? 0,
      streak: (row['streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: lastActive != null
          ? DateTime.parse(lastActive as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
      isPremium: (row['is_premium'] as bool?) ?? false,
      subscriptionStatus: row['subscription_status'] as String?,
      freezeCredits: (row['freeze_credits'] as num?)?.toInt() ?? 0,
      lastFreezeReset:
          lastFreeze != null ? DateTime.parse(lastFreeze as String) : null,
      fullName: row['full_name'] as String?,
      username: row['username'] as String?,
      age: (row['age'] as num?)?.toInt(),
      occupation: row['occupation'] as String?,
      focusCategory: focusCategory,
      onboardingCompleted: (row['onboarding_completed'] as bool?) ?? false,
      reminderEnabled: (row['reminder_enabled'] as bool?) ?? true,
      reminderTime: _fromTimeRow(row['reminder_time']) ?? '20:00',
      lastNotificationSent: _fromDateRow(row['last_notification_sent']),
    );
  }

  static String _toTimeString(String hhmm) {
    if (hhmm.length >= 5 && hhmm[2] == ':') return hhmm;
    return '20:00';
  }

  static String? _fromTimeRow(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.length >= 5) return s.substring(0, 5);
    return null;
  }

  static String? _toDateString(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime? _fromDateRow(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }
}
