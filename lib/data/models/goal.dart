import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// MVP: 8 primary categories for general growth. general kept for backward compat.
enum GoalCategory {
  fitness,
  study,
  work,
  focus,
  mind,
  health,
  finance,
  selfGrowth,
  general,
}

enum GoalDifficulty { easy, medium, hard }

@immutable
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.baseXp,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String title;
  final GoalCategory category;
  final GoalDifficulty difficulty;
  final int baseXp;
  final bool isActive;
  final DateTime createdAt;

  Goal copyWith({
    String? id,
    String? title,
    GoalCategory? category,
    GoalDifficulty? difficulty,
    int? baseXp,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      baseXp: baseXp ?? this.baseXp,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  int get typeId => 2;

  @override
  Goal read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final categoryIndex = reader.readInt();
    final difficultyIndex = reader.readInt();
    final baseXp = reader.readInt();
    final isActive = reader.readBool();
    final createdAtMillis = reader.readInt();

    return Goal(
      id: id,
      title: title,
      category: GoalCategory.values[categoryIndex],
      difficulty: GoalDifficulty.values[difficultyIndex],
      baseXp: baseXp,
      isActive: isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeInt(obj.category.index)
      ..writeInt(obj.difficulty.index)
      ..writeInt(obj.baseXp)
      ..writeBool(obj.isActive)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
