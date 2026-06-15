import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/core/http.dart';
import 'package:client/models/application.dart';

part 'application_datasource.g.dart';

@riverpod
ApplicationDatasource applicationDatasource(ApplicationDatasourceRef ref) {
  return ApplicationDatasource(ref.read(dioProvider));
}

class ApplicationDatasource {
  final Dio _dio;

  ApplicationDatasource(this._dio);

  Future<Application> create(String vacancyId) async {
    final response = await _dio.post(
      '/applications',
      data: {'vacancyId': vacancyId},
    );
    return Application.fromJson(response.data);
  }

  Future<List<Application>> listMine() async {
    final response = await _dio.get('/applications/mine');
    return (response.data as List)
        .map((json) => Application.fromJson(json))
        .toList();
  }

  Future<void> delete(String id) async {
    await _dio.delete('/applications/$id');
  }
}
