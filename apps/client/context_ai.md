# Flutter Client App — RepFinder (Estudante)

## Contexto

Você está implementando o app mobile do estudante para o **RepFinder**, uma plataforma
que conecta estudantes que buscam moradia em repúblicas universitárias com representantes
que gerenciam essas repúblicas.

O projeto já tem um backend REST + SSE funcionando. Seu trabalho é implementar o app
Flutter do estudante do zero, a partir de um projeto criado com `flutter create client`.

---

## Stack obrigatória

Adicione estas dependências no `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP + cache
  dio: ^5.4.0
  dio_cache_interceptor: ^3.5.0

  # Estado
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Persistência segura
  flutter_secure_storage: ^9.0.0

  # Persistência simples
  shared_preferences: ^2.2.0

  # Conectividade
  connectivity_plus: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0
```

---

## Estrutura de pastas

Organize o projeto exatamente assim dentro de `lib/`:

```
lib/
├── main.dart
├── core/
│   ├── http.dart           # Dio configurado com cache + auth interceptor
│   ├── storage.dart        # SecureStorage wrapper
│   ├── connectivity.dart   # StreamProvider de conectividade
│   ├── offline_queue.dart  # Fila de ações offline
│   └── errors.dart         # AppException com código e mensagem
├── models/
│   ├── user.dart
│   ├── vacancy.dart
│   ├── application.dart
│   └── notification.dart
├── datasources/
│   ├── auth_datasource.dart
│   ├── vacancy_datasource.dart
│   ├── application_datasource.dart
│   └── notification_datasource.dart
├── domain/
│   ├── auth_controller.dart
│   ├── vacancy_controller.dart
│   ├── application_controller.dart
│   └── notification_controller.dart
├── screens/
│   ├── login_screen.dart
│   ├── vacancies_screen.dart
│   ├── profile_screen.dart
│   └── notifications_screen.dart
└── widgets/
    ├── vacancy_card.dart
    ├── application_status_chip.dart
    └── notification_item.dart
```

---

## API base URL

```
http://10.0.2.2:3030/api   ← emulador Android
http://localhost:3030/api  ← iOS simulator / web
```

Use uma constante em `core/http.dart`. Deixe comentado como trocar para produção.

---

## Contratos da API (use exatamente esses shapes)

### Autenticação

**POST /users/register**
```json
// request
{ "name": "string", "email": "string", "password": "string", "role": "student" }

// response 201
{ "user": { "id": "uuid", "name": "string", "email": "string", "role": "student" }, "token": "jwt" }
```

**POST /users/login**
```json
// request
{ "email": "string", "password": "string" }

// response 200
{ "user": { "id": "uuid", "name": "string", "email": "string", "role": "student" }, "token": "jwt" }
```

**GET /users/me** — Bearer token obrigatório
```json
// response 200
{ "id": "uuid", "name": "string", "email": "string", "role": "student" }
```

**PATCH /users/me** — Bearer token obrigatório
```json
// request (todos opcionais)
{ "name": "string", "email": "string", "password": "string" }

// response 200 — mesmo shape de User
```

### Vagas

**GET /vacancies** — público, sem token
```json
// response 200
[{ "id": "uuid", "title": "string", "description": "string", "providerId": "uuid", "createdAt": "iso" }]
```

**GET /vacancies/:id** — público
```json
// response 200 — mesmo shape de Vacancy
```

### Candidaturas

**POST /applications** — Bearer token obrigatório
```json
// request
{ "vacancyId": "uuid" }

// response 201
{ "id": "uuid", "userId": "uuid", "vacancyId": "uuid", "status": "pending", "createdAt": "iso" }
```

**GET /applications/mine** — Bearer token obrigatório
```json
// response 200
[{ "id": "uuid", "userId": "uuid", "vacancyId": "uuid", "status": "pending|accepted|rejected", "createdAt": "iso" }]
```

**DELETE /applications/:id** — Bearer token obrigatório
```json
// response 200 — só funciona se status = "pending"
{ "ok": true }
```

### Notificações

**GET /notifications** — Bearer token obrigatório
```json
// response 200
[{
  "id": "uuid",
  "userId": "uuid",
  "event": "application.status.updated",
  "data": { "applicationId": "uuid", "status": "accepted|rejected", "occurredAt": "iso" },
  "readed_at": "iso | null",
  "createdAt": "iso"
}]
```

**PATCH /notifications/:id/read** — Bearer token obrigatório
```json
// request — body vazio {}
// response 200 — Notification com readed_at preenchido
```

