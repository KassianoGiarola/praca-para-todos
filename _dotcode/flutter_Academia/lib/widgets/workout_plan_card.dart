import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../utils/formatters.dart';
import '../utils/group_colors.dart';

class WorkoutPlanCard extends StatelessWidget {
  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.exercises,
    this.onTap,
    this.onStart,
    this.onCopy,
  });

  final WorkoutPlan plan;
  final List<Exercise> exercises;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstExercise = plan.exercises.isEmpty
        ? null
        : exercises.cast<Exercise?>().firstWhere(
            (exercise) => exercise?.id == plan.exercises.first.exerciseId,
            orElse: () => null,
          );
    final accent =
        firstExercise?.muscleGroup.accentColor ?? theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 42,
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
                          plan.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (plan.description.isNotEmpty)
                          Text(
                            plan.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copiar treino',
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_all_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.list_alt,
                    label: '${plan.exercises.length} exercícios',
                  ),
                  _MetaChip(
                    icon: Icons.repeat,
                    label: '${plan.totalSets} séries',
                  ),
                  _MetaChip(
                    icon: Icons.event_repeat,
                    label: formatWeekdays(plan.scheduledWeekdays),
                  ),
                  _MetaChip(
                    icon: Icons.update,
                    label: formatDate(plan.updatedAt),
                  ),
                ],
              ),
              if (onStart != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar treino'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
