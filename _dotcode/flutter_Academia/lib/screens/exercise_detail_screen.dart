import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/muscle_group.dart';
import '../services/repository_scope.dart';
import '../utils/formatters.dart';
import '../utils/group_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/exercise_media_preview.dart';
import '../widgets/stat_tile.dart';
import 'exercise_form_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final exercise = repository.exercises.cast<Exercise?>().firstWhere(
      (item) => item?.id == exerciseId,
      orElse: () => null,
    );

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercício')),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Exercício não encontrado',
          message: 'Ele pode ter sido removido da biblioteca.',
        ),
      );
    }

    final accent = exercise.muscleGroup.accentColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            tooltip: 'Editar exercício',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExerciseFormScreen(exercise: exercise),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ExerciseMediaPreview(
            videoUrl: exercise.mediaUrl,
            thumbnailUrl: exercise.thumbnailUrl,
            height: 230,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 12,
                height: 56,
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
                      exercise.muscleGroup.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      exercise.equipment,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              StatTile(
                label: 'Séries padrão',
                value: '${exercise.defaultSets}',
                icon: Icons.repeat,
                color: accent,
              ),
              StatTile(
                label: 'Reps padrão',
                value: '${exercise.defaultReps}',
                icon: Icons.tag,
                color: accent,
              ),
              StatTile(
                label: 'Carga',
                value: formatKg(exercise.defaultLoadKg),
                icon: Icons.scale,
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instruções',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.instructions.isEmpty
                        ? 'Sem instruções cadastradas.'
                        : exercise.instructions,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(width: 8),
                      Text('Descanso padrão: ${exercise.restSeconds}s'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
