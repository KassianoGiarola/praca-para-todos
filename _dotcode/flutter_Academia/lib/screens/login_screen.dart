import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loadingGoogle = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.16,
                            ),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 82,
                        height: 82,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Meu Treino',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre para salvar seus exercícios, treinos e evolução na nuvem.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _loadingGoogle ? null : _signInWithGoogle,
                    icon: _loadingGoogle
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const _GoogleMark(),
                    label: const Text('Continuar com Google'),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Sua sessão permanece ativa neste dispositivo até você sair pelo Perfil.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _messageFor(error));
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Não foi possível entrar: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingGoogle = false);
      }
    }
  }

  String _messageFor(FirebaseAuthException error) {
    return switch (error.code) {
      'popup-closed-by-user' => 'Login cancelado antes de concluir.',
      'account-exists-with-different-credential' =>
        'Já existe uma conta com este e-mail usando outro método de login.',
      'operation-not-allowed' =>
        'Este método de login ainda não está habilitado no Firebase.',
      'network-request-failed' =>
        'Falha de rede. Verifique sua conexão e tente novamente.',
      _ => error.message ?? 'Não foi possível concluir o login.',
    };
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
