import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/datasources/application_datasource.dart';
import 'package:provider/models/application.dart';

part 'application_controller.g.dart';

@Riverpod()
class ApplicationController extends _$ApplicationController {
  // Este controller será usado para gerenciar candidaturas de uma vaga específica
  // Portanto, o build() não listará todas, mas será chamado com um vacancyId
  // Por enquanto, deixamos vazio ou com um valor padrão.
  @override
  Future<List<Application>> build() async {
    return []; // Será carregado sob demanda por vaga
  }

  Future<List<Application>> getApplicationsForVacancy(String vacancyId) async {
    return ref.read(applicationDatasourceProvider).listByVacancy(vacancyId);
  }

  Future<void> updateStatus(
    String applicationId,
    String status,
    String vacancyId,
  ) async {
    // Atualiza o status de uma aplicação específica no servidor.
    // Quem chama este método (ex: CandidateCard) é responsável por recarregar
    // a lista da tela (ManageCandidatesScreen) depois que isto terminar,
    // pois este controller não mantém o estado por vacancyId.
    await ref
        .read(applicationDatasourceProvider)
        .updateApplicationStatus(applicationId, status);
  }
}
