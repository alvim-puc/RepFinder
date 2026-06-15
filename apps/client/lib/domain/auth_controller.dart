import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/core/cloudinary.dart';
import 'package:client/core/storage.dart';
import 'package:client/datasources/auth_datasource.dart';
import 'package:client/models/user.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<User?> build() async {
    return await SecureStorage.getUser();
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

  Future<void> updateMe({
    String? name,
    String? email,
    String? password,
    String? bio,
    String? gender,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedUser = await ref
          .read(authDatasourceProvider)
          .updateMe(
            name: name,
            email: email,
            password: password,
            bio: bio,
            gender: gender,
          );
      await SecureStorage.saveUser(updatedUser);
      return updatedUser;
    });
  }

  /// Faz upload da foto para o Cloudinary e atualiza o avatarUrl no backend.
  Future<void> updateAvatar(XFile imageFile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final url = await CloudinaryUploader.uploadAvatar(imageFile);

      final updatedUser = await ref
          .read(authDatasourceProvider)
          .updateMe(avatarUrl: url);

      await SecureStorage.saveUser(updatedUser);
      return updatedUser;
    });
  }
}
