import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/core/connectivity.dart';
import 'package:client/core/offline_queue.dart';
import 'package:client/datasources/application_datasource.dart';
import 'package:client/models/application.dart';
import 'package:client/core/http.dart'; // Para acessar o dioProvider

part 'application_controller.g.dart';

@Riverpod(keepAlive: true)
class ApplicationController extends _$ApplicationController {
  @override
  Future<List<Application>> build() async {
    ref.listen(connectivityProvider, (_, next) async {
      if (next.value == true) {
        // Tenta processar a fila offline ao voltar online
        await OfflineQueue.flush(ref.read(dioProvider));
        ref.invalidateSelf(); // Recarrega as candidaturas
      }
    });
    return ref.read(applicationDatasourceProvider).listMine();
  }

  Future<void> apply(String vacancyId) async {
    final isOnline = await ref.read(connectivityProvider.future);
    if (isOnline) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        await ref.read(applicationDatasourceProvider).create(vacancyId);
        return ref.read(applicationDatasourceProvider).listMine();
      });
    } else {
      await OfflineQueue.enqueue(vacancyId);
      // Mostrar um snackbar informando que a candidatura será enviada offline
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Candidatura enfileirada para envio offline.'),
        ),
      );
    }
  }

  Future<void> remove(String applicationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(applicationDatasourceProvider).delete(applicationId);
      return ref.read(applicationDatasourceProvider).listMine();
    });
  }
}
