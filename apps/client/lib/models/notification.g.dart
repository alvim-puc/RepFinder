// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      event: json['event'] as String,
      data: json['data'] as Map<String, dynamic>,
      readedAt: json['readed_at'] == null
          ? null
          : DateTime.parse(json['readed_at'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'event': instance.event,
      'data': instance.data,
      'readed_at': instance.readedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
