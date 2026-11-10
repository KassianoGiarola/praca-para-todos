import 'package:flutter/material.dart';

import '../models/muscle_group.dart';

extension MuscleGroupColors on MuscleGroup {
  Color get accentColor => switch (this) {
    MuscleGroup.peito => const Color(0xFFFF6B6B),
    MuscleGroup.costas => const Color(0xFF4ECDC4),
    MuscleGroup.pernas => const Color(0xFFFFD166),
    MuscleGroup.ombros => const Color(0xFF8EA7E9),
    MuscleGroup.bracos => const Color(0xFFFF8FAB),
    MuscleGroup.core => const Color(0xFF95D5B2),
    MuscleGroup.cardio => const Color(0xFFFF9F1C),
    MuscleGroup.mobilidade => const Color(0xFFA78BFA),
  };
}
