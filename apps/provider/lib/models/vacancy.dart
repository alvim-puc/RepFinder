import 'package:json_annotation/json_annotation.dart';

part 'vacancy.g.dart';

@JsonSerializable()
class Vacancy {
  final String id;
  final String title;
  final String description;
  final String providerId;
  final DateTime createdAt;
  final int applicantsCount; // Novo campo para o app do representante

  Vacancy({
    required this.id,
    required this.title,
    required this.description,
    required this.providerId,
    required this.createdAt,
    this.applicantsCount = 0, // Valor padrão
  });

  factory Vacancy.fromJson(Map<String, dynamic> json) =>
      _$VacancyFromJson(json);
  Map<String, dynamic> toJson() => _$VacancyToJson(this);
}
