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
    final datasource = ref.read(notificationDatasourceProvider);

    // Inicia SSE aqui — conecta quando o provider é criado (ao logar)
    // e fica vivo até o provider ser descartado (ao deslogar)
    _sseSubscription?.cancel();
    _sseSubscription = datasource.listenEvents().listen((eventData) async {
      try {
        final updated = await datasource.listAll();
        state = AsyncData(updated);
      } catch (_) {}


      if (eventData["event"] == "application.created") {
        ref.invalidate(vacancyControllerProvider);
      }
    }, onError: (e) => print('Erro no stream SSE: $e'));

    ref.onDispose(() => _sseSubscription?.cancel());

    return datasource.listAll();
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
}
