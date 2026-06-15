import 'package:json_annotation/json_annotation.dart';

part 'application.g.dart';

@JsonSerializable()
class Application {
  final String id;
  final String userId;
  final String vacancyId;
  final String status; // "pending" | "accepted" | "rejected"
  final DateTime createdAt;

  Application({
    required this.id,
    required this.userId,
    required this.vacancyId,
    required this.status,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}
