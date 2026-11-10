import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      _ => throw UnsupportedError(
        'FirebaseOptions só foram configuradas para Android e Web.',
      ),
    };
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDpkR499LhrsaLD9g1v9JwB3aLGkC7VMro',
    appId: '1:128095261088:web:459f3648c9be29151814c5',
    messagingSenderId: '128095261088',
    projectId: 'meu-treino-kassiano-2026',
    authDomain: 'meu-treino-kassiano-2026.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBe9Y-3JXwxQWqceKhueR85z_cNR7RpI6s',
    appId: '1:128095261088:android:1b6236a804755bcd1814c5',
    messagingSenderId: '128095261088',
    projectId: 'meu-treino-kassiano-2026',
  );
}
