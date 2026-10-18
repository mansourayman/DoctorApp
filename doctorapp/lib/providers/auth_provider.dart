import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService api;
  bool _loading = false;
  bool get loading => _loading;

  AuthProvider(this.api);

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final token = res['access_token'];
      if (token != null) {
        await api.saveToken(token);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await api.removeToken();
    notifyListeners();
  }
}
