# Meu Treino

App Flutter para Android e Web para controlar exercícios de academia, montar rotinas, registrar séries/repetições/cargas e acompanhar evolução.

## Stack

- Flutter 3 / Dart 3
- Material 3
- Firebase Auth
- Cloud Firestore
- Mídia por URL externa, assets do app ou Firebase Hosting
- `video_player` para previews de vídeos demonstrativos
- `health` para leitura de batimentos e calorias via Health Connect no Android
- Dados mockados offline por padrão

## Funcionalidades da primeira versão

- Aba **Hoje** com treino planejado, progresso, início/continuação de treino e tempo total.
- Cadastro e edição de exercícios com grupo muscular, equipamento, séries, reps, carga, descanso, instruções, URL de vídeo/gif e thumbnail.
- Biblioteca de exercícios com busca, filtro por grupo muscular, detalhes e preview de vídeo em loop/mudo.
- Criação e edição de treinos, ordenação de exercícios, metas por exercício e cópia de rotina.
- Execução de treino com exercício atual, mídia, registro de séries, reps/carga, descanso automático, pular/voltar e salvar sessão.
- Finalização de treino com feedback de esforço, observação opcional e tentativa de sincronização com Health Connect.
- Progresso com histórico, volume, séries, recordes simples por exercício e resumo do relógio quando sincronizado.
- Perfil com status Firebase/mock, Health Connect, alternância de tema e caminhos do modelo de dados.

## Rodando localmente

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

O app roda com dados mockados sem Firebase:

```bash
flutter run
```

Para rodar no Chrome:

```bash
flutter run -d chrome
```

## Firebase

O projeto Firebase dedicado já foi criado e vinculado ao Android e Web:

- Projeto: `meu-treino-kassiano-2026`
- App Android: `br.com.meutreino.meu_treino`
- App Web: `Meu Treino Web`
- Config Android: `android/app/google-services.json`
- Opções Flutter: `lib/firebase_options.dart`
- Firestore: banco `(default)` criado em `southamerica-east1`
- Regras Firestore: publicadas a partir de `firestore.rules`
- Authentication Google: habilitado no console
- Com `USE_FIREBASE=true`, exercícios, treinos e sessões são salvos em Firestore por usuário autenticado.

Para rodar usando a inicialização Firebase:

```bash
flutter run --dart-define=USE_FIREBASE=true
```

No Chrome:

```bash
flutter run -d chrome --dart-define=USE_FIREBASE=true
```

Se a inicialização falhar, o app continua em modo mock e mostra o erro na aba Perfil.

Com Firebase ativo, o app mostra uma tela de login antes das abas principais. O login principal é feito com Google, e a sessão permanece salva no dispositivo/navegador até o usuário sair pela aba Perfil.

Na aba Perfil, use **Importar ficha Bioforma** para gravar/restaurar os exercícios e treinos iniciais no Firestore do usuário atual.

Para Android debug, as digitais SHA-1/SHA-256 do debug keystore local já foram registradas no Firebase e `android/app/google-services.json` foi atualizado. Para publicar uma versão release, registre também as digitais SHA da chave de assinatura de produção e baixe novamente o `google-services.json`.

### Firebase Hosting

O Hosting está configurado para publicar o build Flutter Web em `build/web`.

Build de produção:

```bash
flutter build web --dart-define=USE_FIREBASE=true
```

Deploy:

```bash
firebase deploy --only hosting --project meu-treino-kassiano-2026
```

URL:

- `https://meu-treino-kassiano-2026.web.app`

### Plano Spark

Este projeto deve permanecer no plano Spark. Por isso, o app não usa Firebase Storage para upload de vídeos/thumbnails.

Para mídia demonstrativa dos exercícios, use uma destas opções:

- URLs externas HTTPS nos campos `mediaUrl` e `thumbnailUrl`.
- Arquivos empacotados como assets do app.
- Arquivos estáticos publicados no Firebase Hosting, dentro da cota Spark.

Firebase Storage para novos projetos exige Blaze/billing para provisionar e acessar buckets. Como a meta aqui é Spark, `storage.rules` e upload via Storage não fazem parte do fluxo ativo.

## Amazfit, Zepp e Health Connect

A integração do relógio é feita no Android pelo Health Connect:

1. Sincronize o Amazfit GTR 3 Pro no app Zepp.
2. No Zepp/Google Fit/Health Connect, permita que os dados do Zepp cheguem ao Health Connect.
3. No Meu Treino Android, abra Perfil > Relógio e saúde > Conectar Health Connect.
4. Libere leitura de batimentos e calorias.
5. Ao finalizar um treino, o app tenta sincronizar automaticamente usando o horário de início/fim da sessão.
6. Se os dados ainda não aparecerem, abra o Zepp, sincronize o relógio e toque em **Sincronizar relógio** no card do treino em Progresso.

O app salva no documento da sessão:

- `healthSummary.averageHeartRateBpm`
- `healthSummary.minHeartRateBpm`
- `healthSummary.maxHeartRateBpm`
- `healthSummary.activeCaloriesKcal`
- `healthSummary.totalCaloriesKcal`
- `healthSummary.sourceName`
- `healthSummary.syncedAt`

A integração não fica disponível no Flutter Web, porque Health Connect depende do Android físico.

## Modelo de dados previsto

Firestore:

- `users/{uid}`
- `users/{uid}/exercises/{exerciseId}`
- `users/{uid}/workoutPlans/{planId}`
- `users/{uid}/sessions/{sessionId}`

Mídia:

- `users/{uid}/exercises/{exerciseId}.mediaUrl`
- `users/{uid}/exercises/{exerciseId}.thumbnailUrl`

## Organização

- `lib/models`: entidades de exercícios, treinos, sessões e recordes.
- `lib/repositories`: repositório mock e repositório preparado para Firestore.
- `lib/services`: Firebase bootstrap, Auth, Firestore, Health Connect e escopo de dependência.
- `lib/screens`: telas principais do app.
- `lib/widgets`: componentes reutilizáveis.
- `lib/theme`: tema Material 3 claro/escuro.
- `lib/utils`: formatadores, cores e helpers.
