import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/core/http.dart';
import 'package:client/models/vacancy.dart';

part 'vacancy_datasource.g.dart';

@riverpod
VacancyDatasource vacancyDatasource(VacancyDatasourceRef ref) {
  return VacancyDatasource(ref.read(dioProvider));
}

class VacancyDatasource {
  final Dio _dio;

  VacancyDatasource(this._dio);

  Future<List<Vacancy>> listAll() async {
    final response = await _dio.get('/vacancies');
    return (response.data as List)
        .map((json) => Vacancy.fromJson(json))
        .toList();
  }

  Future<Vacancy> getById(String id) async {
    final response = await _dio.get('/vacancies/$id');
    return Vacancy.fromJson(response.data);
  }
}
