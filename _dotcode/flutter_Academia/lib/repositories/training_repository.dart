import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/bioforma_seed.dart';
import '../models/exercise.dart';
import '../models/health_workout_summary.dart';
import '../models/muscle_group.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../services/firebase_bootstrap.dart';

abstract class TrainingRepository extends ChangeNotifier {
  List<Exercise> get exercises;
  List<WorkoutPlan> get workoutPlans;
  List<WorkoutSession> get sessions;
  WorkoutSession? get activeSession;
  ThemeMode get themeMode;
  FirebaseStatus get firebaseStatus;

  WorkoutPlan? get todayPlan;

  void setThemeMode(ThemeMode mode);
  Future<void> saveExercise(Exercise exercise);
  Future<void> deleteExercise(String id);
  Future<void> saveWorkoutPlan(WorkoutPlan plan);
  Future<void> copyWorkoutPlan(String id);
  WorkoutSession startSession(WorkoutPlan plan);
  void logSet({
    required int exerciseIndex,
    required int reps,
    required double? loadKg,
  });
  void removeLastSet(int exerciseIndex);
  WorkoutSession? finishSession({WorkoutEffort? effort, String notes = ''});
  Future<void> updateSessionHealthSummary(
    String sessionId,
    HealthWorkoutSummary summary,
  );
  void abandonActiveSession();
  void resetMockData();
}

class MockTrainingRepository extends TrainingRepository {
  MockTrainingRepository({required this.firebaseStatus}) {
    _seed();
  }

  static const _uuid = Uuid();

  @override
  final FirebaseStatus firebaseStatus;

  final List<Exercise> _exercises = [];
  final List<WorkoutPlan> _workoutPlans = [];
  final List<WorkoutSession> _sessions = [];
  WorkoutSession? _activeSession;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  List<Exercise> get exercises => List.unmodifiable(_exercises);

  @override
  List<WorkoutPlan> get workoutPlans => List.unmodifiable(_workoutPlans);

  @override
  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

  @override
  WorkoutSession? get activeSession => _activeSession;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  WorkoutPlan? get todayPlan {
    if (_workoutPlans.isEmpty) {
      return null;
    }
    final weekday = DateTime.now().weekday;
    return _workoutPlans.cast<WorkoutPlan?>().firstWhere(
      (plan) => plan!.scheduledWeekdays.contains(weekday),
      orElse: () => null,
    );
  }

