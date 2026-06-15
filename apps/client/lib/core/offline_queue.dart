import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueue {
  static const _queueKey = 'offline_application_queue';

  static Future<void> enqueue(String vacancyId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawQueue = prefs.getStringList(_queueKey) ?? [];
    rawQueue.add(vacancyId);
    await prefs.setStringList(_queueKey, rawQueue);
  }

  static Future<List<String>> _getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_queueKey) ?? [];
  }

  static Future<void> _clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  static Future<void> flush(Dio dio) async {
    final queue = await _getQueue();
    if (queue.isEmpty) return;

    List<String> failedItems = [];
    for (final vacancyId in queue) {
      try {
        await dio.post('/applications', data: {'vacancyId': vacancyId});
      } on DioException catch (e) {
        // Se falhar, adiciona de volta à fila e para.
        // A fila será tentada novamente na próxima vez que ficar online.
        failedItems.add(vacancyId);
        break;
      }
    }

    if (failedItems.isEmpty) {
      await _clearQueue();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_queueKey, failedItems);
    }
  }
}
