import '../utils/json_helpers.dart';
import 'health_workout_summary.dart';
import 'muscle_group.dart';

enum WorkoutEffort {
  light('light', 'Leve'),
  moderate('moderate', 'Moderado'),
  intense('intense', 'Intenso'),
  veryIntense('very_intense', 'Muito intenso');

  const WorkoutEffort(this.id, this.label);

  final String id;
  final String label;
}

WorkoutEffort? workoutEffortFromId(String? id) {
  if (id == null || id.isEmpty) {
    return null;
  }
  for (final effort in WorkoutEffort.values) {
    if (effort.id == id) {
      return effort;
    }
  }
  return null;
}

class SetLog {
  const SetLog({
    required this.id,
    required this.setNumber,
    required this.reps,
    required this.completedAt,
    this.loadKg,
  });

  final String id;
  final int setNumber;
  final int reps;
  final double? loadKg;
  final DateTime completedAt;

  double get volume => reps * (loadKg ?? 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'setNumber': setNumber,
      'reps': reps,
      'loadKg': loadKg,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      id: map['id']?.toString() ?? '',
      setNumber: intFromJson(map['setNumber']),
      reps: intFromJson(map['reps']),
      loadKg: nullableDoubleFromJson(map['loadKg']),
      completedAt: dateFromJson(map['completedAt']),
    );
  }
}

class SessionExercise {
  const SessionExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.order,
    required this.targetSets,
    required this.targetReps,
    required this.restSeconds,
    required this.sets,
    this.targetLoadKg,
    this.mediaUrl,
    this.thumbnailUrl,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final MuscleGroup muscleGroup;
  final int order;
  final int targetSets;
  final int targetReps;
  final double? targetLoadKg;
  final int restSeconds;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final List<SetLog> sets;

  int get completedSets => sets.length;
  bool get isComplete => completedSets >= targetSets;
  double get volume => sets.fold(0, (sum, set) => sum + set.volume);

  SessionExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    MuscleGroup? muscleGroup,
    int? order,
    int? targetSets,
    int? targetReps,
    double? targetLoadKg,
    bool clearTargetLoad = false,
    int? restSeconds,
    String? mediaUrl,
    String? thumbnailUrl,
    List<SetLog>? sets,
  }) {
    return SessionExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      order: order ?? this.order,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetLoadKg: clearTargetLoad ? null : targetLoadKg ?? this.targetLoadKg,
      restSeconds: restSeconds ?? this.restSeconds,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup.id,
      'order': order,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetLoadKg': targetLoadKg,
      'restSeconds': restSeconds,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }

  factory SessionExercise.fromMap(Map<String, dynamic> map) {
    return SessionExercise(
      id: map['id']?.toString() ?? '',
      exerciseId: map['exerciseId']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      muscleGroup: muscleGroupFromId(map['muscleGroup']?.toString()),
      order: intFromJson(map['order']),
      targetSets: intFromJson(map['targetSets'], fallback: 3),
      targetReps: intFromJson(map['targetReps'], fallback: 10),
      targetLoadKg: nullableDoubleFromJson(map['targetLoadKg']),
      restSeconds: intFromJson(map['restSeconds'], fallback: 60),
      mediaUrl: map['mediaUrl']?.toString(),
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      sets: mapListFromJson(map['sets']).map(SetLog.fromMap).toList(),
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.planId,
    required this.planName,
    required this.startedAt,
    required this.exercises,
    this.effort,
    this.notes = '',
    this.healthSummary,
    this.endedAt,
  });

  final String id;
  final String planId;
  final String planName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<SessionExercise> exercises;
  final WorkoutEffort? effort;
  final String notes;
  final HealthWorkoutSummary? healthSummary;

  bool get isCompleted => endedAt != null;
  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);
  int get totalPlannedSets =>
      exercises.fold(0, (sum, exercise) => sum + exercise.targetSets);
  int get completedSets =>
      exercises.fold(0, (sum, exercise) => sum + exercise.completedSets);
  double get totalVolume =>
      exercises.fold(0, (sum, exercise) => sum + exercise.volume);

  WorkoutSession copyWith({
    String? id,
    String? planId,
    String? planName,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEndedAt = false,
    List<SessionExercise>? exercises,
    WorkoutEffort? effort,
    bool clearEffort = false,
    String? notes,
    HealthWorkoutSummary? healthSummary,
    bool clearHealthSummary = false,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      exercises: exercises ?? this.exercises,
      effort: clearEffort ? null : effort ?? this.effort,
      notes: notes ?? this.notes,
      healthSummary: clearHealthSummary
          ? null
          : healthSummary ?? this.healthSummary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planId': planId,
      'planName': planName,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'effort': effort?.id,
      'notes': notes,
      'healthSummary': healthSummary?.toMap(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id']?.toString() ?? '',
      planId: map['planId']?.toString() ?? '',
      planName: map['planName']?.toString() ?? '',
      startedAt: dateFromJson(map['startedAt']),
      endedAt: map['endedAt'] == null ? null : dateFromJson(map['endedAt']),
      effort: workoutEffortFromId(map['effort']?.toString()),
      notes: map['notes']?.toString() ?? '',
      healthSummary: map['healthSummary'] is Map
          ? HealthWorkoutSummary.fromMap(
              Map<String, dynamic>.from(map['healthSummary'] as Map),
            )
          : null,
      exercises:
          mapListFromJson(
              map['exercises'],
            ).map(SessionExercise.fromMap).toList()
            ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }
}
