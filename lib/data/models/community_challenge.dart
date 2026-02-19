import 'package:flutter/foundation.dart';

/// Community challenge from Supabase `challenges` table.
@immutable
class CommunityChallenge {
  const CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.rewardXp,
    this.createdBy,
    required this.isPublic,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final int durationDays;
  final int rewardXp;
  final String? createdBy;
  final bool isPublic;
  final DateTime? createdAt;
}