**GET /notifications/events** — Bearer token obrigatório, SSE stream
```
// cada evento tem o formato:
event: application.status.updated
data: {"applicationId":"uuid","status":"accepted|rejected","occurredAt":"iso"}
```

---

## Models

Implemente os models com `fromJson` factory e `toJson`. Tipos exatos:

```dart
// user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role; // sempre "student" neste app
}

// vacancy.dart
class Vacancy {
  final String id;
  final String title;
  final String description;
  final String providerId;
  final DateTime createdAt;
}

// application.dart
class Application {
  final String id;
  final String userId;
  final String vacancyId;
  final String status; // "pending" | "accepted" | "rejected"
  final DateTime createdAt;
}

// notification.dart
class AppNotification {
  final String id;
  final String userId;
  final String event;
  final Map<String, dynamic> data;
  final DateTime? readedAt;   // campo "readed_at" na API
  final DateTime createdAt;
}
```

---

## core/storage.dart

```dart
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _tokenKey = 'auth_token';
  static const _userKey  = 'auth_user';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: _tokenKey);

  static Future<void> saveUser(User user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  static Future<User?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw));
  }

  static Future<void> clear() => _storage.deleteAll();
}
```

---

## core/http.dart

Configure o Dio com:
- `baseUrl` apontando para a API
- `DioCacheInterceptor` com `MemCacheStore`, TTL de 1 hora, `hitCacheOnErrorExcept: [401, 403]`
- `AuthInterceptor` que lê o token via `SecureStorage.getToken()` e injeta em `Authorization: Bearer <token>`
- Em erro 401, chama `SecureStorage.clear()` e navega para login usando uma `GlobalKey<NavigatorState>`

---

## core/connectivity.dart

```dart
// StreamProvider<bool> que emite true quando online, false quando offline
// Usa connectivity_plus
// Ao voltar online, invalida todos os providers que precisam de refresh
```

---

## core/offline_queue.dart

Implemente uma fila simples com `SharedPreferences` para a ação de candidatura:

- `enqueue(String vacancyId)` — salva em `shared_preferences` como lista JSON
- `flush(Dio dio)` — tenta executar cada item da fila, para na primeira falha
- Chamado automaticamente quando `connectivityProvider` emite `true`

---

## Datasources

Cada datasource recebe `Dio` via construtor (injetado pelo Riverpod). Sem lógica de
negócio — só chamadas HTTP, parse de response e throw de `AppException` em erros.

**auth_datasource.dart**
- `register(name, email, password)` → `AuthResponse`
- `login(email, password)` → `AuthResponse`
- `getMe()` → `User`
- `updateMe({name, email, password})` → `User`

**vacancy_datasource.dart**
- `listAll()` → `List<Vacancy>`
- `getById(id)` → `Vacancy`

**application_datasource.dart**
- `create(vacancyId)` → `Application`
- `listMine()` → `List<Application>`
- `delete(id)` → `void`

**notification_datasource.dart**
- `listAll()` → `List<AppNotification>`
- `markRead(id)` → `AppNotification`
- `listenEvents()` → `Stream<Map<String,dynamic>>` usando `http` package para SSE
  - Conecta em `GET /notifications/events` com Bearer token
  - Parseia linhas no formato SSE (`event:` + `data:`)
  - Emite cada evento como Map

---

## Controllers (Riverpod)

Use `@riverpod` annotation e `build_runner` para geração de código.

**auth_controller.dart**
```dart
// AuthState = AsyncValue<User?>
// build(): lê SecureStorage, retorna User salvo ou null
// login(email, password): chama datasource, salva token + user, atualiza state
// register(name, email, password): igual ao login após registro
// logout(): SecureStorage.clear(), state = null
// updateMe({name, email, password}): chama datasource, atualiza user salvo
```

**vacancy_controller.dart**
```dart
// build(): chama vacancyDatasource.listAll()
// Adiciona listener de connectivityProvider para invalidateSelf() ao voltar online
```

**application_controller.dart**
```dart
// build(): chama applicationDatasource.listMine()
// apply(vacancyId): verifica conectividade
//   - online: chama datasource.create(), invalidateSelf()
//   - offline: enfileira via offlineQueue, mostra snackbar
// remove(applicationId): chama datasource.delete(), invalidateSelf()
```

**notification_controller.dart**
```dart
// build(): chama notificationDatasource.listAll()
// markRead(id): chama datasource.markRead(), atualiza item na lista local
// startListening(): conecta SSE via datasource.listenEvents()
//   - ao receber evento, chama invalidateSelf() para recarregar lista
```

---

## Screens

### login_screen.dart

