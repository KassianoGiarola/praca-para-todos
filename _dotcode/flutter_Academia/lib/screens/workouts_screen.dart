import 'package:flutter/material.dart';

import '../models/workout_plan.dart';
import '../services/repository_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/workout_plan_card.dart';
import 'workout_execution_screen.dart';
import 'workout_plan_form_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final plans = repository.workoutPlans;

    return Scaffold(
      appBar: AppBar(title: const Text('Treinos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Treino'),
      ),
      body: plans.isEmpty
          ? EmptyState(
              icon: Icons.assignment_add,
              title: 'Nenhum treino criado',
              message:
                  'Monte rotinas como Treino A, B ou C e defina a ordem dos exercícios.',
              actionLabel: 'Criar treino',
              onAction: () => _openForm(context),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: plans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return WorkoutPlanCard(
                  plan: plan,
                  exercises: repository.exercises,
                  onTap: () => _openForm(context, plan),
                  onStart: () {
                    repository.startSession(plan);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WorkoutExecutionScreen(),
                      ),
                    );
                  },
                  onCopy: () => repository.copyWorkoutPlan(plan.id),
                );
              },
            ),
    );
  }

  void _openForm(BuildContext context, [WorkoutPlan? plan]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkoutPlanFormScreen(plan: plan)),
    );
  }
}
