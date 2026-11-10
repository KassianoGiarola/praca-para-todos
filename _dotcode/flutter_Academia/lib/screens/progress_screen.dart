import 'package:flutter/material.dart';

import '../models/health_workout_summary.dart';
import '../models/personal_record.dart';
import '../models/workout_session.dart';
import '../services/health_connect_service.dart';
import '../services/repository_scope.dart';
import '../utils/formatters.dart';
import '../utils/group_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final sessions = repository.sessions;
    final records = _recordsFrom(sessions);
    final totalVolume = sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      body: sessions.isEmpty
          ? const EmptyState(
              icon: Icons.trending_up,
              title: 'Sem histórico ainda',
              message:
                  'Finalize um treino para acompanhar evolução de carga, volume e recordes.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    StatTile(
                      label: 'Treinos',
                      value: '${sessions.length}',
                      icon: Icons.event_available,
                    ),
                    StatTile(
                      label: 'Volume',
                      value: '${formatNumber(totalVolume)} kg',
                      icon: Icons.scale,
                    ),
                    StatTile(
                      label: 'Séries',
                      value: '${_totalSets(sessions)}',
                      icon: Icons.repeat,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const SectionHeader(title: 'Recordes pessoais'),
                const SizedBox(height: 10),
                for (final record in records)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecordCard(record: record),
                  ),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Histórico de treinos'),
                const SizedBox(height: 10),
                for (final session in sessions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SessionHistoryCard(session: session),
                  ),
              ],
            ),
    );
  }

  int _totalSets(List<WorkoutSession> sessions) {
    return sessions.fold(0, (sum, session) => sum + session.completedSets);
  }

  List<PersonalRecord> _recordsFrom(List<WorkoutSession> sessions) {
    final records = <String, PersonalRecord>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final current =
            records[exercise.exerciseId] ??
            PersonalRecord(
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.exerciseName,
              maxLoadKg: 0,
              maxReps: 0,
              maxVolume: 0,
            );

        var maxLoad = current.maxLoadKg;
        var maxReps = current.maxReps;
        for (final set in exercise.sets) {
          maxLoad = set.loadKg != null && set.loadKg! > maxLoad
              ? set.loadKg!
              : maxLoad;
          maxReps = set.reps > maxReps ? set.reps : maxReps;
        }

        records[exercise.exerciseId] = PersonalRecord(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          maxLoadKg: maxLoad,
          maxReps: maxReps,
          maxVolume: exercise.volume > current.maxVolume
              ? exercise.volume
              : current.maxVolume,
        );
      }
    }

    final items = records.values.where((record) => record.hasData).toList()
      ..sort((a, b) => b.maxVolume.compareTo(a.maxVolume));
    return items.take(6).toList();
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.exerciseName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: 'Maior carga',
                    value: formatKg(record.maxLoadKg),
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Mais reps',
                    value: '${record.maxReps}',
                  ),
                ),
                Expanded(
                  child: _MiniMetric(
                    label: 'Maior volume',
                    value: '${formatNumber(record.maxVolume)} kg',
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

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SessionHistoryCard extends StatefulWidget {
  const _SessionHistoryCard({required this.session});

  final WorkoutSession session;

  @override
  State<_SessionHistoryCard> createState() => _SessionHistoryCardState();
}

class _SessionHistoryCardState extends State<_SessionHistoryCard> {
  final _healthService = HealthConnectService();
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = widget.session;
    final first = session.exercises.isEmpty ? null : session.exercises.first;
    final accent = first?.muscleGroup.accentColor ?? theme.colorScheme.primary;
    final healthSummary = session.healthSummary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.planName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        formatDateTime(session.startedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatDuration(session.duration),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: session.totalPlannedSets == 0
                    ? 0
                    : (session.completedSets / session.totalPlannedSets)
                          .clamp(0.0, 1.0)
                          .toDouble(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${session.completedSets}/${session.totalPlannedSets} séries • ${formatNumber(session.totalVolume)} kg de volume',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (session.effort != null || session.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (session.effort != null)
                    Chip(
                      avatar: const Icon(Icons.speed, size: 18),
                      label: Text(session.effort!.label),
                    ),
                  if (session.notes.isNotEmpty)
                    Text(
                      session.notes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
            if (healthSummary != null && healthSummary.hasData) ...[
              const SizedBox(height: 12),
              _HealthSummaryContent(summary: healthSummary),
            ],
            const SizedBox(height: 12),
            if (_healthService.isSupportedPlatform)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _syncing ? null : _syncHealthSummary,
                  icon: _syncing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.watch_outlined),
                  label: Text(
                    healthSummary?.hasData == true
                        ? 'Atualizar dados do relógio'
                        : 'Sincronizar relógio',
                  ),
                ),
              )
            else
              Text(
                'Health Connect disponível no app Android.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncHealthSummary() async {
    setState(() => _syncing = true);
    final messenger = ScaffoldMessenger.of(context);
    final repository = RepositoryScope.read(context);

    try {
      final availability = await _healthService.checkAvailability();
      if (!mounted) {
        return;
      }

      if (availability == HealthConnectAvailability.unavailable ||
          availability == HealthConnectAvailability.updateRequired) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Instale ou atualize o Health Connect para sincronizar.',
            ),
          ),
        );
        await _healthService.installHealthConnect();
        return;
      }

      if (availability != HealthConnectAvailability.available) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Health Connect não está disponível neste aparelho.'),
          ),
        );
        return;
      }

      var granted = await _healthService.hasPermissions();
      if (!granted) {
        granted = await _healthService.requestPermissions();
      }

      if (!mounted) {
        return;
      }

      if (!granted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Permissão negada. Libere batimentos e calorias no Health Connect.',
            ),
          ),
        );
        return;
      }

      final summary = await _healthService.readWorkoutSummary(widget.session);
      if (!mounted) {
        return;
      }

      if (summary == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Não encontrei dados nesse horário. Sincronize o Zepp e tente novamente.',
            ),
          ),
        );
        return;
      }

      await repository.updateSessionHealthSummary(widget.session.id, summary);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Dados do relógio sincronizados.')),
        );
      }
    } on Object {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Não foi possível sincronizar os dados do relógio.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }
}

class _HealthSummaryContent extends StatelessWidget {
  const _HealthSummaryContent({required this.summary});

  final HealthWorkoutSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dados do relógio',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                summary.sourceName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (summary.averageHeartRateBpm != null)
                _HealthMetricChip(
                  icon: Icons.favorite_outline,
                  label: 'Média',
                  value: formatBpm(summary.averageHeartRateBpm),
                ),
              if (summary.maxHeartRateBpm != null)
                _HealthMetricChip(
                  icon: Icons.trending_up,
                  label: 'Máx.',
                  value: formatBpm(summary.maxHeartRateBpm),
                ),
              if (summary.minHeartRateBpm != null)
                _HealthMetricChip(
                  icon: Icons.trending_down,
                  label: 'Mín.',
                  value: formatBpm(summary.minHeartRateBpm),
                ),
              if (summary.displayCaloriesKcal != null)
                _HealthMetricChip(
                  icon: Icons.local_fire_department_outlined,
                  label: summary.caloriesLabel,
                  value: formatCalories(summary.displayCaloriesKcal),
                ),
            ],
          ),
          if (summary.syncedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Sincronizado em ${formatDateTime(summary.syncedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthMetricChip extends StatelessWidget {
  const _HealthMetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            '$label: $value',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
