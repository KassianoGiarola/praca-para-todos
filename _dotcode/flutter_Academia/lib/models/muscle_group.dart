enum MuscleGroup {
  peito,
  costas,
  pernas,
  ombros,
  bracos,
  core,
  cardio,
  mobilidade,
}

extension MuscleGroupInfo on MuscleGroup {
  String get id => switch (this) {
    MuscleGroup.peito => 'peito',
    MuscleGroup.costas => 'costas',
    MuscleGroup.pernas => 'pernas',
    MuscleGroup.ombros => 'ombros',
    MuscleGroup.bracos => 'bracos',
    MuscleGroup.core => 'core',
    MuscleGroup.cardio => 'cardio',
    MuscleGroup.mobilidade => 'mobilidade',
  };

  String get label => switch (this) {
    MuscleGroup.peito => 'Peito',
    MuscleGroup.costas => 'Costas',
    MuscleGroup.pernas => 'Pernas',
    MuscleGroup.ombros => 'Ombros',
    MuscleGroup.bracos => 'Braços',
    MuscleGroup.core => 'Core',
    MuscleGroup.cardio => 'Cardio',
    MuscleGroup.mobilidade => 'Mobilidade',
  };
}

MuscleGroup muscleGroupFromId(String? value) {
  return MuscleGroup.values.firstWhere(
    (group) => group.id == value,
    orElse: () => MuscleGroup.peito,
  );
}
