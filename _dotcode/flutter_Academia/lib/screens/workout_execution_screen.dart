import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../services/health_connect_service.dart';
import '../services/repository_scope.dart';
import '../utils/formatters.dart';
import '../utils/group_colors.dart';
import '../widgets/exercise_media_preview.dart';
import '../widgets/timer_badge.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  const WorkoutExecutionScreen({super.key});

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  final _repsController = TextEditingController();
  final _loadController = TextEditingController();
  final _healthService = HealthConnectService();
  Timer? _elapsedTimer;
  Timer? _restTimer;
  Duration _elapsed = Duration.zero;
  int _exerciseIndex = 0;
  int _restRemaining = 0;
  String? _controllerExerciseId;

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = RepositoryScope.read(context).activeSession;
      if (mounted && session != null) {
        setState(() => _elapsed = DateTime.now().difference(session.startedAt));
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    _repsController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final session = repository.activeSession;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Execução')),
        body: const Center(child: Text('Nenhum treino em andamento.')),
      );
    }
    if (session.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Execução')),
        body: const Center(child: Text('Este treino não tem exercícios.')),
      );
    }

    final currentIndex = _exerciseIndex
        .clamp(0, session.exercises.length - 1)
        .toInt();
    final current = session.exercises[currentIndex];
    _syncInputDefaults(current);

    return Scaffold(
      appBar: AppBar(
        title: Text(session.planName),
        actions: [
          TextButton(
            onPressed: () => _confirmFinish(context),
            child: const Text('Finalizar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: TimerBadge(
                  label: 'Total',
                  value: formatDuration(_elapsed),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TimerBadge(
                  label: 'Descanso',
                  value: _restRemaining > 0 ? '${_restRemaining}s' : 'pronto',
                  icon: Icons.hourglass_bottom,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SessionProgress(session: session),
          const SizedBox(height: 16),
          ExerciseMediaPreview(
            videoUrl: current.mediaUrl,
            thumbnailUrl: current.thumbnailUrl,
            height: 210,
          ),
          const SizedBox(height: 16),
          _ExerciseHeader(
            current: current,
            currentIndex: currentIndex,
            totalExercises: session.exercises.length,
          ),
          const SizedBox(height: 16),
          _SetChecklist(current: current),
          const SizedBox(height: 16),
          _InputPanel(
            repsController: _repsController,
            loadController: _loadController,
            onCompleteSet: () => _completeSet(context, currentIndex),
            onUndo: current.sets.isEmpty
                ? null
                : () => repository.removeLastSet(currentIndex),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currentIndex == 0
                      ? null
                      : () => setState(() {
                          _exerciseIndex--;
                          _restRemaining = 0;
                        }),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: currentIndex == session.exercises.length - 1
                      ? () => _confirmFinish(context)
                      : () => setState(() {
                          _exerciseIndex++;
                          _restRemaining = 0;
                        }),
                  icon: Icon(
                    currentIndex == session.exercises.length - 1
                        ? Icons.flag
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    currentIndex == session.exercises.length - 1
                        ? 'Finalizar'
                        : 'Pular/Próximo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _syncInputDefaults(SessionExercise exercise) {
    if (_controllerExerciseId == exercise.id) {
      return;
    }
    _controllerExerciseId = exercise.id;
    _repsController.text = exercise.targetReps.toString();
    _loadController.text = exercise.targetLoadKg?.toStringAsFixed(1) ?? '';
  }

  void _completeSet(BuildContext context, int exerciseIndex) {
    final reps = int.tryParse(_repsController.text.trim());
    final normalizedLoad = _loadController.text.trim().replaceAll(',', '.');
    final load = normalizedLoad.isEmpty
        ? null
        : double.tryParse(normalizedLoad);

    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida de reps.')),
      );
      return;
    }

    if (normalizedLoad.isNotEmpty && load == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma carga válida.')),
      );
      return;
    }

    final repository = RepositoryScope.read(context);
    final current = repository.activeSession!.exercises[exerciseIndex];
    repository.logSet(exerciseIndex: exerciseIndex, reps: reps, loadKg: load);
    _startRest(current.restSeconds);

    final updated = repository.activeSession!.exercises[exerciseIndex];
    if (updated.isComplete &&
        repository.activeSession!.exercises.every(
          (exercise) => exercise.isComplete,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas as séries foram registradas.')),
      );
    }
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() => _restRemaining = seconds);
    if (seconds <= 0) {
      return;
    }
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_restRemaining <= 1) {
        timer.cancel();
        setState(() => _restRemaining = 0);
      } else {
        setState(() => _restRemaining--);
      }
    });
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final repository = RepositoryScope.read(context);
    final session = repository.activeSession;
    if (session == null) {
      Navigator.of(context).pop();
      return;
    }

    final notesController = TextEditingController();
    final result = await showDialog<_FinishWorkoutResult>(
      context: context,
      builder: (context) {
        var selectedEffort = WorkoutEffort.moderate;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Como foi o treino?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Serão salvas ${session.completedSets} de ${session.totalPlannedSets} séries registradas.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final effort in WorkoutEffort.values)
                        ChoiceChip(
                          label: Text(effort.label),
                          selected: selectedEffort == effort,
                          onSelected: (_) {
                            setDialogState(() => selectedEffort = effort);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observação opcional',
                      hintText: 'Ex.: senti dor no ombro, aumentei carga...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  _FinishWorkoutResult(
                    effort: selectedEffort,
                    notes: notesController.text,
                  ),
                ),
                child: const Text('Salvar treino'),
              ),
            ],
          ),
        );
      },
    );
    notesController.dispose();

    if (result == null || !context.mounted) {
      return;
    }

    final finished = repository.finishSession(
      effort: result.effort,
      notes: result.notes,
    );
    if (finished != null) {
      await _trySyncHealthSummary(context, finished);
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _trySyncHealthSummary(
    BuildContext context,
    WorkoutSession session,
  ) async {
    if (!_healthService.isSupportedPlatform) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final repository = RepositoryScope.read(context);

    try {
      final availability = await _healthService.checkAvailability();
      if (!context.mounted ||
          availability != HealthConnectAvailability.available) {
        return;
      }

      var granted = await _healthService.hasPermissions();
      if (!granted) {
        granted = await _healthService.requestPermissions();
      }
      if (!context.mounted || !granted) {
        return;
      }

      final summary = await _healthService.readWorkoutSummary(session);
      if (!context.mounted || summary == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Treino salvo. Sincronize o Zepp e atualize pelo histórico.',
            ),
          ),
        );
        return;
      }

      await repository.updateSessionHealthSummary(session.id, summary);
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Treino salvo com dados do relógio.')),
        );
      }
    } on Object {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Treino salvo sem dados do relógio.')),
        );
      }
    }
  }
}