  @override
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    final index = _exercises.indexWhere((item) => item.id == exercise.id);
    if (index == -1) {
      _exercises.add(exercise);
    } else {
      _exercises[index] = exercise;
    }
    notifyListeners();
  }

  @override
  Future<void> deleteExercise(String id) async {
    _exercises.removeWhere((exercise) => exercise.id == id);
    for (var i = 0; i < _workoutPlans.length; i++) {
      final filtered = _workoutPlans[i].exercises
          .where((item) => item.exerciseId != id)
          .toList();
      _workoutPlans[i] = _workoutPlans[i].copyWith(exercises: filtered);
    }
    notifyListeners();
  }

  @override
  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    final sorted = _normalizeOrder(plan.exercises);
    final normalizedPlan = plan.copyWith(
      exercises: sorted,
      updatedAt: DateTime.now(),
    );
    final index = _workoutPlans.indexWhere((item) => item.id == plan.id);
    if (index == -1) {
      _workoutPlans.add(normalizedPlan);
    } else {
      _workoutPlans[index] = normalizedPlan;
    }
    notifyListeners();
  }

  @override
  Future<void> copyWorkoutPlan(String id) async {
    final source = _workoutPlans.firstWhere((plan) => plan.id == id);
    final now = DateTime.now();
    final copy = source.copyWith(
      id: _uuid.v4(),
      name: '${source.name} (cópia)',
      exercises: source.exercises
          .map((item) => item.copyWith(id: _uuid.v4()))
          .toList(),
      createdAt: now,
      updatedAt: now,
    );
    _workoutPlans.add(copy);
    notifyListeners();
  }

  @override
  WorkoutSession startSession(WorkoutPlan plan) {
    final now = DateTime.now();
    final sessionExercises = plan.exercises.map((item) {
      final exercise = _exercises.firstWhere(
        (entry) => entry.id == item.exerciseId,
        orElse: () => Exercise(
          id: item.exerciseId,
          name: 'Exercício removido',
          muscleGroup: MuscleGroup.peito,
          equipment: '-',
          defaultSets: item.sets,
          defaultReps: item.reps,
          defaultLoadKg: item.targetLoadKg,
          restSeconds: item.restSeconds,
          instructions: '',
          createdAt: now,
          updatedAt: now,
        ),
      );
      return SessionExercise(
        id: item.id,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        order: item.order,
        targetSets: item.sets,
        targetReps: item.reps,
        targetLoadKg: item.targetLoadKg,
        restSeconds: item.restSeconds,
        mediaUrl: exercise.mediaUrl,
        thumbnailUrl: exercise.thumbnailUrl,
        sets: const [],
      );
    }).toList();

    _activeSession = WorkoutSession(
      id: _uuid.v4(),
      planId: plan.id,
      planName: plan.name,
      startedAt: now,
      exercises: sessionExercises,
    );
    notifyListeners();
    return _activeSession!;
  }

  @override
  void logSet({
    required int exerciseIndex,
    required int reps,
    required double? loadKg,
  }) {
    final session = _activeSession;
    if (session == null || exerciseIndex >= session.exercises.length) {
      return;
    }

    final exercise = session.exercises[exerciseIndex];
    if (exercise.completedSets >= exercise.targetSets) {
      return;
    }

    final updatedSet = SetLog(
      id: _uuid.v4(),
      setNumber: exercise.completedSets + 1,
      reps: reps,
      loadKg: loadKg,
      completedAt: DateTime.now(),
    );
    final updatedExercise = exercise.copyWith(
      sets: [...exercise.sets, updatedSet],
    );
    final updatedExercises = [...session.exercises];
    updatedExercises[exerciseIndex] = updatedExercise;
    _activeSession = session.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  @override
  void removeLastSet(int exerciseIndex) {
    final session = _activeSession;
    if (session == null || exerciseIndex >= session.exercises.length) {
      return;
    }

    final exercise = session.exercises[exerciseIndex];
    if (exercise.sets.isEmpty) {
      return;
    }

    final updatedExercise = exercise.copyWith(
      sets: exercise.sets.take(exercise.sets.length - 1).toList(),
    );
    final updatedExercises = [...session.exercises];
    updatedExercises[exerciseIndex] = updatedExercise;
    _activeSession = session.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  @override
  WorkoutSession? finishSession({WorkoutEffort? effort, String notes = ''}) {
    final session = _activeSession;
    if (session == null) {
      return null;
    }

    final finished = session.copyWith(
      endedAt: DateTime.now(),
      effort: effort,
      clearEffort: effort == null,
      notes: notes.trim(),
    );
    _sessions.insert(0, finished);
    _activeSession = null;
    notifyListeners();
    return finished;
  }

  @override
  Future<void> updateSessionHealthSummary(
    String sessionId,
    HealthWorkoutSummary summary,
  ) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) {
      return;
    }

    _sessions[index] = _sessions[index].copyWith(healthSummary: summary);
    notifyListeners();
  }

  @override
  void abandonActiveSession() {
    _activeSession = null;
    notifyListeners();
  }

  @override
  void resetMockData() {
    _exercises.clear();
    _workoutPlans.clear();
    _sessions.clear();
    _activeSession = null;
    _seed();
    notifyListeners();
  }

  List<WorkoutExercise> _normalizeOrder(List<WorkoutExercise> items) {
    final sorted = [...items]..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i),
    ];
  }

  void _seed() {
    final seed = buildBioformaSeed(DateTime.now());
    _exercises.addAll(seed.exercises);
    _workoutPlans.addAll(seed.workoutPlans);
    _sessions.addAll(seed.sessions);
  }
}
