import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/core/http.dart';
import 'package:client/models/user.dart';

part 'auth_datasource.g.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

@riverpod
AuthDatasource authDatasource(AuthDatasourceRef ref) {
  return AuthDatasource(ref.read(dioProvider));
}

class AuthDatasource {
  final Dio _dio;

  AuthDatasource(this._dio);

  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _dio.post(
      '/users/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'student',
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/users/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<User> getMe() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data);
  }

  Future<User> updateMe({
    String? name,
    String? email,
    String? password,
    String? avatarUrl,
    String? bio,
    String? gender,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (bio != null) data['bio'] = bio;
    if (gender != null) data['gender'] = gender;

    final response = await _dio.patch('/users/me', data: data);
    return User.fromJson(response.data);
  }
}