class _FinishWorkoutResult {
  const _FinishWorkoutResult({required this.effort, required this.notes});

  final WorkoutEffort effort;
  final String notes;
}

class _SessionProgress extends StatelessWidget {
  const _SessionProgress({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final progress = session.totalPlannedSets == 0
        ? 0.0
        : session.completedSets / session.totalPlannedSets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Progresso do treino',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${session.completedSets}/${session.totalPlannedSets} séries',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          minHeight: 10,
          value: progress.clamp(0.0, 1.0).toDouble(),
        ),
      ],
    );
  }
}

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader({
    required this.current,
    required this.currentIndex,
    required this.totalExercises,
  });

  final SessionExercise current;
  final int currentIndex;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = current.muscleGroup.accentColor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercício ${currentIndex + 1} de $totalExercises',
              style: theme.textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              current.exerciseName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('${current.targetSets} séries')),
                Chip(label: Text('${current.targetReps} reps')),
                Chip(label: Text(formatKg(current.targetLoadKg))),
                Chip(label: Text('${current.restSeconds}s descanso')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetChecklist extends StatelessWidget {
  const _SetChecklist({required this.current});

  final SessionExercise current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (var index = 0; index < current.targetSets; index++)
              _SetRow(
                index: index,
                set: index < current.sets.length ? current.sets[index] : null,
                textColor: theme.colorScheme.onSurface,
              ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.textColor,
  });

  final int index;
  final SetLog? set;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = set != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              completed
                  ? 'Série ${index + 1}: ${set!.reps} reps • ${formatKg(set!.loadKg)}'
                  : 'Série ${index + 1}: pendente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: completed
                    ? textColor
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  const _InputPanel({
    required this.repsController,
    required this.loadController,
    required this.onCompleteSet,
    required this.onUndo,
  });

  final TextEditingController repsController;
  final TextEditingController loadController;
  final VoidCallback onCompleteSet;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps feitas'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: loadController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Carga kg'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Desfazer última série',
                  onPressed: onUndo,
                  icon: const Icon(Icons.undo),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onCompleteSet,
                    icon: const Icon(Icons.check),
                    label: const Text('Concluir série'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
