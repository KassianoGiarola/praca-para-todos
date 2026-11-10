import '../utils/json_helpers.dart';
import 'muscle_group.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.defaultSets,
    required this.defaultReps,
    required this.restSeconds,
    required this.instructions,
    required this.createdAt,
    required this.updatedAt,
    this.defaultLoadKg,
    this.mediaUrl,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String equipment;
  final int defaultSets;
  final int defaultReps;
  final double? defaultLoadKg;
  final int restSeconds;
  final String instructions;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasMedia => mediaUrl != null && mediaUrl!.trim().isNotEmpty;
  bool get hasThumbnail =>
      thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;

  Exercise copyWith({
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    String? equipment,
    int? defaultSets,
    int? defaultReps,
    double? defaultLoadKg,
    bool clearDefaultLoad = false,
    int? restSeconds,
    String? instructions,
    String? mediaUrl,
    bool clearMediaUrl = false,
    String? thumbnailUrl,
    bool clearThumbnailUrl = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultLoadKg: clearDefaultLoad
          ? null
          : defaultLoadKg ?? this.defaultLoadKg,
      restSeconds: restSeconds ?? this.restSeconds,
      instructions: instructions ?? this.instructions,
      mediaUrl: clearMediaUrl ? null : mediaUrl ?? this.mediaUrl,
      thumbnailUrl: clearThumbnailUrl
          ? null
          : thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup.id,
      'equipment': equipment,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultLoadKg': defaultLoadKg,
      'restSeconds': restSeconds,
      'instructions': instructions,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      muscleGroup: muscleGroupFromId(map['muscleGroup']?.toString()),
      equipment: map['equipment']?.toString() ?? '',
      defaultSets: intFromJson(map['defaultSets'], fallback: 3),
      defaultReps: intFromJson(map['defaultReps'], fallback: 10),
      defaultLoadKg: nullableDoubleFromJson(map['defaultLoadKg']),
      restSeconds: intFromJson(map['restSeconds'], fallback: 60),
      instructions: map['instructions']?.toString() ?? '',
      mediaUrl: map['mediaUrl']?.toString(),
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      createdAt: dateFromJson(map['createdAt']),
      updatedAt: dateFromJson(map['updatedAt']),
    );
  }
}
