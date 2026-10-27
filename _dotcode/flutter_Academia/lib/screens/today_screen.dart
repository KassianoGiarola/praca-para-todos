import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../services/repository_scope.dart';
import '../utils/formatters.dart';
import '../utils/group_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';
import '../widgets/workout_plan_card.dart';
import 'workout_execution_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final plan = repository.todayPlan;
    final activeSession = repository.activeSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoje'),
        actions: [
          if (repository.firebaseStatus.usingMockData)
            const Tooltip(
              message: 'Modo mock offline',
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off_outlined),
              ),
            ),
        ],
      ),
      body: plan == null
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (activeSession != null) ...[
                  _ActiveSessionCard(session: activeSession),
                  const SizedBox(height: 16),
                ],
                const SizedBox(
                  height: 360,
                  child: EmptyState(
                    icon: Icons.assignment_add,
                    title: 'Nenhum treino agendado para hoje',
                    message:
                        'Escolha os dias da semana em cada treino ou inicie um treino manualmente pela aba Treinos.',
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (activeSession != null) ...[
                  _ActiveSessionCard(session: activeSession),
                  const SizedBox(height: 16),
                ],
                _TodaySummary(plan: plan, activeSession: activeSession),
                const SizedBox(height: 16),
                WorkoutPlanCard(
                  plan: plan,
                  exercises: repository.exercises,
                  onStart: () => _startWorkout(context, plan),
                ),
                const SizedBox(height: 22),
                const SectionHeader(title: 'Exercícios de hoje'),
                const SizedBox(height: 10),
                for (final item in plan.exercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlannedExerciseTile(
                      planItem: item,
                      exercise: _findExercise(repository.exercises, item),
                    ),
                  ),
              ],
            ),
    );
  }

  Exercise? _findExercise(List<Exercise> exercises, WorkoutExercise item) {
    return exercises.cast<Exercise?>().firstWhere(
      (exercise) => exercise?.id == item.exerciseId,
      orElse: () => null,
    );
  }

  void _startWorkout(BuildContext context, WorkoutPlan plan) {
    final repository = RepositoryScope.read(context);
    repository.startSession(plan);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WorkoutExecutionScreen()));
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.plan, required this.activeSession});

  final WorkoutPlan plan;
  final WorkoutSession? activeSession;

  @override
  Widget build(BuildContext context) {
    final completedSets = activeSession?.completedSets ?? 0;
    final progress = plan.totalSets == 0 ? 0.0 : completedSets / plan.totalSets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plano do dia',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          plan.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          formatWeekdays(plan.scheduledWeekdays, short: false),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress.clamp(0.0, 1.0).toDouble(),
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.05,
          children: [
            StatTile(
              label: 'Progresso',
              value: '${(progress * 100).round()}%',
              icon: Icons.stacked_line_chart,
            ),
            StatTile(
              label: 'Séries',
              value: '$completedSets/${plan.totalSets}',
              icon: Icons.repeat,
            ),
            StatTile(
              label: 'Exercícios',
              value: '${plan.exercises.length}',
              icon: Icons.fitness_center,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final progress = session.totalPlannedSets == 0
        ? 0.0
        : session.completedSets / session.totalPlannedSets;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Treino em andamento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ElapsedText(startedAt: session.startedAt),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble()),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WorkoutExecutionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continuar treino'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElapsedText extends StatefulWidget {
  const _ElapsedText({required this.startedAt});

  final DateTime startedAt;

  @override
  State<_ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<_ElapsedText> {
  Timer? _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startedAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = DateTime.now().difference(widget.startedAt));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(_elapsed),
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _PlannedExerciseTile extends StatelessWidget {
  const _PlannedExerciseTile({required this.planItem, required this.exercise});

  final WorkoutExercise planItem;
  final Exercise? exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        exercise?.muscleGroup.accentColor ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.18),
              foregroundColor: accent,
              child: Text('${planItem.order + 1}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise?.name ?? 'Exercício removido',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${planItem.sets}x${planItem.reps} • ${formatKg(planItem.targetLoadKg)} • descanso ${planItem.restSeconds}s',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
