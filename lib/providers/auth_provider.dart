import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  Map<String, dynamic>? user;
  bool loading = false;

  AuthProvider({required this.authService}) {
    _tryRestore();
  }

  bool get isAuthenticated => user != null;

  Future<void> _tryRestore() async {
    loading = true;
    notifyListeners();
    try {
      final me = await authService.me();
      user = me;
    } catch (_) {
      user = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String identifier, String password) async {
    loading = true;
    notifyListeners();
    try {
      await authService.loginAndSaveToken(identifier, password);
      final me = await authService.me();
      user = me;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    loading = true;
    notifyListeners();
    try {
      await authService.register({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      });
      await login(email, password);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    loading = true;
    notifyListeners();
    await authService.logout();
    user = null;
    loading = false;
    notifyListeners();
  }
}
