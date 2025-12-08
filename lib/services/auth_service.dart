// lib/services/auth_service.dart
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

  /// login and store token in secure storage
  /// identifier can be email or phone depending on backend
  Future<String> loginAndSaveToken(String identifier, String password) async {
    final res = await api.login(identifier, password);
    // we expect the backend to return access_token or token name
    // try common keys:
    final token = res['access_token'] ?? res['token'] ?? res['accessToken'];
    if (token == null) throw Exception('Token not found in login response');
    final tokenStr = token.toString();
    await storage.setToken(tokenStr);
    return tokenStr;
  }

  /// register expects a flexible Map (so caller can pass arbitrary fields)
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final res = await api.register(body);
    return res;
  }

  /// get current user profile (requires token present in storage)
  Future<Map<String, dynamic>> me() async {
    final res = await api.me();
    return res;
  }

  /// change password
  /// requires token present in storage
  /// Change password by calling backend endpoint.
  /// Assumes backend endpoint: POST {baseUrl}/auth/change-password
  /// Returns true on success, otherwise throws an Exception with a helpful message.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    // 1. إنشاء البيانات لإرسالها إلى الخادم
    final body = {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
    // 2. استدعاء نقطة النهاية لتغيير كلمة المرور
    // يجب أن تكون الدالة api.changePassword موجودة في ApiService
    final res = await api.changePassword(body);
    // 3. تحليل الاستجابة
    // نفترض أن الخادم يعيد حالة نجاح (مثل status code 200) أو رسالة خطأ
    // إذا كان الخادم يعيد true عند النجاح:
    // return res;
    // إذا كان الخادم يعيد Map ونتوقع 'success': true
    return res['success'] == true;
    final token = await storage.getToken();
    if (token == null) throw Exception('Not authenticated.');

    final base = api.baseUrl;
    // نُرسل current_password and new_password في الـ query string لأن السيرفر يطلبهما كـ query
    final qUrl = Uri.parse(
      '$base/auth/change-password'
      '?current_password=${Uri.encodeComponent(currentPassword)}'
      '&new_password=${Uri.encodeComponent(newPassword)}',
    );

    final resp = await http.post(
      qUrl,
      headers: {
        'Authorization': 'Bearer $token',
        // لا حاجة لـ Content-Type لأننا لا نرسل body هنا
      },
    );

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return true;
    }

    // حاول نفك الـ JSON error message لو موجود
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
