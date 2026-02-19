import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'goal.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.level,
    required this.currentXp,
    required this.totalXp,
    required this.streak,
    required this.lastActiveDate,
    required this.isPremium,
    this.subscriptionStatus,
    this.freezeCredits = 0,
    this.lastFreezeReset,
    this.fullName,
    this.username,
    this.age,
    this.occupation,
    this.focusCategory,
    this.onboardingCompleted = false,
    this.reminderEnabled = true,
    this.reminderTime = '20:00',
    this.lastNotificationSent,
  });

  /// Default for a fresh install. All profile fields optional; app works with empty profile.
  factory UserProfile.initial() => UserProfile(
        level: 1,
        currentXp: 0,
        totalXp: 0,
        streak: 0,
        lastActiveDate: DateTime.fromMillisecondsSinceEpoch(0),
        isPremium: false,
        freezeCredits: 0,
        lastFreezeReset: null,
        fullName: null,
        username: null,
        age: null,
        occupation: null,
        focusCategory: null,
        onboardingCompleted: false,
        reminderEnabled: true,
        reminderTime: '20:00',
        lastNotificationSent: null,
      );

  final int level;
  final int currentXp;
  final int totalXp;
  final int streak;
  final DateTime lastActiveDate;
  final bool isPremium;
  /// Server authority: free | active | canceled. Prefer over local isPremium when set.
  final String? subscriptionStatus;
  /// Premium: 1 credit per 7 days; used when streak would break.
  final int freezeCredits;
  /// Last time we granted a freeze credit (7-day window).
  final DateTime? lastFreezeReset;

  /// Optional profile fields. All nullable; no mandatory onboarding.
  final String? fullName;
  final String? username;
  final int? age;
  final String? occupation;
  final GoalCategory? focusCategory;

  /// When false, user sees onboarding on first login; after completion we set true.
  final bool onboardingCompleted;

  /// Daily reminder: enabled by default. Mobile = local notification; web = in-app banner.
  final bool reminderEnabled;
  /// Time of day for reminder, "HH:mm" (e.g. "20:00").
  final String reminderTime;
  /// Last date we sent or cancelled the reminder (used to cancel after first goal of day).
  final DateTime? lastNotificationSent;

  /// True if user has an active premium subscription (server or local).
  bool get isPremiumEffective =>
      subscriptionStatus == 'active' || (subscriptionStatus == null && isPremium);

  UserProfile copyWith({
    int? level,
    int? currentXp,
    int? totalXp,
    int? streak,
    DateTime? lastActiveDate,
    bool? isPremium,
    String? subscriptionStatus,
    int? freezeCredits,
    DateTime? lastFreezeReset,
    String? fullName,
    String? username,
    int? age,
    String? occupation,
    GoalCategory? focusCategory,
    bool? onboardingCompleted,
    bool? reminderEnabled,
    String? reminderTime,
    DateTime? lastNotificationSent,
  }) {
    return UserProfile(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isPremium: isPremium ?? this.isPremium,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      freezeCredits: freezeCredits ?? this.freezeCredits,
      lastFreezeReset: lastFreezeReset ?? this.lastFreezeReset,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      focusCategory: focusCategory ?? this.focusCategory,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      lastNotificationSent: lastNotificationSent ?? this.lastNotificationSent,
    );
  }
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  int get typeId => 1;

  @override
  UserProfile read(BinaryReader reader) {
    final level = reader.readInt();
    final currentXp = reader.readInt();
    final totalXp = reader.readInt();
    final streak = reader.readInt();
    final lastActiveMillis = reader.readInt();
    final isPremium = reader.readBool();
    int freezeCredits = 0;
    DateTime? lastFreezeReset;
    try {
      freezeCredits = reader.readInt();
      final ms = reader.readInt();
      lastFreezeReset = ms < 0 ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {}
    String? fullName;
    String? username;
    int? age;
    String? occupation;
    GoalCategory? focusCategory;
    try {
      final fn = reader.readString();
      fullName = fn.isEmpty ? null : fn;
      final un = reader.readString();
      username = un.isEmpty ? null : un;
      final a = reader.readInt();
      age = a < 0 ? null : a;
      final occ = reader.readString();
      occupation = occ.isEmpty ? null : occ;
      final fc = reader.readInt();
      focusCategory =
          fc < 0 || fc >= GoalCategory.values.length ? null : GoalCategory.values[fc];
    } catch (_) {}
    bool onboardingCompleted = false;
    try {
      onboardingCompleted = reader.readBool();
    } catch (_) {}
    bool reminderEnabled = true;
    String reminderTime = '20:00';
    DateTime? lastNotificationSent;
    try {
      reminderEnabled = reader.readBool();
      reminderTime = reader.readString();
      if (reminderTime.isEmpty) reminderTime = '20:00';
      final sentMs = reader.readInt();
      lastNotificationSent =
          sentMs <= 0 ? null : DateTime.fromMillisecondsSinceEpoch(sentMs);
    } catch (_) {}
    return UserProfile(
      level: level,
      currentXp: currentXp,
      totalXp: totalXp,
      streak: streak,
      lastActiveDate: DateTime.fromMillisecondsSinceEpoch(lastActiveMillis),
      isPremium: isPremium,
      subscriptionStatus: null,
      freezeCredits: freezeCredits,
      lastFreezeReset: lastFreezeReset,
      fullName: fullName,
      username: username,
      age: age,
      occupation: occupation,
      focusCategory: focusCategory,
      onboardingCompleted: onboardingCompleted,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      lastNotificationSent: lastNotificationSent,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeInt(obj.level)
      ..writeInt(obj.currentXp)
      ..writeInt(obj.totalXp)
      ..writeInt(obj.streak)
      ..writeInt(obj.lastActiveDate.millisecondsSinceEpoch)
      ..writeBool(obj.isPremium)
      ..writeInt(obj.freezeCredits)
      ..writeInt(obj.lastFreezeReset?.millisecondsSinceEpoch ?? -1)
      ..writeString(obj.fullName ?? '')
      ..writeString(obj.username ?? '')
      ..writeInt(obj.age ?? -1)
      ..writeString(obj.occupation ?? '')
      ..writeInt(obj.focusCategory?.index ?? -1)
      ..writeBool(obj.onboardingCompleted)
      ..writeBool(obj.reminderEnabled)
      ..writeString(obj.reminderTime)
      ..writeInt(obj.lastNotificationSent?.millisecondsSinceEpoch ?? -1);
  }
}
