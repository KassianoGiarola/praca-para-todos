import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/muscle_group.dart';
import '../models/workout_plan.dart';
import '../services/repository_scope.dart';
import '../utils/formatters.dart';
import '../utils/group_colors.dart';
import '../widgets/empty_state.dart';

class WorkoutPlanFormScreen extends StatefulWidget {
  const WorkoutPlanFormScreen({super.key, this.plan});

  final WorkoutPlan? plan;

  @override
  State<WorkoutPlanFormScreen> createState() => _WorkoutPlanFormScreenState();
}

class _WorkoutPlanFormScreenState extends State<WorkoutPlanFormScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late List<WorkoutExercise> _items;
  late Set<int> _selectedWeekdays;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _nameController = TextEditingController(text: plan?.name ?? '');
    _descriptionController = TextEditingController(
      text: plan?.description ?? '',
    );
    _items = [...?plan?.exercises];
    _selectedWeekdays = {...?plan?.scheduledWeekdays};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plan != null;
    final repository = RepositoryScope.watch(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar treino' : 'Novo treino')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do treino'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Campo obrigatório'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 18),
            _WeekdaySelector(
              selectedWeekdays: _selectedWeekdays,
              onChanged: (weekday, selected) {
                setState(() {
                  if (selected) {
                    _selectedWeekdays.add(weekday);
                  } else {
                    _selectedWeekdays.remove(weekday);
                  }
                });
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Exercícios',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: repository.exercises.isEmpty
                      ? null
                      : () =>
                            _openExercisePicker(context, repository.exercises),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              const EmptyState(
                icon: Icons.playlist_add,
                title: 'Treino vazio',
                message:
                    'Adicione exercícios da biblioteca para definir ordem, séries, repetições e descanso.',
              )
            else
              for (var index = 0; index < _items.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WorkoutExerciseEditor(
                    key: ValueKey(_items[index].id),
                    item: _items[index],
                    exercise: _exerciseFor(repository.exercises, _items[index]),
                    index: index,
                    total: _items.length,
                    onMoveUp: index == 0 ? null : () => _move(index, -1),
                    onMoveDown: index == _items.length - 1
                        ? null
                        : () => _move(index, 1),
                    onRemove: () => setState(() => _items.removeAt(index)),
                    onChanged: (item) => setState(() => _items[index] = item),
                  ),
                ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEditing ? 'Salvar treino' : 'Criar treino'),
            ),
          ],
        ),
      ),
    );
  }

  Exercise? _exerciseFor(List<Exercise> exercises, WorkoutExercise item) {
    return exercises.cast<Exercise?>().firstWhere(
      (exercise) => exercise?.id == item.exerciseId,
      orElse: () => null,
    );
  }

  void _move(int index, int delta) {
    final newIndex = index + delta;
    setState(() {
      final item = _items.removeAt(index);
      _items.insert(newIndex, item);
      _items = _normalizeOrder(_items);
    });
  }

  Future<void> _openExercisePicker(
    BuildContext context,
    List<Exercise> exercises,
  ) async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: exercises.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: exercise.muscleGroup.accentColor.withValues(
                  alpha: 0.18,
                ),
                foregroundColor: exercise.muscleGroup.accentColor,
                child: const Icon(Icons.fitness_center),
              ),
              title: Text(exercise.name),
              subtitle: Text(
                '${exercise.muscleGroup.label} • ${exercise.defaultSets}x${exercise.defaultReps}',
              ),
              onTap: () => Navigator.of(context).pop(exercise),
            );
          },
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _items = [
        ..._items,
        WorkoutExercise(
          id: _uuid.v4(),
          exerciseId: selected.id,
          order: _items.length,
          sets: selected.defaultSets,
          reps: selected.defaultReps,
          targetLoadKg: selected.defaultLoadKg,
          restSeconds: selected.restSeconds,
        ),
      ];
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um exercício.')),
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.plan;
    final plan = WorkoutPlan(
      id: existing?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      exercises: _normalizeOrder(_items),
      scheduledWeekdays: _normalizedWeekdays(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await RepositoryScope.read(context).saveWorkoutPlan(plan);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  List<WorkoutExercise> _normalizeOrder(List<WorkoutExercise> items) {
    return [for (var i = 0; i < items.length; i++) items[i].copyWith(order: i)];
  }

  List<int> _normalizedWeekdays() {
    return _selectedWeekdays
        .where((weekday) => weekday >= 1 && weekday <= 7)
        .toList()
      ..sort();
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({
    required this.selectedWeekdays,
    required this.onChanged,
  });

  final Set<int> selectedWeekdays;
  final void Function(int weekday, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dias da semana',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in weekdayShortLabels.entries)
              FilterChip(
                label: Text(entry.value),
                selected: selectedWeekdays.contains(entry.key),
                onSelected: (selected) => onChanged(entry.key, selected),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          formatWeekdays(_sortedWeekdays(), short: false),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  List<int> _sortedWeekdays() {
    return selectedWeekdays.toList()..sort();
  }
}

class _WorkoutExerciseEditor extends StatelessWidget {
  const _WorkoutExerciseEditor({
    super.key,
    required this.item,
    required this.exercise,
    required this.index,
    required this.total,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.onChanged,
  });

  final WorkoutExercise item;
  final Exercise? exercise;
  final int index;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onRemove;
  final ValueChanged<WorkoutExercise> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        exercise?.muscleGroup.accentColor ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.18),
                  foregroundColor: accent,
                  child: Text('${index + 1}'),
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
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        exercise?.equipment ?? '-',
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
                  tooltip: 'Mover para cima',
                  onPressed: onMoveUp,
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  tooltip: 'Mover para baixo',
                  onPressed: onMoveDown,
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                IconButton(
                  tooltip: 'Remover',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Séries',
                    initialValue: item.sets.toString(),
                    onChanged: (value) => onChanged(
                      item.copyWith(sets: value.clamp(1, 99).toInt()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberField(
                    label: 'Reps',
                    initialValue: item.reps.toString(),
                    onChanged: (value) => onChanged(
                      item.copyWith(reps: value.clamp(1, 999).toInt()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.targetLoadKg?.toStringAsFixed(1) ?? '',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Carga alvo kg',
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(
                        value.trim().replaceAll(',', '.'),
                      );
                      onChanged(
                        item.copyWith(
                          targetLoadKg: parsed,
                          clearTargetLoad: value.trim().isEmpty,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberField(
                    label: 'Descanso s',
                    initialValue: item.restSeconds.toString(),
                    onChanged: (value) => onChanged(
                      item.copyWith(restSeconds: value.clamp(15, 600).toInt()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Meta: ${item.sets}x${item.reps} • ${formatKg(item.targetLoadKg)} • ${item.restSeconds}s',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (value) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          onChanged(parsed);
        }
      },
    );
  }
}
