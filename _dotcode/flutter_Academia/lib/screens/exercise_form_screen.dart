import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/muscle_group.dart';
import '../services/repository_scope.dart';

class ExerciseFormScreen extends StatefulWidget {
  const ExerciseFormScreen({super.key, this.exercise});

  final Exercise? exercise;

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _equipmentController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _loadController;
  late final TextEditingController _restController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _mediaController;
  late final TextEditingController _thumbnailController;
  late MuscleGroup _group;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _group = exercise?.muscleGroup ?? MuscleGroup.peito;
    _nameController = TextEditingController(text: exercise?.name ?? '');
    _equipmentController = TextEditingController(
      text: exercise?.equipment ?? '',
    );
    _setsController = TextEditingController(
      text: (exercise?.defaultSets ?? 3).toString(),
    );
    _repsController = TextEditingController(
      text: (exercise?.defaultReps ?? 10).toString(),
    );
    _loadController = TextEditingController(
      text: exercise?.defaultLoadKg?.toStringAsFixed(1) ?? '',
    );
    _restController = TextEditingController(
      text: (exercise?.restSeconds ?? 60).toString(),
    );
    _instructionsController = TextEditingController(
      text: exercise?.instructions ?? '',
    );
    _mediaController = TextEditingController(text: exercise?.mediaUrl ?? '');
    _thumbnailController = TextEditingController(
      text: exercise?.thumbnailUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _loadController.dispose();
    _restController.dispose();
    _instructionsController.dispose();
    _mediaController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar exercício' : 'Novo exercício'),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Excluir exercício',
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do exercício'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MuscleGroup>(
              initialValue: _group,
              decoration: const InputDecoration(labelText: 'Grupo muscular'),
              items: [
                for (final group in MuscleGroup.values)
                  DropdownMenuItem(value: group, child: Text(group.label)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _group = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _equipmentController,
              decoration: const InputDecoration(labelText: 'Equipamento'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(labelText: 'Séries'),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(labelText: 'Repetições'),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _loadController,
                    decoration: const InputDecoration(
                      labelText: 'Carga padrão kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalPositiveDouble,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _restController,
                    decoration: const InputDecoration(
                      labelText: 'Descanso seg.',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instructionsController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Instruções de execução',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mediaController,
              decoration: const InputDecoration(
                labelText: 'URL do vídeo/gif demonstrativo',
                prefixIcon: Icon(Icons.movie_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _thumbnailController,
              decoration: const InputDecoration(
                labelText: 'URL da thumbnail',
                prefixIcon: Icon(Icons.image_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEditing ? 'Salvar alterações' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
  }

  String? _positiveInt(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    return parsed == null || parsed <= 0 ? 'Use um número válido' : null;
  }

  String? _optionalPositiveDouble(String? value) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (text.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(text);
    return parsed == null || parsed < 0 ? 'Use uma carga válida' : null;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.exercise;
    final loadText = _loadController.text.trim().replaceAll(',', '.');
    final mediaUrl = _mediaController.text.trim();
    final thumbnailUrl = _thumbnailController.text.trim();
    final exercise = Exercise(
      id: existing?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      muscleGroup: _group,
      equipment: _equipmentController.text.trim(),
      defaultSets: int.parse(_setsController.text.trim()),
      defaultReps: int.parse(_repsController.text.trim()),
      defaultLoadKg: loadText.isEmpty ? null : double.parse(loadText),
      restSeconds: int.parse(_restController.text.trim()),
      instructions: _instructionsController.text.trim(),
      mediaUrl: mediaUrl.isEmpty ? null : mediaUrl,
      thumbnailUrl: thumbnailUrl.isEmpty ? null : thumbnailUrl,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await RepositoryScope.read(context).saveExercise(exercise);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final exercise = widget.exercise;
    if (exercise == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir exercício?'),
        content: Text(
          '${exercise.name} será removido da biblioteca e dos treinos mockados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await RepositoryScope.read(context).deleteExercise(exercise.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
