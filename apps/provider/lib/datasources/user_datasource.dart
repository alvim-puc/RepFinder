import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/core/http.dart';
import 'package:provider/models/candidate_profile.dart';

/// Datasource para perfis públicos de usuários (ex.: dados do candidato
/// exibidos para o representante na tela de gestão de candidatos).
///
/// Provider escrito manualmente (Provider/FutureProvider.family comuns),
/// sem @riverpod/build_runner, para manter o módulo simples.
final userDatasourceProvider = Provider<UserDatasource>((ref) {
  return UserDatasource(ref.read(dioProvider));
});

class UserDatasource {
  final Dio _dio;

  UserDatasource(this._dio);

  /// GET /users/:id — perfil público (sem e-mail). É o mesmo endpoint que
  /// o app cliente usa para o próprio perfil, só que aqui sem auth.
  Future<CandidateProfile> getPublicProfile(String userId) async {
    final response = await _dio.get('/users/$userId');
    return CandidateProfile.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Cacheia o perfil público por userId (evita refazer a requisição ao
/// rolar/rebuildar a lista de candidatos).
final candidateProfileProvider =
    FutureProvider.family<CandidateProfile, String>((ref, userId) {
      return ref.read(userDatasourceProvider).getPublicProfile(userId);
    });
