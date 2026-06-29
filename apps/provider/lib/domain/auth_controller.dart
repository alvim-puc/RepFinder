import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:provider/core/storage.dart';
import 'package:provider/datasources/auth_datasource.dart';
import 'package:provider/models/user.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async {
    try {
      return await SecureStorage.getUser();
    } catch (_) {
      // storage falhou ou vazio — trata como não autenticado
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authResponse = await ref
          .read(authDatasourceProvider)
          .login(email, password);
      await SecureStorage.saveToken(authResponse.token);
      await SecureStorage.saveUser(authResponse.user);
      return authResponse.user;
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authResponse = await ref
          .read(authDatasourceProvider)
          .register(name, email, password);
      await SecureStorage.saveToken(authResponse.token);
      await SecureStorage.saveUser(authResponse.user);
      return authResponse.user;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await SecureStorage.clear();
    state = const AsyncValue.data(null);
  }

  Future<void> updateMe({String? name, String? email, String? password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedUser = await ref
          .read(authDatasourceProvider)
          .updateMe(name: name, email: email, password: password);
      await SecureStorage.saveUser(updatedUser);
      return updatedUser;
    });
  }
}
