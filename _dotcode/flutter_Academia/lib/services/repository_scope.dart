import 'package:flutter/widgets.dart';

import '../repositories/training_repository.dart';

class RepositoryScope extends InheritedNotifier<TrainingRepository> {
  const RepositoryScope({
    super.key,
    required TrainingRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static TrainingRepository watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(scope != null, 'RepositoryScope não encontrado na árvore.');
    return scope!.notifier!;
  }

  static TrainingRepository read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<RepositoryScope>();
    assert(scope != null, 'RepositoryScope não encontrado na árvore.');
    return scope!.notifier!;
  }
}
