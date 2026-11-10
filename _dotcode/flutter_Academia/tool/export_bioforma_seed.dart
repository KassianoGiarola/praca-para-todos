import 'dart:convert';
import 'dart:io';

import 'package:meu_treino/data/bioforma_seed.dart';

void main() {
  final seed = buildBioformaSeed(DateTime.now());
  final payload = {
    'exercises': seed.exercises.map((exercise) => exercise.toMap()).toList(),
    'workoutPlans': seed.workoutPlans.map((plan) => plan.toMap()).toList(),
    'sessions': seed.sessions.map((session) => session.toMap()).toList(),
  };

  stdout.writeln(jsonEncode(payload));
}
