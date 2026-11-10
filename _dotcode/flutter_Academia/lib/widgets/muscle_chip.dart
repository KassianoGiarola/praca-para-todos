import 'package:flutter/material.dart';

import '../models/muscle_group.dart';
import '../utils/group_colors.dart';

class MuscleChip extends StatelessWidget {
  const MuscleChip({
    super.key,
    required this.group,
    this.selected = false,
    this.onSelected,
  });

  final MuscleGroup group;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final color = group.accentColor;
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      label: Text(group.label),
      avatar: CircleAvatar(backgroundColor: color, radius: 5),
      selectedColor: color.withValues(alpha: 0.22),
      checkmarkColor: color,
    );
  }
}
