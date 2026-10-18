import 'dart:convert';
import 'package:http/http.dart' as http;

import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api;
  final StorageService storage;

  AuthService({required this.api, required this.storage});

  Future<void> logout() async {
    await storage.removeToken();
  }

  Future<String> loginAndSaveToken(String identifier, String password) async {
    final res = await api.login(identifier, password);

    final token = res['access_token'] ?? res['token'] ?? res['accessToken'];
    if (token == null) throw Exception('Token not found in login response');
    final tokenStr = token.toString();
    await storage.setToken(tokenStr);
    return tokenStr;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final res = await api.register(body);
    return res;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await api.me();
    return res;
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await storage.getToken();
    if (token == null) throw Exception('Not authenticated.');

    final base = api.baseUrl;

    final qUrl = Uri.parse(
      '$base/auth/change-password'
      '?current_password=${Uri.encodeComponent(currentPassword)}'
      '&new_password=${Uri.encodeComponent(newPassword)}',
    );

    final resp = await http.post(
      qUrl,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return true;
    }

    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body['detail'] != null) {
        throw Exception(body['detail'].toString());
      }
    } catch (_) {}

    throw Exception(
      'Failed to change password: ${resp.statusCode} ${resp.body}',
    );
  }
}
