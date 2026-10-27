class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxLoadKg,
    required this.maxReps,
    required this.maxVolume,
  });

  final String exerciseId;
  final String exerciseName;
  final double maxLoadKg;
  final int maxReps;
  final double maxVolume;

  bool get hasData => maxLoadKg > 0 || maxReps > 0 || maxVolume > 0;
}
