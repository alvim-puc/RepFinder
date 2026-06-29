import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/core/http.dart';
import 'package:provider/models/application.dart';

part 'application_datasource.g.dart';

@riverpod
ApplicationDatasource applicationDatasource(ApplicationDatasourceRef ref) {
  return ApplicationDatasource(ref.read(dioProvider));
}

class ApplicationDatasource {
  final Dio _dio;

  ApplicationDatasource(this._dio);

  Future<List<Application>> listByVacancy(String vacancyId) async {
    final response = await _dio.get('/applications/vacancies/$vacancyId');
    return (response.data as List)
        .map((json) => Application.fromJson(json))
        .toList();
  }

  Future<Application> updateApplicationStatus(String id, String status) async {
    final response = await _dio.patch(
      '/applications/$id/status',
      data: {'status': status},
    );
    return Application.fromJson(response.data);
  }
}
