import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

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
  });

  /// Default for a fresh install.
  factory UserProfile.initial() => UserProfile(
        level: 1,
        currentXp: 0,
        totalXp: 0,
        streak: 0,
        lastActiveDate: DateTime.fromMillisecondsSinceEpoch(0),
        isPremium: false,
        freezeCredits: 0,
        lastFreezeReset: null,
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
      ..writeInt(obj.lastFreezeReset?.millisecondsSinceEpoch ?? -1);
  }
}
