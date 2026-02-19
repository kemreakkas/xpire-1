import 'dart:math';

import 'user_profile_analyzer.dart';

final _rng = Random();

/// 50 rule-based motivation messages in 5 groups. No external API.
class MotivationEngine {
  MotivationEngine._();

  static const List<String> _lowEnergy = [
    "Small steps still count. One tiny win today.",
    "You don't have to be perfect. Just show up.",
    "Rest is part of the plan. Light effort still moves you forward.",
    "Low energy? Pick one thing and call it a win.",
    "Today can be gentle. One goal is enough.",
    "Your best today might look different. That's okay.",
    "Even 5 minutes of progress is progress.",
    "Be kind to yourself. Tomorrow is a new day.",
    "One small action beats zero. You've got this.",
    "Pause if you need to. Then take one step.",
  ];

  static const List<String> _highEnergy = [
    "You're on fire. Channel that energy into one big win.",
    "High energy day! Stack two or three wins.",
    "Momentum is real. Ride it with intention.",
    "Today's the day to push a little harder.",
    "Your streak shows you can do this. Go get it.",
    "Use this energy wisely. One focused block.",
    "You're building something. Keep the rhythm.",
    "Strong days compound. Make today count.",
    "You've got the drive. Point it at one clear goal.",
    "Energy is a gift. Spend it on what matters.",
  ];

  static const List<String> _streakBoost = [
    "Your streak is proof you're consistent. Keep it alive.",
    "Another day, another win. Protect the streak.",
    "You didn't come this far to stop now.",
    "That streak didn't build itself. You did.",
    "One more day. You know the drill.",
    "Streak says you're serious. Show up again today.",
    "Consistency beats intensity. You're living it.",
    "Don't break the chain. One goal today.",
    "Your streak is your reputation. Honor it.",
    "Every day you show up, you get stronger.",
  ];

  static const List<String> _comebackMode = [
    "Today is day one again. That's okay.",
    "Every comeback starts with a single step.",
    "No streak? No problem. Start fresh today.",
    "The best time to start was yesterday. The next best is now.",
    "One goal today. That's your comeback.",
    "You're not starting from zero. You're starting with experience.",
    "Comeback mode: one win, then build from there.",
    "Yesterday doesn't define today. Show up now.",
    "Reset and go. One small win counts.",
    "Your next streak starts with today.",
  ];

  static const List<String> _consistencyReward = [
    "You've been showing up. That's the real win.",
    "Consistency is the superpower. You're using it.",
    "Steady progress beats rare heroics. You're on track.",
    "Your habits are forming. Keep the rhythm.",
    "Another day of small wins. That's how change happens.",
    "You're building trust in yourself. One day at a time.",
    "The middle is where most quit. You're still here.",
    "Regular effort compounds. You're proof.",
    "Not flashy, but reliable. That's you.",
    "Keep the engine running. Today matters.",
  ];

  /// Picks a message based on [profile] and [streak]. Uses streak_boost when
  /// streak > 5, comeback_mode when streak == 0, low_energy when energy is low.
  static String generateMotivation(SmartProfile smartProfile, int streak) {
    final group = _selectGroup(smartProfile, streak);
    final list = _messagesForGroup(group);
    return list[_rng.nextInt(list.length)];
  }

  static MotivationGroup _selectGroup(SmartProfile profile, int streak) {
    if (streak > 5) return MotivationGroup.streakBoost;
    if (streak == 0) return MotivationGroup.comebackMode;
    if (profile.energyLevel == EnergyLevel.low) return MotivationGroup.lowEnergy;
    if (profile.energyLevel == EnergyLevel.high) {
      return MotivationGroup.highEnergy;
    }
    return MotivationGroup.consistencyReward;
  }

  static List<String> _messagesForGroup(MotivationGroup g) {
    return switch (g) {
      MotivationGroup.lowEnergy => _lowEnergy,
      MotivationGroup.highEnergy => _highEnergy,
      MotivationGroup.streakBoost => _streakBoost,
      MotivationGroup.comebackMode => _comebackMode,
      MotivationGroup.consistencyReward => _consistencyReward,
    };
  }
}

enum MotivationGroup {
  lowEnergy,
  highEnergy,
  streakBoost,
  comebackMode,
  consistencyReward,
}
