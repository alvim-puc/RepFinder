import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/datasources/vacancy_datasource.dart';
import 'package:provider/models/vacancy.dart';

part 'vacancy_controller.g.dart';

@Riverpod(keepAlive: true)
class VacancyController extends _$VacancyController {
  @override
  Future<List<Vacancy>> build() async {
    return ref.read(vacancyDatasourceProvider).listMine();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(vacancyDatasourceProvider).listMine(),
    );
  }

  Future<void> createVacancy(String title, String description) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newVacancy = await ref
          .read(vacancyDatasourceProvider)
          .createVacancy(title, description);
      return [...state.value ?? [], newVacancy];
    });
  }

  Future<void> updateVacancy(
    String id,
    String title,
    String description,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedVacancy = await ref
          .read(vacancyDatasourceProvider)
          .updateVacancy(id, title, description);
      return state.value!.map((v) => v.id == id ? updatedVacancy : v).toList();
    });
  }

  Future<void> deleteVacancy(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(vacancyDatasourceProvider).deleteVacancy(id);
      return state.value!.where((v) => v.id != id).toList();
    });
  }
}
