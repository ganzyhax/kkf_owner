import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kff_owner_admin/app/utils/local_utils.dart';
import 'package:kff_owner_admin/constants/app_constants.dart';
import 'dart:convert';

class ApiClient {
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    Future<http.Response> makeGetRequest() async {
      
      String token = await LocalUtils.getAccessToken() ?? '';
      log('Making GET request to $url with token: $token');
      return await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }

    http.Response response = await makeGetRequest();

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
        'status': response.statusCode.toString(),
      };
    }

    if (response.statusCode == 401) {
      await _refreshToken(response);
      response = await makeGetRequest();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'status': response.statusCode.toString(),
        };
      } else {
        return {
          'success': false,
          'data': jsonDecode(response.body),
          'status': response.statusCode.toString(),
        };
      }
    }

    return {
      'success': false,
      'data': jsonDecode(response.body),
      'status': response.statusCode.toString(),
    };
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    Future<http.Response> makePostRequest() async {
      String token = await LocalUtils.getAccessToken() ?? '';

      return await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'appVersion': 'null',
          'appPlatform': 'web',
        },
        body: jsonEncode(data),
      );
    }

    http.Response response = await makePostRequest();

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    if (response.statusCode == 401) {
      await _refreshToken(response);
      response = await makePostRequest();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    }
    log(response.body.toString());
    return {'success': false, 'data': jsonDecode(response.body)};
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    Future<http.Response> makePostRequest() async {
      String token = await LocalUtils.getAccessToken() ?? '';

      return await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          // 'Mobapp-Version': mbVer
        },
        body: jsonEncode(data),
      );
    }

    http.Response response = await makePostRequest();

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    if (response.statusCode == 401) {
      await _refreshToken(response);
      response = await makePostRequest();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    }
    return {'success': false, 'data': jsonDecode(response.body)};
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    Future<http.Response> makePostRequest() async {
      String token = await LocalUtils.getAccessToken() ?? '';

      return await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          // 'Mobapp-Version': mbVer
        },
        body: jsonEncode(data),
      );
    }

    http.Response response = await makePostRequest();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }
    if (response.statusCode == 401) {
      await _refreshToken(response);
      response = await makePostRequest();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    }
    return {'success': false, 'data': jsonDecode(response.body)};
  }

  static Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);

    Future<http.Response> makeDeleteRequest() async {
      String token = await LocalUtils.getAccessToken() ?? '';

      return await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'appVersion': 'null',
          'appPlatform': 'web',
        },
        body: data != null ? jsonEncode(data) : null,
      );
    }

    http.Response response = await makeDeleteRequest();

    if (response.statusCode == 200 || response.statusCode == 204) {
      return {
        'success': true,
        'data': response.body.isNotEmpty ? jsonDecode(response.body) : null,
      };
    }
    if (response.statusCode == 401) {
      await _refreshToken(response);
      response = await makeDeleteRequest();
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'data': response.body.isNotEmpty ? jsonDecode(response.body) : null,
        };
      } else {
        return {'success': false, 'data': jsonDecode(response.body)};
      }
    }

    log(response.body.toString());
    return {'success': false, 'data': jsonDecode(response.body)};
  }

  static Future<dynamic> postUnAuth(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // String mbVer = await AuthUtils.getIndexMobileVersion();
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Mobapp-Version': mbVer
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      log(response.body.toString());
      return {'success': false, 'data': jsonDecode(response.body)};
    }
  }

  static Future<dynamic> getUnAuth(String endpoint) async {
    final url = Uri.parse(AppConstant.baseUrl.toString() + endpoint);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Mobapp-Version': mbVer
      },
    );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false, 'data': jsonDecode(response.body)};
    }
  }

  static Future<void> _refreshToken(http.Response response) async {
    final refreshToken = await LocalUtils.getRefreshToken();
    final url = Uri.parse(AppConstant.baseUrl + 'api/auth/refreshAccessToken');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await LocalUtils.setAccessToken(data['accessToken']);
    } else {
      print('Failed to refresh token');
    }
  }
}
