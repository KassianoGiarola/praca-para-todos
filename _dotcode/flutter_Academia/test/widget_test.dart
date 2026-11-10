import 'package:flutter_test/flutter_test.dart';
import 'package:meu_treino/main.dart';
import 'package:meu_treino/repositories/training_repository.dart';
import 'package:meu_treino/services/firebase_bootstrap.dart';

void main() {
  testWidgets('mostra a tela inicial do Meu Treino', (tester) async {
    final repository = MockTrainingRepository(
      firebaseStatus: FirebaseStatus.disabled(),
    );

    await tester.pumpWidget(MeuTreinoApp(repository: repository));

    expect(find.text('Hoje'), findsWidgets);
    expect(find.text('Plano do dia'), findsOneWidget);
    expect(find.text('Iniciar treino'), findsOneWidget);
  });
}
