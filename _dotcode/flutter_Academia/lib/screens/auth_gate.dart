import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'app_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.authService.authStateChanges,
      initialData: widget.authService.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthSplash();
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(authService: widget.authService);
        }

        return FutureBuilder<bool>(
          future: _canEnter(user),
          builder: (context, permissionSnapshot) {
            if (permissionSnapshot.connectionState != ConnectionState.done) {
              return const _AuthSplash();
            }

            if (permissionSnapshot.data == true) {
              return const AppShell();
            }

            return LoginScreen(authService: widget.authService);
          },
        );
      },
    );
  }

  Future<bool> _canEnter(User user) async {
    if (user.isAnonymous) {
      await widget.authService.signOut();
      return false;
    }

    return true;
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
