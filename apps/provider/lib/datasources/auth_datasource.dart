import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/core/http.dart';
import 'package:provider/models/user.dart';

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
        'role': 'representative',
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

  Future<User> updateMe({String? name, String? email, String? password}) async {
    final response = await _dio.patch(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
      },
    );
    return User.fromJson(response.data);
  }
}
