import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

/// Upload direto para o Cloudinary — a API nunca recebe a imagem,
/// apenas a URL resultante via PATCH /users/me.
///
/// Configuração necessária no dashboard do Cloudinary:
/// Settings → Upload → Upload presets → Add preset
///   - Signing mode: Unsigned
///   - Folder: repfinder/avatars
///   - Incoming transformation: c_fill,w_400,h_400,f_webp,q_auto
class CloudinaryUploader {
  static String get _cloudName => dotenv.get('CLOUDINARY_CLOUD_NAME');
  static String get _uploadPreset => dotenv.get('CLOUDINARY_UPLOAD_PRESET');

  /// Faz upload de uma imagem e retorna a URL segura (https) do Cloudinary.
  static Future<String> uploadAvatar(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();

    final response = await Dio().post(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      data: {
        'file': 'data:image/$ext;base64,$base64Image',
        'upload_preset': _uploadPreset,
        'folder': 'repfinder/avatars',
      },
    );

    return response.data['secure_url'] as String;
  }
}
