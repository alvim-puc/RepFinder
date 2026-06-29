import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/core/http.dart';
import 'package:provider/models/vacancy.dart';

part 'vacancy_datasource.g.dart';

@riverpod
VacancyDatasource vacancyDatasource(VacancyDatasourceRef ref) {
  return VacancyDatasource(ref.read(dioProvider));
}

class VacancyDatasource {
  final Dio _dio;

  VacancyDatasource(this._dio);

  Future<List<Vacancy>> listMine() async {
    final response = await _dio.get('/vacancies/mine');
    return (response.data as List)
        .map((json) => Vacancy.fromJson(json))
        .toList();
  }

  Future<Vacancy> createVacancy(String title, String description) async {
    final response = await _dio.post(
      '/vacancies',
      data: {'title': title, 'description': description},
    );
    return Vacancy.fromJson(response.data);
  }

  Future<Vacancy> updateVacancy(
    String id,
    String title,
    String description,
  ) async {
    final response = await _dio.patch(
      '/vacancies/$id',
      data: {'title': title, 'description': description},
    );
    return Vacancy.fromJson(response.data);
  }

  Future<void> deleteVacancy(String id) async {
    await _dio.delete('/vacancies/$id');
  }
}
