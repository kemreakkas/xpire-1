import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Tracks one active challenge: which challenge and which goal IDs were created for it.
@immutable
class ActiveChallenge {
  const ActiveChallenge({
    required this.challengeId,
    required this.startedAt,
    required this.goalIds,
  });

  final String challengeId;
  final DateTime startedAt;
  final List<String> goalIds;

  ActiveChallenge copyWith({
    String? challengeId,
    DateTime? startedAt,
    List<String>? goalIds,
  }) {
    return ActiveChallenge(
      challengeId: challengeId ?? this.challengeId,
      startedAt: startedAt ?? this.startedAt,
      goalIds: goalIds ?? this.goalIds,
    );
  }
}

class ActiveChallengeAdapter extends TypeAdapter<ActiveChallenge> {
  @override
  int get typeId => 4;

  @override
  ActiveChallenge read(BinaryReader reader) {
    final challengeId = reader.readString();
    final startedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final length = reader.readInt();
    final goalIds = List<String>.generate(length, (_) => reader.readString());
    return ActiveChallenge(
      challengeId: challengeId,
      startedAt: startedAt,
      goalIds: goalIds,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveChallenge obj) {
    writer.writeString(obj.challengeId);
    writer.writeInt(obj.startedAt.millisecondsSinceEpoch);
    writer.writeInt(obj.goalIds.length);
    for (final id in obj.goalIds) {
      writer.writeString(id);
    }
  }
}
