import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/datasources/notification_datasource.dart';
import 'package:provider/models/notification.dart';
import 'package:provider/domain/vacancy_controller.dart';

part 'notification_controller.g.dart';

@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  StreamSubscription? _sseSubscription;

  @override
  Future<List<AppNotification>> build() async {
    ref.onDispose(() {
      _sseSubscription?.cancel();
    });

    return ref.read(notificationDatasourceProvider).listAll();
  }

  Future<void> markRead(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedNotification = await ref
          .read(notificationDatasourceProvider)
          .markRead(id);
      final currentList = state.value ?? [];
      return currentList
          .map((n) => n.id == id ? updatedNotification : n)
          .toList();
    });
  }

  /// Conecta ao stream SSE. Deve ser chamado apenas enquanto a tela de
  /// notificações estiver aberta (mesmo padrão do app cliente).
  void startListening() {
    _sseSubscription?.cancel();
    _sseSubscription = ref
        .read(notificationDatasourceProvider)
        .listenEvents()
        .listen(
          (eventData) {
            ref.invalidateSelf(); // Recarrega a lista de notificações
            // Uma nova candidatura impacta a contagem/lista de vagas do
            // representante, então recarregamos esse provider também.
            if (eventData["event"] == "application.created") {
              ref.invalidate(vacancyControllerProvider);
            }
          },
          onError: (error) {
            print('Erro no stream SSE: $error');
          },
        );
  }

  void stopListening() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }
}
