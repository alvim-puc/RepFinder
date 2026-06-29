// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  id: json['id'] as String,
  userId: json['userId'] as String,
  vacancyId: json['vacancyId'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  applicantName: json['applicantName'] as String?,
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'vacancyId': instance.vacancyId,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'applicantName': instance.applicantName,
    };
