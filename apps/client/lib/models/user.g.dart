// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  gender: json['gender'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'gender': instance.gender,
};
