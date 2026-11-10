import '../models/exercise.dart';
import '../models/muscle_group.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';

class BioformaSeedData {
  const BioformaSeedData({
    required this.exercises,
    required this.workoutPlans,
    required this.sessions,
  });

  final List<Exercise> exercises;
  final List<WorkoutPlan> workoutPlans;
  final List<WorkoutSession> sessions;
}

BioformaSeedData buildBioformaSeed(DateTime now) {
  final createdAt = now.subtract(const Duration(days: 7));
  final updatedAt = now;

  final exercises = [
    _exercise(
      id: 'bioforma_alongamento_peito_ombros',
      name: 'Alongamento do Peito e Parte Frontal dos Ombros',
      muscleGroup: MuscleGroup.mobilidade,
      equipment: 'Peso corporal',
      sets: 1,
      reps: 30,
      restSeconds: 30,
      instructions:
          'Use como aquecimento de ombros e peitoral antes dos treinos de membros superiores.',
      gifPath:
          'Exercicios/Mobilidade/Alongamento do Peito e Parte Frontal dos Ombros.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_supino_inclinado_halteres',
      name: 'Supino Inclinado com Halteres',
      muscleGroup: MuscleGroup.peito,
      equipment: 'Banco inclinado e halteres',
      sets: 3,
      reps: 12,
      loadKg: 12,
      restSeconds: 60,
      instructions:
          'Carga anotada na ficha: 12/12 kg. Mantenha escapulas encaixadas e controle a descida.',
      gifPath: 'Exercicios/Peitoral/Supino Inclinado com Halteres.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_crossover_polia_media',
      name: 'Cross over polia media',
      muscleGroup: MuscleGroup.peito,
      equipment: 'Crossover',
      sets: 3,
      reps: 12,
      loadKg: 5,
      restSeconds: 60,
      instructions:
          'Carga anotada na ficha: 5/5 kg. Cruze com controle e sem perder a postura.',
      gifPath: 'Exercicios/Peitoral/Cross over polia media.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_supino_reto_barra',
      name: 'Supino Reto',
      muscleGroup: MuscleGroup.peito,
      equipment: 'Barra',
      sets: 3,
      reps: 12,
      loadKg: 10,
      restSeconds: 60,
      instructions:
          'Carga anotada na ficha: 10/10 kg. Desca a barra com controle e suba sem perder a linha dos punhos.',
      gifPath: 'Exercicios/Peitoral/Supino Reto.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_voador_maquina',
      name: 'Voador na Máquina + rest pause',
      muscleGroup: MuscleGroup.peito,
      equipment: 'Máquina voador',
      sets: 3,
      reps: 12,
      loadKg: 15,
      restSeconds: 60,
      instructions:
          'Na ultima serie, faca rest-pause de 10 segundos e complete as repeticoes restantes.',
      gifPath: 'Exercicios/Peitoral/Voador na Máquina.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_desenvolvimento_halteres',
      name: 'Desenvolvimento com Halteres + drop',
      muscleGroup: MuscleGroup.ombros,
      equipment: 'Banco e halteres',
      sets: 3,
      reps: 12,
      loadKg: 8,
      restSeconds: 60,
      instructions:
          'Ficha: 8 kg com drop para 5 kg. Evite arquear a lombar e mantenha o abdome firme.',
      gifPath:
          'Exercicios/Ombros/Desenvolvimento de Ombro no Banco com Halteres.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_elevacao_lateral_sentado',
      name: 'Elevação Lateral Sentado',
      muscleGroup: MuscleGroup.ombros,
      equipment: 'Banco e halteres',
      sets: 3,
      reps: 12,
      loadKg: 5,
      restSeconds: 60,
      instructions:
          'Carga anotada na ficha: 5/5 kg. Suba ate a linha dos ombros sem balancar o tronco.',
      gifPath: 'Exercicios/Ombros/Elevação lateral com halteres sentado.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_elevacao_frontal_polia',
      name: 'Elevação Frontal na Polia',
      muscleGroup: MuscleGroup.ombros,
      equipment: 'Cabo',
      sets: 3,
      reps: 12,
      loadKg: 10,
      restSeconds: 60,
      instructions:
          'Use pegada controlada e evite compensar com o tronco. Equivalente do catálogo: levantamento frontal de cabo.',
      gifPath:
          'Exercicios/Ombros/Levantamento frontal de cabo com dois braços.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_triceps_pulley_barra_v',
      name: 'Tríceps Barra W + drop',
      muscleGroup: MuscleGroup.bracos,
      equipment: 'Polia com barra V',
      sets: 3,
      reps: 12,
      loadKg: 35,
      restSeconds: 60,
      instructions:
          'Ficha: 35 kg com drop para 25 kg. Mantenha cotovelos fixos ao lado do corpo.',
      gifPath: 'Exercicios/Tríceps/Tríceps Pulley barra V.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_triceps_frances_corda',
      name: 'Tríceps testa na polia',
      muscleGroup: MuscleGroup.bracos,
      equipment: 'Polia com corda',
      sets: 3,
      reps: 12,
      loadKg: 20,
      restSeconds: 60,
      instructions:
          'Equivalente do catálogo: tríceps francês na polia com corda. Controle bem a fase negativa.',
      gifPath: 'Exercicios/Tríceps/Tríceps francês na polia com corda.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_barra_fixa_fechada',
      name: 'Barra Fixa com Pegada Fechada',
      muscleGroup: MuscleGroup.costas,
      equipment: 'Barra fixa',
      sets: 3,
      reps: 8,
      restSeconds: 60,
      instructions:
          'Ficha: 3 series no maximo. Suba sem impulso e controle a descida.',
      gifPath: 'Exercicios/Calistenia/Barra Fixa com Pegada Fechada.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_puxada_alta',
      name: 'Pulley frente aberto',
      muscleGroup: MuscleGroup.costas,
      equipment: 'Polia alta',
      sets: 3,
      reps: 12,
      loadKg: 35,
      restSeconds: 60,
      instructions:
          'Equivalente do catálogo: Puxada Alta. Puxe em direcao ao alto do peito e mantenha escapulas ativas.',
      gifPath: 'Exercicios/Costas/Puxada Alta.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_remada_curvada_barra',
      name: 'Remada Curvada com Barra',
      muscleGroup: MuscleGroup.costas,
      equipment: 'Barra',
      sets: 3,
      reps: 12,
      loadKg: 30,
      restSeconds: 60,
      instructions:
          'Mantenha coluna neutra, tronco inclinado e puxe a barra em direcao ao abdome.',
      gifPath: 'Exercicios/Costas/Remada Curvada com Barra.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_remada_sentada_anilhas',
      name: 'Remada cavalo aberto',
      muscleGroup: MuscleGroup.costas,
      equipment: 'Máquina com anilhas',
      sets: 3,
      reps: 12,
      loadKg: 18,
      restSeconds: 60,
      instructions:
          'Equivalente do catálogo: Remada Sentada com Anilhas. Puxe com cotovelos abertos e controle a volta.',
      gifPath: 'Exercicios/Costas/Remada Sentada com Anilhas.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_pulldown_corda',
      name: 'Pull Down + drop',
      muscleGroup: MuscleGroup.costas,
      equipment: 'Polia com corda',
      sets: 3,
      reps: 12,
      loadKg: 25,
      restSeconds: 60,
      instructions:
          'Ficha: 25 kg com drop para 20 kg. Mantenha bracos quase estendidos e foco no dorsal.',
      gifPath: 'Exercicios/Costas/Pulldown com corda.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_crucifixo_inverso_polia',
      name: 'Crucifixo Inverso na Polia',
      muscleGroup: MuscleGroup.ombros,
      equipment: 'Cabo',
      sets: 3,
      reps: 12,
      loadKg: 5,
      restSeconds: 60,
      instructions:
          'Foque em deltoide posterior. Evite encolher os ombros durante a puxada.',
      gifPath: 'Exercicios/Ombros/Crucifixo inverso unilateral com cabo.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_rosca_direta_barra',
      name: 'Rosca Bíceps na Barra',
      muscleGroup: MuscleGroup.bracos,
      equipment: 'Barra',
      sets: 3,
      reps: 12,
      loadKg: 5,
      restSeconds: 60,
      instructions:
          'Carga anotada na ficha: 5/5 kg. Cotovelos proximos ao corpo e tronco firme.',
      gifPath: 'Exercicios/Bíceps/Rosca Direta com Barra.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_rosca_banco_inclinado',
      name: 'Rosca Bíceps no Banco Inclinado',
      muscleGroup: MuscleGroup.bracos,
      equipment: 'Banco inclinado e halteres',
      sets: 3,
      reps: 12,
      loadKg: 4,
      restSeconds: 60,
      instructions:
          'Carga anotada na ficha: 4/4 kg. Desca bem sem perder o controle dos ombros.',
      gifPath: 'Exercicios/Bíceps/Rosca Banco Inclinado.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_abd_supra_bracos_estendidos',
      name: 'Abd supra braços estendidos',
      muscleGroup: MuscleGroup.core,
      equipment: 'Peso corporal',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions:
          'Sem GIF vinculado por escolha do usuário. Eleve o tronco sem puxar o pescoco.',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_abd_infra',
      name: 'Abd infra',
      muscleGroup: MuscleGroup.core,
      equipment: 'Peso corporal',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      instructions:
          'Sem GIF vinculado por escolha do usuário. Controle a pelve e evite embalar as pernas.',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_prancha_dinamica',
      name: 'Prancha dinâmica',
      muscleGroup: MuscleGroup.core,
      equipment: 'Peso corporal',
      sets: 3,
      reps: 10,
      restSeconds: 60,
      instructions:
          'Sem GIF vinculado por escolha do usuário. Mantenha quadril alinhado durante o movimento.',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_mobilidade_tornozelo',
      name: 'Rotação de Pé e Tornozelo',
      muscleGroup: MuscleGroup.mobilidade,
      equipment: 'Peso corporal',
      sets: 1,
      reps: 10,
      restSeconds: 30,
      instructions:
          'Aquecimento do treino de pernas. Execute 10 repeticoes por lado.',
      gifPath: 'Exercicios/Mobilidade/Rotação de Pé e Tornozelo.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_mobilidade_quadril',
      name: 'Mobilidade de Quadril',
      muscleGroup: MuscleGroup.mobilidade,
      equipment: 'Peso corporal',
      sets: 1,
      reps: 10,
      restSeconds: 30,
      instructions:
          'Sem GIF vinculado por escolha do usuário. Use como aquecimento antes do treino de pernas.',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_cadeira_extensora',
      name: 'Cadeira extensora',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Cadeira extensora',
      sets: 3,
      reps: 12,
      loadKg: 35,
      restSeconds: 60,
      instructions:
          'Ficha: controlar a descida. Estenda sem travar o joelho e volte devagar.',
      gifPath: 'Exercicios/Pernas/Cadeira extensora.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_leg_press_unilateral',
      name: 'Leg Press unilateral',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Leg press 45',
      sets: 3,
      reps: 10,
      loadKg: 25,
      restSeconds: 60,
      instructions:
          'Ficha: 25/25 kg. Execute uma perna por vez, mantendo joelho alinhado ao pe.',
      gifPath: 'Exercicios/Pernas/Leg Press unilateral.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_leg_press',
      name: 'Leg Press',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Leg press 45',
      sets: 3,
      reps: 10,
      loadKg: 60,
      restSeconds: 60,
      instructions:
          'Ficha: 10 + 10 com rest-pause de 10 segundos; carga 60/60 kg.',
      gifPath: 'Exercicios/Pernas/Leg Press.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_agachamento_barra',
      name: 'Agachamento Barra',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Barra',
      sets: 3,
      reps: 12,
      loadKg: 15,
      restSeconds: 60,
      instructions:
          'Ficha: 15/15 kg. Mantenha tronco firme, joelhos alinhados e amplitude controlada.',
      gifPath: 'Exercicios/Pernas/Agachamento Barra.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_elevacao_pelvica_maquina',
      name: 'Elevação Pélvica Na Máquina',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Máquina',
      sets: 3,
      reps: 10,
      loadKg: 25,
      restSeconds: 60,
      instructions:
          'Ficha: 10 + 10 com rest-pause de 10 segundos; carga 25/25 kg.',
      gifPath: 'Exercicios/Glúteos/Elevação Pélvica Na Máquina.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_flexora_em_pe',
      name: 'Flexora em pé',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Máquina flexora em pé',
      sets: 3,
      reps: 10,
      loadKg: 12,
      restSeconds: 60,
      instructions:
          'Ficha: 12/12 kg. GIF externo indicado pelo usuário: Lever Kneeling Leg Curl.',
      mediaUrl:
          'https://fitnessprogramer.com/wp-content/uploads/2021/09/Lever-Kneeling-Leg-Curl-.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_cadeira_flexora',
      name: 'Cadeira flexora 2 tempos',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Cadeira flexora',
      sets: 3,
      reps: 12,
      loadKg: 30,
      restSeconds: 60,
      instructions:
          'Execute em 2 tempos, segurando a contracao antes de retornar.',
      gifPath: 'Exercicios/Pernas/Cadeira flexora.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    _exercise(
      id: 'bioforma_panturrilha_maquina',
      name: 'Panturrilha Máquina',
      muscleGroup: MuscleGroup.pernas,
      equipment: 'Máquina de panturrilha',
      sets: 6,
      reps: 15,
      loadKg: 40,
      restSeconds: 10,
      instructions:
          'Ficha: 6 series de 15 com 40 kg e intervalo curto de 10 segundos.',
      gifPath: 'Exercicios/Panturrilhas/Elevação de Panturrilha na Máquina.gif',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
  ];

  final byId = {for (final exercise in exercises) exercise.id: exercise};

  return BioformaSeedData(
    exercises: exercises,
    workoutPlans: [
      WorkoutPlan(
        id: 'bioforma_treino_a',
        name: 'Treino A - Peito/Ombro/Tríceps',
        description:
            'Ficha Bioforma: peito, ombro e triceps. Alongamentos anotados: 24/23/14.',
        scheduledWeekdays: const [1, 4],
        exercises: [
          _item(
            byId,
            'bioforma_treino_a',
            0,
            'bioforma_alongamento_peito_ombros',
          ),
          _item(
            byId,
            'bioforma_treino_a',
            1,
            'bioforma_supino_inclinado_halteres',
          ),
          _item(byId, 'bioforma_treino_a', 2, 'bioforma_crossover_polia_media'),
          _item(byId, 'bioforma_treino_a', 3, 'bioforma_supino_reto_barra'),
          _item(byId, 'bioforma_treino_a', 4, 'bioforma_voador_maquina'),
          _item(
            byId,
            'bioforma_treino_a',
            5,
            'bioforma_desenvolvimento_halteres',
          ),
          _item(
            byId,
            'bioforma_treino_a',
            6,
            'bioforma_elevacao_lateral_sentado',
          ),
          _item(
            byId,
            'bioforma_treino_a',
            7,
            'bioforma_elevacao_frontal_polia',
          ),
          _item(
            byId,
            'bioforma_treino_a',
            8,
            'bioforma_triceps_pulley_barra_v',
          ),
          _item(byId, 'bioforma_treino_a', 9, 'bioforma_triceps_frances_corda'),
        ],
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
      WorkoutPlan(
        id: 'bioforma_treino_b',
        name: 'Treino B - Costas/Bíceps/Core',
        description:
            'Ficha Bioforma: dorsal, biceps e abdomen. Alongamentos anotados: 25/14/19/19.',
        scheduledWeekdays: const [2, 5],
        exercises: [
          _item(
            byId,
            'bioforma_treino_b',
            0,
            'bioforma_alongamento_peito_ombros',
          ),
          _item(byId, 'bioforma_treino_b', 1, 'bioforma_barra_fixa_fechada'),
          _item(byId, 'bioforma_treino_b', 2, 'bioforma_puxada_alta'),
          _item(byId, 'bioforma_treino_b', 3, 'bioforma_remada_curvada_barra'),
          _item(
            byId,
            'bioforma_treino_b',
            4,
            'bioforma_remada_sentada_anilhas',
          ),
          _item(byId, 'bioforma_treino_b', 5, 'bioforma_pulldown_corda'),
          _item(
            byId,
            'bioforma_treino_b',
            6,
            'bioforma_crucifixo_inverso_polia',
          ),
          _item(byId, 'bioforma_treino_b', 7, 'bioforma_rosca_direta_barra'),
          _item(byId, 'bioforma_treino_b', 8, 'bioforma_rosca_banco_inclinado'),
          _item(
            byId,
            'bioforma_treino_b',
            9,
            'bioforma_abd_supra_bracos_estendidos',
          ),
          _item(byId, 'bioforma_treino_b', 10, 'bioforma_abd_infra'),
          _item(byId, 'bioforma_treino_b', 11, 'bioforma_prancha_dinamica'),
        ],
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
      WorkoutPlan(
        id: 'bioforma_treino_c',
        name: 'Treino C - Pernas Completo',
        description:
            'Ficha Bioforma: pernas completo. Alongamentos anotados: 50/47/37/33.',
        scheduledWeekdays: const [3, 6],
        exercises: [
          _item(byId, 'bioforma_treino_c', 0, 'bioforma_mobilidade_tornozelo'),
          _item(byId, 'bioforma_treino_c', 1, 'bioforma_mobilidade_quadril'),
          _item(byId, 'bioforma_treino_c', 2, 'bioforma_cadeira_extensora'),
          _item(byId, 'bioforma_treino_c', 3, 'bioforma_leg_press_unilateral'),
          _item(byId, 'bioforma_treino_c', 4, 'bioforma_leg_press'),
          _item(byId, 'bioforma_treino_c', 5, 'bioforma_agachamento_barra'),
          _item(
            byId,
            'bioforma_treino_c',
            6,
            'bioforma_elevacao_pelvica_maquina',
          ),
          _item(byId, 'bioforma_treino_c', 7, 'bioforma_flexora_em_pe'),
          _item(byId, 'bioforma_treino_c', 8, 'bioforma_cadeira_flexora'),
          _item(byId, 'bioforma_treino_c', 9, 'bioforma_panturrilha_maquina'),
        ],
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    ],
    sessions: const [],
  );
}

Exercise _exercise({
  required String id,
  required String name,
  required MuscleGroup muscleGroup,
  required String equipment,
  required int sets,
  required int reps,
  required int restSeconds,
  required String instructions,
  required DateTime createdAt,
  required DateTime updatedAt,
  double? loadKg,
  String? gifPath,
  String? mediaUrl,
}) {
  return Exercise(
    id: id,
    name: name,
    muscleGroup: muscleGroup,
    equipment: equipment,
    defaultSets: sets,
    defaultReps: reps,
    defaultLoadKg: loadKg,
    restSeconds: restSeconds,
    instructions: instructions,
    mediaUrl: mediaUrl ?? _gifUrl(gifPath),
    thumbnailUrl: _thumbnailUrl(gifPath),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

WorkoutExercise _item(
  Map<String, Exercise> exercises,
  String planId,
  int order,
  String exerciseId,
) {
  final exercise = exercises[exerciseId]!;
  return WorkoutExercise(
    id: '${planId}_${exercise.id}',
    exerciseId: exercise.id,
    order: order,
    sets: exercise.defaultSets,
    reps: exercise.defaultReps,
    targetLoadKg: exercise.defaultLoadKg,
    restSeconds: exercise.restSeconds,
  );
}

String? _gifUrl(String? path) => path == null ? null : _siteUrl(path);

String? _thumbnailUrl(String? gifPath) {
  if (gifPath == null) {
    return null;
  }
  final fileName = gifPath.split('/').last.replaceAll('.gif', '.png');
  return _siteUrl('thumbnails/$fileName');
}

String _siteUrl(String path) =>
    Uri.encodeFull('https://www.gifdotreino.com/$path');
