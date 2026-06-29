import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  final String id;
  final String userId;
  final String event;
  final Map<String, dynamic> data;
  @JsonKey(name: 'readed_at')
  final DateTime? readedAt; // campo "readed_at" na API
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.event,
    required this.data,
    this.readedAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}
