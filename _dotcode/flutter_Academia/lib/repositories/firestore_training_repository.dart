import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/bioforma_seed.dart';
import '../models/exercise.dart';
import '../models/health_workout_summary.dart';
import '../models/muscle_group.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap.dart';
import '../services/firestore_service.dart';
import 'training_repository.dart';

class FirestoreTrainingRepository extends TrainingRepository {
  FirestoreTrainingRepository({
    required this.firebaseStatus,
    AuthService? authService,
    FirestoreService? firestoreService,
  }) : _authService = authService ?? AuthService(),
       firestore =
           firestoreService ??
           FirestoreService(authService: authService ?? AuthService()) {
    _watchAuth();
  }

  static const _uuid = Uuid();

  final FirestoreService firestore;
  final AuthService _authService;

  @override
  final FirebaseStatus firebaseStatus;

  StreamSubscription<Object?>? _authSubscription;
  final List<StreamSubscription<Object?>> _dataSubscriptions = [];
  final List<Exercise> _exercises = [];
  final List<WorkoutPlan> _workoutPlans = [];
  final List<WorkoutSession> _sessions = [];
  WorkoutSession? _activeSession;
  ThemeMode _themeMode = ThemeMode.dark;

  Object? _lastError;

  Object? get lastError => _lastError;

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
  void dispose() {
    unawaited(_authSubscription?.cancel());
    _cancelDataSubscriptions();
    super.dispose();
  }

  @override
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    _upsertExercise(exercise);
    notifyListeners();
    await firestore.setUserDocument('exercises', exercise.id, exercise.toMap());
  }

  @override
  Future<void> deleteExercise(String id) async {
    final affectedPlans = _workoutPlans
        .where((plan) => plan.exercises.any((item) => item.exerciseId == id))
        .map(
          (plan) => plan.copyWith(
            exercises: _normalizeOrder(
              plan.exercises.where((item) => item.exerciseId != id).toList(),
            ),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();

    _exercises.removeWhere((exercise) => exercise.id == id);
    for (final plan in affectedPlans) {
      _upsertPlan(plan);
    }
    notifyListeners();

    await firestore.deleteUserDocument('exercises', id);
    for (final plan in affectedPlans) {
      await firestore.setUserDocument('workoutPlans', plan.id, plan.toMap());
    }
  }

  @override
  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    final normalizedPlan = plan.copyWith(
      exercises: _normalizeOrder(plan.exercises),
      updatedAt: DateTime.now(),
    );
    _upsertPlan(normalizedPlan);
    notifyListeners();
    await firestore.setUserDocument(
      'workoutPlans',
      normalizedPlan.id,
      normalizedPlan.toMap(),
    );
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

    _upsertPlan(copy);
    notifyListeners();
    await firestore.setUserDocument('workoutPlans', copy.id, copy.toMap());
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
    unawaited(
      firestore.setUserDocument('sessions', finished.id, finished.toMap()),
    );
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

    final updated = _sessions[index].copyWith(healthSummary: summary);
    _sessions[index] = updated;
    notifyListeners();
    await firestore.setUserDocument('sessions', updated.id, updated.toMap());
  }

  @override
  void abandonActiveSession() {
    _activeSession = null;
    notifyListeners();
  }

  @override
  void resetMockData() {
    unawaited(_importSampleData());
  }

  void _watchAuth() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      _cancelDataSubscriptions();
      _clearRemoteState();
      if (user != null) {
        _connectData();
      }
      notifyListeners();
    }, onError: _setError);
  }

  void _connectData() {
    _dataSubscriptions.add(
      firestore
          .watchUserCollection('exercises')
          .map((items) => items.map(Exercise.fromMap).toList())
          .listen((items) {
            _lastError = null;
            _exercises
              ..clear()
              ..addAll(items..sort((a, b) => a.name.compareTo(b.name)));
            notifyListeners();
          }, onError: _setError),
    );

    _dataSubscriptions.add(
      firestore
          .watchUserCollection('workoutPlans')
          .map((items) => items.map(WorkoutPlan.fromMap).toList())
          .listen((items) {
            _lastError = null;
            _workoutPlans
              ..clear()
              ..addAll(
                items..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
              );
            notifyListeners();
          }, onError: _setError),
    );

    _dataSubscriptions.add(
      firestore
          .watchUserCollection('sessions', orderBy: 'startedAt')
          .map((items) => items.map(WorkoutSession.fromMap).toList())
          .listen((items) {
            _lastError = null;
            _sessions
              ..clear()
              ..addAll(
                items..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
              );
            notifyListeners();
          }, onError: _setError),
    );
  }

  void _cancelDataSubscriptions() {
    for (final subscription in _dataSubscriptions) {
      unawaited(subscription.cancel());
    }
    _dataSubscriptions.clear();
  }

  void _clearRemoteState() {
    _exercises.clear();
    _workoutPlans.clear();
    _sessions.clear();
    _activeSession = null;
  }

  void _setError(Object error) {
    _lastError = error;
    notifyListeners();
  }

  void _upsertExercise(Exercise exercise) {
    final index = _exercises.indexWhere((item) => item.id == exercise.id);
    if (index == -1) {
      _exercises.add(exercise);
    } else {
      _exercises[index] = exercise;
    }
    _exercises.sort((a, b) => a.name.compareTo(b.name));
  }

  void _upsertPlan(WorkoutPlan plan) {
    final index = _workoutPlans.indexWhere((item) => item.id == plan.id);
    if (index == -1) {
      _workoutPlans.add(plan);
    } else {
      _workoutPlans[index] = plan;
    }
    _workoutPlans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<WorkoutExercise> _normalizeOrder(List<WorkoutExercise> items) {
    final sorted = [...items]..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i),
    ];
  }

  Future<void> _importSampleData() async {
    final seed = buildBioformaSeed(DateTime.now());
    try {
      await firestore.clearUserCollection('sessions');
      await firestore.clearUserCollection('workoutPlans');
      await firestore.clearUserCollection('exercises');

      for (final exercise in seed.exercises) {
        await firestore.setUserDocument(
          'exercises',
          exercise.id,
          exercise.toMap(),
        );
      }
      for (final plan in seed.workoutPlans) {
        await firestore.setUserDocument('workoutPlans', plan.id, plan.toMap());
      }
      for (final session in seed.sessions) {
        await firestore.setUserDocument(
          'sessions',
          session.id,
          session.toMap(),
        );
      }
    } on Object catch (error) {
      _setError(error);
    }
  }
}
