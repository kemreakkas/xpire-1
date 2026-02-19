import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/challenge_leaderboard_entry.dart';
import '../models/weekly_leaderboard_entry.dart';

/// Fetches challenge and weekly leaderboards from Supabase views.
class SupabaseLeaderboardRepository {
  SupabaseLeaderboardRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Challenge leaderboard: top 10 + full list for current user rank.
  /// Sort: completed_days desc, joined_at asc.
  /// Returns up to 10 for display; [currentUserRank] is set if current user is not in top 10.
  Future<({
    List<ChallengeLeaderboardEntry> top10,
    ChallengeLeaderboardEntry? currentUserEntry,
  })> getChallengeLeaderboard(String challengeId) async {
    if (!SupabaseConfig.isConfigured) {
      return (top10: <ChallengeLeaderboardEntry>[], currentUserEntry: null);
    }
    try {
      List<dynamic> raw;
      try {
        raw = await _client
            .from('challenge_participants')
            .select('*, users(username, full_name)')
            .eq('challenge_id', challengeId)
            .order('completed_days', ascending: false)
            .order('joined_at', ascending: true) as List<dynamic>;
      } catch (_) {
        raw = await _client
            .from('challenge_participants')
            .select()
            .eq('challenge_id', challengeId)
            .order('completed_days', ascending: false)
            .order('joined_at', ascending: true) as List<dynamic>;
      }
      final list = raw.whereType<Map<String, dynamic>>().toList();
      final entries = <ChallengeLeaderboardEntry>[];
      for (var i = 0; i < list.length; i++) {
        entries.add(_challengeEntryFromRow(list[i], i + 1));
      }
      final top10 = entries.take(10).toList();
      final uid = _client.auth.currentUser?.id;
      ChallengeLeaderboardEntry? currentUserEntry;
      if (uid != null) {
        final idx = entries.indexWhere((e) => e.userId == uid);
        if (idx >= 0) {
          currentUserEntry = _challengeEntryFromRow(
            list[idx],
            idx + 1,
          );
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
    String username = userId;
    final usersRow = row['users'];
    if (usersRow is Map<String, dynamic>) {
      final raw = usersRow['username'] ?? usersRow['full_name'];
      if (raw is String && raw.isNotEmpty) username = raw;
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
    );
  }

  /// Weekly global leaderboard: top 20. Order by weekly_xp desc.
  Future<List<WeeklyLeaderboardEntry>> getWeeklyLeaderboard() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      const limit = 20;
      final res = await _client
          .from('weekly_leaderboard')
          .select()
          .order('weekly_xp', ascending: false)
          .limit(limit);
      final list = (res as List<dynamic>).whereType<Map<String, dynamic>>();
      var rank = 1;
      return list
          .map((row) => _weeklyEntryFromRow(row, rank++))
          .toList(growable: false);
    } catch (e, st) {
      AppLog.error('Weekly leaderboard fetch failed', e, st);
      return [];
    }
  }

  WeeklyLeaderboardEntry _weeklyEntryFromRow(
    Map<String, dynamic> row,
    int rank,
  ) {
    final userId = row['user_id'] as String? ?? '';
    final rawName = row['username'] ?? row['display_name'] ?? userId;
    final username = rawName is String ? rawName : userId;
    final weeklyXp = (row['weekly_xp'] as num?)?.toInt() ?? 0;
    return WeeklyLeaderboardEntry(
      rank: rank,
      userId: userId,
      username: username,
      weeklyXp: weeklyXp,
    );
  }
}
