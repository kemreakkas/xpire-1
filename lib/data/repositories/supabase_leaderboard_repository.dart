import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/challenge_leaderboard_entry.dart';
import '../models/weekly_leaderboard_entry.dart';

/// Fetches challenge and weekly leaderboards from Supabase views.
class SupabaseLeaderboardRepository {
  SupabaseLeaderboardRepository();

  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  /// Challenge leaderboard: top 10 + full list for current user rank.
  /// Sort: completed_days desc, joined_at asc.
  /// Returns up to 10 for display; [currentUserRank] is set if current user is not in top 10.
  Future<
    ({
      List<ChallengeLeaderboardEntry> top10,
      ChallengeLeaderboardEntry? currentUserEntry,
    })
  >
  getChallengeLeaderboard(String challengeId) async {
    if (!SupabaseConfig.isConfigured) {
      return (top10: <ChallengeLeaderboardEntry>[], currentUserEntry: null);
    }
    final client = _client;
    if (client == null) {
      return (top10: <ChallengeLeaderboardEntry>[], currentUserEntry: null);
    }
    try {
      List<dynamic> raw;
      try {
        raw =
            await client
                    .from('challenge_participants')
                    .select('*, users(username, full_name, is_premium)')
                    .eq('challenge_id', challengeId)
                    .order('completed_days', ascending: false)
                    .order('joined_at', ascending: true)
                as List<dynamic>;
      } catch (_) {
        raw =
            await client
                    .from('challenge_participants')
                    .select()
                    .eq('challenge_id', challengeId)
                    .order('completed_days', ascending: false)
                    .order('joined_at', ascending: true)
                as List<dynamic>;
      }
      final list = raw.whereType<Map<String, dynamic>>().toList();
      final entries = <ChallengeLeaderboardEntry>[];
      for (var i = 0; i < list.length; i++) {
        entries.add(_challengeEntryFromRow(list[i], i + 1));
      }
      final top10 = entries.take(10).toList();
      final uid = client.auth.currentUser?.id;
      ChallengeLeaderboardEntry? currentUserEntry;
      if (uid != null) {
        final idx = entries.indexWhere((e) => e.userId == uid);
        if (idx >= 0) {
          currentUserEntry = _challengeEntryFromRow(list[idx], idx + 1);
        }
      }
      return (top10: top10, currentUserEntry: currentUserEntry);
    } catch (e, st) {
      AppLog.error('Challenge leaderboard fetch failed', e, st);
      return (top10: <ChallengeLeaderboardEntry>[], currentUserEntry: null);
    }
  }

  ChallengeLeaderboardEntry _challengeEntryFromRow(
    Map<String, dynamic> row,
    int position,
  ) {
    final userId = row['user_id'] as String? ?? '';
    String username = _formatUsername(null, userId);
    final usersRow = row['users'];
    bool isPremium = false;
    if (usersRow is Map<String, dynamic>) {
      final raw = usersRow['username'] ?? usersRow['full_name'];
      username = _formatUsername(raw as String?, userId);
      isPremium = usersRow['is_premium'] == true;
    }
    final completedDays = (row['completed_days'] as num?)?.toInt() ?? 0;
    final joinedAt = row['joined_at'] != null
        ? DateTime.parse(row['joined_at'] as String)
        : DateTime.now();
    return ChallengeLeaderboardEntry(
      position: position,
      userId: userId,
      username: username,
      completedDays: completedDays,
      joinedAt: joinedAt,
      isPremium: isPremium,
    );
  }

  /// Global leaderboard: top 20. Order by total_xp desc.
  Future<List<WeeklyLeaderboardEntry>> getWeeklyLeaderboard() async {
    if (!SupabaseConfig.isConfigured) return [];
    final client = _client;
    if (client == null) return [];
    try {
      const limit = 20;
      List<dynamic> res;
      try {
        res =
            await client
                    .from('global_leaderboard')
                    .select()
                    .order('total_xp', ascending: false)
                    .limit(limit)
                as List<dynamic>;
      } catch (_) {
        res =
            await client
                    .from('users')
                    .select(
                      'id, username, full_name, total_xp, level, streak, is_premium',
                    )
                    .order('total_xp', ascending: false)
                    .limit(limit)
                as List<dynamic>;
      }
      final list = res.whereType<Map<String, dynamic>>();
      var rank = 1;
      return list
          .map((row) => _weeklyEntryFromGlobalLeaderboardRow(row, rank++))
          .toList(growable: false);
    } catch (e, st) {
      AppLog.error('Global leaderboard fetch failed', e, st);
      rethrow;
    }
  }

  WeeklyLeaderboardEntry _weeklyEntryFromGlobalLeaderboardRow(
    Map<String, dynamic> row,
    int rank,
  ) {
    final userId = row['id'] as String? ?? '';
    final rawName = row['username'] ?? row['full_name'];
    final username = _formatUsername(rawName as String?, userId);
    final totalXp = (row['total_xp'] as num?)?.toInt() ?? 0;
    final level = (row['level'] as num?)?.toInt() ?? 1;
    final streak = (row['streak'] as num?)?.toInt() ?? 0;
    final isPremium = row['is_premium'] == true;
    return WeeklyLeaderboardEntry(
      rank: rank,
      userId: userId,
      username: username,
      level: level,
      streak: streak,
      totalXp: totalXp,
      isPremium: isPremium,
    );
  }

  String _formatUsername(String? raw, String fallbackId) {
    if (raw != null && raw.trim().isNotEmpty && raw != fallbackId) {
      return raw.trim();
    }
    if (fallbackId.length >= 5) {
      return 'Üye_${fallbackId.substring(0, 5)}';
    }
    return 'Anonim Üye';
  }
}
