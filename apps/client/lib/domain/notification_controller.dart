import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/datasources/notification_datasource.dart';
import 'package:client/models/notification.dart';

part 'notification_controller.g.dart';

@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  StreamSubscription? _sseSubscription;

  @override
  Future<List<AppNotification>> build() async {
    // Registra a limpeza automática quando o provider for destruído
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

  void startListening() {
    _sseSubscription?.cancel();
    _sseSubscription = ref
        .read(notificationDatasourceProvider)
        .listenEvents()
        .listen(
          (eventData) {
            ref.invalidateSelf();
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
