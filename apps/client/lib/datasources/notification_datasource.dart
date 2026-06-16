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
    int reconnectDelaySeconds = 1;
    const maxReconnectDelaySeconds = 30;

    while (true) {
      final token = await SecureStorage.getToken();
      if (token == null) {
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      final uri = Uri.parse('${_dio.options.baseUrl}/notifications/events');
      final client = http.Client();

      try {
        final request = http.Request('GET', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Cache-Control'] = 'no-cache';
        request.headers['Accept'] = 'text/event-stream';

        final response = await client.send(request);

        if (response.statusCode == 200) {
          reconnectDelaySeconds = 1;
          await for (var chunk in response.stream.transform(utf8.decoder)) {
            final lines = chunk.split('\n');
            String? event;
            String? data;
            for (var line in lines) {
              if (line.startsWith('event: '))
                event = line.substring(7);
              else if (line.startsWith('data: '))
                data = line.substring(6);

              if (event != null && data != null) {
                yield {'event': event, 'data': jsonDecode(data)};
                event = null;
                data = null;
              }
            }
          }
        } else if (response.statusCode == 401) {
          await SecureStorage.clear();
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
          break;
        } else {
          await Future.delayed(Duration(seconds: reconnectDelaySeconds));
          reconnectDelaySeconds = (reconnectDelaySeconds * 2).clamp(
            1,
            maxReconnectDelaySeconds,
          );
        }
      } catch (e) {
        await Future.delayed(Duration(seconds: reconnectDelaySeconds));
        reconnectDelaySeconds = (reconnectDelaySeconds * 2).clamp(
          1,
          maxReconnectDelaySeconds,
        );
      } finally {
        client.close();
      }
    }
  }
}
