import 'dart:developer';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LocalUtils {
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static Future<void> setGrade(String grade) async {
    await storage.write(key: 'userGrade', value: grade.toString());
  }

  static Future<void> setLanguage(String lang) async {
    await storage.write(key: 'localLang', value: lang.toString());
  }

  static Future<bool> isLogged() async {
    String? res = await storage.read(key: 'accessToken');
    if (res == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }

  static Future<void> clearStorage() async {
    await storage.deleteAll();
  }

  static Future<void> setAccessToken(String token) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    await storage.write(key: 'userId', value: decodedToken['userId']);
    await storage.write(key: 'accessToken', value: token);
  }

  static Future<void> setRefreshToken(String token) async {
    await storage.write(key: 'refreshToken', value: token);
  }

  static Future<String?> get(String key) async {
    return await storage.read(key: key);
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }
}
