import 'package:flutter/material.dart';

import 'repositories/firestore_training_repository.dart';
import 'repositories/training_repository.dart';
import 'screens/app_shell.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firebase_bootstrap.dart';
import 'services/repository_scope.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  final authService = AuthService();
  if (firebaseStatus.initialized) {
    await authService.configurePersistence();
  }
  final TrainingRepository repository = firebaseStatus.initialized
      ? FirestoreTrainingRepository(
          firebaseStatus: firebaseStatus,
          authService: authService,
        )
      : MockTrainingRepository(firebaseStatus: firebaseStatus);
  runApp(MeuTreinoApp(repository: repository, authService: authService));
}

class MeuTreinoApp extends StatelessWidget {
  const MeuTreinoApp({super.key, required this.repository, this.authService});

  final TrainingRepository repository;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        return RepositoryScope(
          repository: repository,
          child: MaterialApp(
            title: 'Meu Treino',
            debugShowCheckedModeBanner: false,
            themeMode: repository.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: repository.firebaseStatus.initialized
                ? AuthGate(authService: authService ?? AuthService())
                : const AppShell(),
          ),
        );
      },
    );
  }
}
