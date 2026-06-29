/// Representa o perfil público de um usuário (GET /users/:id), usado para
/// mostrar nome, sexo, foto e bio do candidato a uma vaga.
///
/// Parsing feito manualmente (sem @JsonSerializable/build_runner) porque é
/// um modelo pequeno e somente leitura.
class CandidateProfile {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? bio;
  final String? gender; // 'female' | 'male' | 'non_binary' | 'other'

  CandidateProfile({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.gender,
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> json) {
    return CandidateProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
    );
  }

  /// Rótulo em português para exibição na UI.
  String get genderLabel {
    switch (gender) {
      case 'female':
        return 'Feminino';
      case 'male':
        return 'Masculino';
      case 'non_binary':
        return 'Não-binário';
      case 'other':
        return 'Outro';
      default:
        return 'Não informado';
    }
  }
}
