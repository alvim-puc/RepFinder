import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String role; // sempre "student" neste app

  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;

  final String? bio;

  final String? gender; // 'female' | 'male' | 'non_binary' | 'other'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
