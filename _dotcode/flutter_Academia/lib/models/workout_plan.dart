import '../utils/json_helpers.dart';

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.order,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.targetLoadKg,
  });

  final String id;
  final String exerciseId;
  final int order;
  final int sets;
  final int reps;
  final double? targetLoadKg;
  final int restSeconds;

  WorkoutExercise copyWith({
    String? id,
    String? exerciseId,
    int? order,
    int? sets,
    int? reps,
    double? targetLoadKg,
    bool clearTargetLoad = false,
    int? restSeconds,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      targetLoadKg: clearTargetLoad ? null : targetLoadKg ?? this.targetLoadKg,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'order': order,
      'sets': sets,
      'reps': reps,
      'targetLoadKg': targetLoadKg,
      'restSeconds': restSeconds,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id']?.toString() ?? '',
      exerciseId: map['exerciseId']?.toString() ?? '',
      order: intFromJson(map['order']),
      sets: intFromJson(map['sets'], fallback: 3),
      reps: intFromJson(map['reps'], fallback: 10),
      targetLoadKg: nullableDoubleFromJson(map['targetLoadKg']),
      restSeconds: intFromJson(map['restSeconds'], fallback: 60),
    );
  }
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.scheduledWeekdays = const [],
  });

  final String id;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final List<int> scheduledWeekdays;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get totalSets => exercises.fold(0, (sum, item) => sum + item.sets);

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    List<int>? scheduledWeekdays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      scheduledWeekdays: scheduledWeekdays ?? this.scheduledWeekdays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'scheduledWeekdays': scheduledWeekdays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      exercises:
          mapListFromJson(
              map['exercises'],
            ).map(WorkoutExercise.fromMap).toList()
            ..sort((a, b) => a.order.compareTo(b.order)),
      scheduledWeekdays:
          (map['scheduledWeekdays'] as List?)
              ?.whereType<num>()
              .map((value) => value.toInt())
              .toList() ??
          const [],
      createdAt: dateFromJson(map['createdAt']),
      updatedAt: dateFromJson(map['updatedAt']),
    );
  }
}
