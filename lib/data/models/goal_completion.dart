import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

@immutable
class GoalCompletion {
  const GoalCompletion({
    required this.id,
    required this.goalId,
    required this.date,
    required this.earnedXp,
    this.completedAt,
  });

  final String id;
  final String goalId;
  final DateTime date; // date-only
  final int earnedXp;
  /// Exact timestamp when completed (for advanced stats / weekly grouping).
  final DateTime? completedAt;

  GoalCompletion copyWith({
    String? id,
    String? goalId,
    DateTime? date,
    int? earnedXp,
    DateTime? completedAt,
  }) {
    return GoalCompletion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      date: date ?? this.date,
      earnedXp: earnedXp ?? this.earnedXp,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class GoalCompletionAdapter extends TypeAdapter<GoalCompletion> {
  @override
  int get typeId => 3;

  @override
  GoalCompletion read(BinaryReader reader) {
    final id = reader.readString();
    final goalId = reader.readString();
    final dateMillis = reader.readInt();
    final earnedXp = reader.readInt();
    DateTime? completedAt;
    try {
      final ms = reader.readInt();
      completedAt = ms <= 0 ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {}
    return GoalCompletion(
      id: id,
      goalId: goalId,
      date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      earnedXp: earnedXp,
      completedAt: completedAt,
    );
  }

  @override
  void write(BinaryWriter writer, GoalCompletion obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.goalId)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeInt(obj.earnedXp)
      ..writeInt(obj.completedAt?.millisecondsSinceEpoch ?? -1);
  }
}
