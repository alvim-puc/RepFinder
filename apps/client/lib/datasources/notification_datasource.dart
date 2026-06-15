import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/core/http.dart';
import 'package:client/models/notification.dart';
import 'package:http/http.dart' as http;
import 'package:client/core/storage.dart';

part 'notification_datasource.g.dart';

@riverpod
NotificationDatasource notificationDatasource(NotificationDatasourceRef ref) {
  return NotificationDatasource(ref.read(dioProvider));
}

class NotificationDatasource {
  final Dio _dio;

  NotificationDatasource(this._dio);

  Future<List<AppNotification>> listAll() async {
    final response = await _dio.get('/notifications');
    return (response.data as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  Future<AppNotification> markRead(String id) async {
    final response = await _dio.patch('/notifications/$id/read');
    return AppNotification.fromJson(response.data);
  }

  Stream<Map<String, dynamic>> listenEvents() async* {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado para SSE');
    }

    final uri = Uri.parse('${_dio.options.baseUrl}/notifications/events');
    final client = http.Client();

    while (true) {
      try {
        final request = http.Request('GET', uri);
        request.headers['Authorization'] = 'Bearer $token';
        final response = await client.send(request);

        if (response.statusCode == 200) {
          await for (var chunk in response.stream.transform(utf8.decoder)) {
            final lines = chunk.split('\n');
            String? event;
            String? data;
            for (var line in lines) {
              if (line.startsWith('event: ')) {
                event = line.substring(7);
              } else if (line.startsWith('data: ')) {
                data = line.substring(6);
              }

              if (event != null && data != null) {
                yield {'event': event, 'data': jsonDecode(data)};
                event = null;
                data = null;
              }
            }
          }
        } else {
          throw Exception('Erro ao conectar ao SSE: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro na conexão SSE: $e. Tentando reconectar em 3 segundos...');
        await Future.delayed(Duration(seconds: 3));
      }
    }
  }
}
