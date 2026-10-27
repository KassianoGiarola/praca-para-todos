import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/muscle_group.dart';
import '../services/repository_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/exercise_card.dart';
import '../widgets/muscle_chip.dart';
import 'exercise_detail_screen.dart';
import 'exercise_form_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedGroup;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final exercises = repository.exercises.where(_matchesFilters).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Exercício'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar por nome',
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  selected: _selectedGroup == null,
                  onSelected: (_) => setState(() => _selectedGroup = null),
                  label: const Text('Todos'),
                ),
                const SizedBox(width: 8),
                for (final group in MuscleGroup.values) ...[
                  MuscleChip(
                    group: group,
                    selected: _selectedGroup == group,
                    onSelected: (_) => setState(() => _selectedGroup = group),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: exercises.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'Nada encontrado',
                    message:
                        'Cadastre um exercício novo ou ajuste os filtros para ver a biblioteca.',
                    actionLabel: 'Cadastrar exercício',
                    onAction: () => _openForm(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: exercises.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ExerciseCard(
                        exercise: exercise,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ExerciseDetailScreen(exerciseId: exercise.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilters(Exercise exercise) {
    final normalizedQuery = _query.trim().toLowerCase();
    final matchesQuery =
        normalizedQuery.isEmpty ||
        exercise.name.toLowerCase().contains(normalizedQuery);
    final matchesGroup =
        _selectedGroup == null || exercise.muscleGroup == _selectedGroup;
    return matchesQuery && matchesGroup;
  }

  void _openForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ExerciseFormScreen()));
  }
}