- Tabs "Entrar" / "Cadastrar" no topo
- Formulário de login: email + senha + botão "Entrar"
- Formulário de cadastro: nome + email + senha + botão "Cadastrar"
  - Role fixa como "student" — não mostrar seletor
- Validação local: campos obrigatórios, email válido, senha ≥ 6 chars
- Loading state no botão enquanto processa
- Erro da API exibido como snackbar
- Após sucesso: navega para `/vacancies` e remove login da stack

### vacancies_screen.dart

- AppBar com título "RepFinder" e ícone de sino (badge com contagem de não lidas)
  - Sino navega para `/notifications`
- Lista de vagas em cards (`VacancyCard`)
- Pull-to-refresh que invalida o provider
- Loading: `CircularProgressIndicator` centralizado
- Erro: mensagem + botão retry
- Empty state: ícone + "Nenhuma vaga disponível no momento"
- Tap no card abre bottom sheet com detalhes da vaga:
  - Título, descrição completa, data de criação
  - Botão "Me candidatar"
    - Se já tem candidatura para essa vaga: botão desabilitado "Já candidatado"
    - Se offline: botão "Candidatar (offline)" que enfileira
  - Feedback de sucesso/erro via snackbar

### profile_screen.dart

- Header colorido com avatar (iniciais do nome), nome, badge "Estudante"
- Seção de informações: email (read-only na visualização)
- Botão "Editar perfil" que abre bottom sheet com form de edição (nome, email, senha)
- Seção "Minhas Candidaturas":
  - Lista compacta de candidaturas com título da vaga e chip de status
  - Status chips: pending=cinza, accepted=verde, rejected=vermelho
  - Candidaturas pending têm botão de cancelar (swipe ou ícone)
- Botão "Sair" no final (vermelho, outlined)
- Bottom navigation bar com 3 itens: Vagas / Perfil / Notificações

### notifications_screen.dart

- AppBar "Notificações" com botão voltar
- Tabs "Todas" / "Não lidas" (com badge de contagem)
- Lista de `NotificationItem` widgets
- Tap em item: marca como lida + exibe detalhes em snackbar ou dialog
- Empty state por tab
- Inicia SSE listener ao entrar na tela (`notificationController.startListening()`)
- Para SSE ao sair da tela (`dispose`)

---

## Widgets

### vacancy_card.dart
- Card com título, trecho da descrição (2 linhas, overflow ellipsis)
- Data de criação formatada ("há X dias")
- Botão "Ver detalhes" que recebe `onTap` como callback

### application_status_chip.dart
- Chip com cor e label baseado no status:
  - pending → cinza, "Pendente"
  - accepted → verde, "Aceita"
  - rejected → vermelho, "Recusada"

### notification_item.dart
- Ícone colorido à esquerda (verde=aceita, vermelho=recusada)
- Título bold + subtítulo com detalhes
- Timestamp relativo à direita ("há 2min")
- Fundo levemente tintado se `readed_at == null`

---

## Navegação

Use `Navigator` simples com rotas nomeadas em `main.dart`:

```dart
routes: {
  '/':             (ctx) => AuthGate(),      // verifica token, redireciona
  '/login':        (ctx) => LoginScreen(),
  '/vacancies':    (ctx) => VacanciesScreen(),
  '/profile':      (ctx) => ProfileScreen(),
  '/notifications':(ctx) => NotificationsScreen(),
}
```

**AuthGate**: widget que lê `authController`, se `user != null` vai para `/vacancies`,
senão vai para `/login`. Mostra loading enquanto `AsyncValue` está em loading.

---

## Tratamento de erros

Crie `AppException` com `statusCode` e `message`. No `AuthInterceptor`:
- 400 → `AppException('Dados inválidos', 400)`
- 401 → limpa storage, navega para login
- 403 → `AppException('Sem permissão', 403)`
- 404 → `AppException('Não encontrado', 404)`
- 409 → `AppException('Conflito: ${response.data['error']}', 409)`
- outros → `AppException('Erro inesperado', statusCode)`

---

## Observações finais

- O campo `role` no registro deve ser sempre `"student"` — hardcoded no datasource
- O campo `readed_at` vem da API como string ISO ou null — mapeie para `DateTime?`
- SSE: a conexão deve ser reestabelecida automaticamente se cair (retry com delay de 3s)
- Não implemente nada relacionado a criar/editar/deletar vagas — isso é exclusivo do app representante
- Não implemente `PATCH /applications/:id/status` — isso é exclusivo do representante
- Após `flutter pub get`, rode `dart run build_runner build` para gerar o código Riverpod
