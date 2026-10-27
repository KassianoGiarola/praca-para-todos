import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseStatus {
  const FirebaseStatus({
    required this.requested,
    required this.initialized,
    this.errorMessage,
  });

  final bool requested;
  final bool initialized;
  final String? errorMessage;

  bool get usingMockData => !initialized;

  factory FirebaseStatus.disabled() {
    return const FirebaseStatus(requested: false, initialized: false);
  }
}

class FirebaseBootstrap {
  static const useFirebase = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: false,
  );

  static Future<FirebaseStatus> initialize() async {
    if (!useFirebase) {
      return FirebaseStatus.disabled();
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      return const FirebaseStatus(requested: true, initialized: true);
    } on Object catch (error) {
      return FirebaseStatus(
        requested: true,
        initialized: false,
        errorMessage: error.toString(),
      );
    }
  }
}
