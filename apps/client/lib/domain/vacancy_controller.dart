import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/datasources/vacancy_datasource.dart';
import 'package:client/models/vacancy.dart';
import 'package:client/core/connectivity.dart';

part 'vacancy_controller.g.dart';

@Riverpod(keepAlive: true)
class VacancyController extends _$VacancyController {
  @override
  Future<List<Vacancy>> build() async {
    ref.listen(connectivityProvider, (_, next) {
      if (next.value == true) {
        // Invalida o provider para recarregar as vagas quando a conexão voltar
        ref.invalidateSelf();
      }
    });
    return ref.read(vacancyDatasourceProvider).listAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(vacancyDatasourceProvider).listAll(),
    );
  }
}
