// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vacancy _$VacancyFromJson(Map<String, dynamic> json) => Vacancy(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  providerId: json['providerId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$VacancyToJson(Vacancy instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'providerId': instance.providerId,
  'createdAt': instance.createdAt.toIso8601String(),
};
