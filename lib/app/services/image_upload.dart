// ============================================
// FILE: lib/services/image_upload_service.dart
// ============================================
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:kff_owner_admin/app/utils/local_utils.dart';
import 'package:kff_owner_admin/constants/app_constants.dart';

class ImageUploadService {
  /// Загружает фото на сервер и возвращает список URLs
  static Future<List<String>> uploadImages(List<Uint8List> images) async {
    try {
      // Конвертируем в base64
      List<Map<String, String>> base64Images = [];

      for (int i = 0; i < images.length; i++) {
        final base64 = base64Encode(images[i]);
        base64Images.add({
          'base64': 'data:image/jpeg;base64,$base64',
          'fileName':
              'arena_photo_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        });
      }

      // Отправляем на сервер
      String token = await LocalUtils.getAccessToken() ?? '';

      final response = await http.post(
        Uri.parse('${AppConstant.baseUrl}api/upload-images'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'images': base64Images}),
      );
      log(response.body.toString());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Извлекаем URLs из ответа
          List<String> urls = [];
          for (var file in data['files']) {
            urls.add(file['url']);
          }
          return urls;
        } else {
          throw Exception('Upload failed: ${data['error']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Загружает одно фото
  static Future<String> uploadSingleImage(Uint8List image) async {
    final urls = await uploadImages([image]);
    return urls.first;
  }
}
