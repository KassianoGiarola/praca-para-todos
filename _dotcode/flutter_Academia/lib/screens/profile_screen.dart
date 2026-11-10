import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/health_connect_service.dart';
import '../services/repository_scope.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.watch(context);
    final firebase = repository.firebaseStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
              StatTile(
                label: 'Exercícios',
                value: '${repository.exercises.length}',
                icon: Icons.fitness_center,
              ),
              StatTile(
                label: 'Treinos',
                value: '${repository.workoutPlans.length}',
                icon: Icons.assignment,
              ),
              StatTile(
                label: 'Sessões',
                value: '${repository.sessions.length}',
                icon: Icons.history,
              ),
            ],
          ),
          if (repository.firebaseStatus.initialized) ...[
            const SizedBox(height: 22),
            const SectionHeader(title: 'Conta'),
            const SizedBox(height: 10),
            const _AccountCard(),
          ],
          const SizedBox(height: 22),
          const SectionHeader(title: 'Relógio e saúde'),
          const SizedBox(height: 10),
          const _HealthConnectCard(),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Aparência'),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Escuro'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Claro'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.phone_android),
                label: Text('Sistema'),
              ),
            ],
            selected: {repository.themeMode},
            onSelectionChanged: (selection) {
              repository.setThemeMode(selection.first);
            },
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Firebase'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        firebase.initialized
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        color: firebase.initialized
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          firebase.initialized
                              ? 'Firebase conectado'
                              : 'Rodando com dados mockados',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    firebase.requested
                        ? firebase.errorMessage ??
                              'Firestore está configurado para persistência offline.'
                        : 'Ative com --dart-define=USE_FIREBASE=true depois de configurar o Firebase.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Modelo de dados'),
          const SizedBox(height: 10),
          const _PathCard(
            title: 'Firestore',
            paths: [
              'users/{uid}',
              'users/{uid}/exercises/{exerciseId}',
              'users/{uid}/workoutPlans/{planId}',
              'users/{uid}/sessions/{sessionId}',
            ],
          ),
          const SizedBox(height: 10),
          const _PathCard(
            title: 'Mídia no Spark',
            paths: [
              'exercises/{exerciseId}.mediaUrl',
              'exercises/{exerciseId}.thumbnailUrl',
              'Use URLs externas, assets do app ou Firebase Hosting.',
              'Sem upload para Firebase Storage no plano Spark.',
            ],
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () {
              repository.resetMockData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    repository.firebaseStatus.initialized
                        ? 'Importando ficha Bioforma no Firestore.'
                        : 'Ficha Bioforma restaurada.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.restart_alt),
            label: Text(
              repository.firebaseStatus.initialized
                  ? 'Importar ficha Bioforma'
                  : 'Restaurar ficha Bioforma',
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatefulWidget {
  const _AccountCard();

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  final _authService = AuthService();
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      initialData: _authService.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final title = user.displayName ?? user.email ?? 'Conta Google';
        final subtitle = user.email ?? user.uid;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.photoURL == null
                          ? null
                          : NetworkImage(user.photoURL!),
                      child: user.photoURL == null
                          ? const Icon(Icons.account_circle_outlined)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signingOut ? null : _signOut,
                    icon: _signingOut
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: const Text('Sair da conta'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Você voltará para a tela de login neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _signingOut = true);
    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authMessage(error))));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível sair da conta. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  String _authMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'network-request-failed' =>
        'Falha de rede. Verifique sua conexão e tente sair novamente.',
      _ => error.message ?? 'Não foi possível sair da conta.',
    };
  }
}

class _HealthConnectCard extends StatefulWidget {
  const _HealthConnectCard();

  @override
  State<_HealthConnectCard> createState() => _HealthConnectCardState();
}

class _HealthConnectCardState extends State<_HealthConnectCard> {
  final _healthService = HealthConnectService();
  HealthConnectAvailability? _availability;
  bool _hasPermissions = false;
  bool _loading = true;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusText();
    final icon = _hasPermissions
        ? Icons.health_and_safety_outlined
        : Icons.monitor_heart_outlined;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Health Connect',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (_loading)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading || _working ? null : _handlePrimaryAction,
                icon: _working
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_primaryIcon()),
                label: Text(_primaryLabel()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    final availability = await _healthService.checkAvailability();
    final hasPermissions =
        availability == HealthConnectAvailability.available &&
        await _healthService.hasPermissions();
    if (!mounted) {
      return;
    }
    setState(() {
      _availability = availability;
      _hasPermissions = hasPermissions;
      _loading = false;
    });
  }

  Future<void> _handlePrimaryAction() async {
    setState(() => _working = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final availability =
          _availability ?? await _healthService.checkAvailability();
      if (availability == HealthConnectAvailability.unavailable ||
          availability == HealthConnectAvailability.updateRequired) {
        await _healthService.installHealthConnect();
        return;
      }

      if (availability != HealthConnectAvailability.available) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Health Connect só está disponível no Android.'),
          ),
        );
        return;
      }

      final granted = await _healthService.requestPermissions();
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Permissões do Health Connect liberadas.'
                : 'Permissões não liberadas.',
          ),
        ),
      );
    } on Object {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o Health Connect.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _working = false);
        await _loadStatus();
      }
    }
  }

  String _statusText() {
    if (_loading) {
      return 'Verificando integração com o relógio.';
    }
    if (_hasPermissions) {
      return 'Permissões liberadas para batimentos e calorias.';
    }

    return switch (_availability) {
      HealthConnectAvailability.available =>
        'Conecte para ler batimentos e calorias dos treinos sincronizados.',
      HealthConnectAvailability.updateRequired =>
        'Health Connect precisa ser atualizado neste aparelho.',
      HealthConnectAvailability.unavailable =>
        'Health Connect não está instalado neste aparelho.',
      HealthConnectAvailability.unsupportedPlatform =>
        'Disponível no app Android.',
      HealthConnectAvailability.unknown ||
      null => 'Não foi possível verificar o Health Connect.',
    };
  }

  String _primaryLabel() {
    return switch (_availability) {
      HealthConnectAvailability.unavailable ||
      HealthConnectAvailability.updateRequired => 'Instalar Health Connect',
      HealthConnectAvailability.unsupportedPlatform => 'Indisponível aqui',
      _ => _hasPermissions ? 'Revalidar permissões' : 'Conectar Health Connect',
    };
  }

  IconData _primaryIcon() {
    return switch (_availability) {
      HealthConnectAvailability.unavailable ||
      HealthConnectAvailability.updateRequired => Icons.download_outlined,
      HealthConnectAvailability.unsupportedPlatform => Icons.phone_android,
      _ => Icons.verified_user_outlined,
    };
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.title, required this.paths});

  final String title;
  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            for (final path in paths)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  path,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
