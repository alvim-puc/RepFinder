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
    // Atualiza o status de uma aplicação específica e recarrega a lista para a vaga
    await ref
        .read(applicationDatasourceProvider)
        .updateApplicationStatus(applicationId, status);
    // Após a atualização, recarrega a lista de candidaturas para a vaga específica
    // Isso garante que a UI que está observando esta lista seja atualizada.
    // Poderíamos otimizar para atualizar apenas o item, mas invalidar é mais simples por agora.
    ref.invalidateSelf(); // Invalida este controller para que ele recarregue
    // Como este controller não tem um build() que carrega por ID, precisamos de um mecanismo para atualizar a tela que o usa.
    // A tela de ManageCandidatesScreen precisará chamar getApplicationsForVacancy novamente.
  }
}
