import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import "../services/api_service.dart";

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
  Future<void> _setLoading(bool v) async {
    loading = v;
    notifyListeners();
  }

  Future<void> _tryRestore() async {
    await _setLoading(true);
    try {
      final me = await authService.me();
      user = me;
    } 
    catch (_) {
      user = null;
    }
    finally {
      loading = false;
      notifyListeners();
      await _setLoading(false);
    }
  }

  Future<void> login(String identifier, String password) async {
    loading = true;
    notifyListeners();
    await _setLoading(true);
    try {
      await authService.loginAndSaveToken(identifier, password);
      final me = await authService.me();
      user = me;
    } 
    finally {
      loading = false;
      notifyListeners();
      notifyListeners();
    }
    finally {
      await _setLoading(false);
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
    await _setLoading(true);
    try {
      await authService.register({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      });
      await login(email, password);
    } 
    finally {
      loading = false;
      notifyListeners();
      await login(email, password);
    }
    finally {
      await _setLoading(false);
    }
  }

  Future<void> logout() async {
    loading = true;
    notifyListeners();
    await authService.logout();
    user = null;
    loading = false;
    notifyListeners();

    await _setLoading(true);
    try {
      await authService.logout();
      user = null;
      notifyListeners();
    } 
    finally {
      await _setLoading(false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    await _setLoading(true);
    try {
      final dynamic api = authService.api;
      if (api == null) {
        throw Exception('API client is not available from AuthService.');
      }
      try {
        final result = await api.updateProfile(fields);
        if (result is bool && !result) {
          throw Exception('Server rejected profile update.');
        }
      } on NoSuchMethodError catch (_) {
        throw Exception(
          'Api client does not implement updateProfile(fields). Add updateProfile to ApiService.',
        );
      }
      final me = await authService.me();
      user = me;
      notifyListeners();
    }
     catch (e) {
      rethrow;
    } 
    finally {
      await _setLoading(false);
    }
  }

  Future<void> uploadAvatarAndUpdate(
    String filePath, {
    String? cloudinaryName,
    String? uploadPreset,
  }) async {
    await _setLoading(true);
    try {
      final dynamic api = authService.api;

      if (api == null) {
        throw Exception('API client is not available from AuthService.');
      }

      if (kIsWeb) {
        throw UnsupportedError(
          'Uploading local files is not supported on web. Provide a remote URL or implement web upload.',
        );
      }

      if (filePath.trim().isEmpty) {
        throw ArgumentError('filePath must not be empty.');
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found at provided path: $filePath');
      }

      String uploadedUrl;

      try {
        if (cloudinaryName != null && uploadPreset != null) {
          uploadedUrl = await api.uploadImageToCloudinary(
            filePath,
            cloudName: cloudinaryName,
            uploadPreset: uploadPreset,
          );
        } else {
          uploadedUrl = await api.uploadImage(filePath);
        }
      } 
      on NoSuchMethodError catch (_) {
        throw Exception(
          'Api client does not implement expected upload methods (uploadImage or uploadImageToCloudinary).',
        );
      }

      if (uploadedUrl == null || uploadedUrl.trim().isEmpty) {
        throw Exception('Upload did not return a valid URL.');
      }

      await updateProfile({'avatar_url': uploadedUrl});
    }
     catch (e) {
      rethrow;
    } 
    finally {
      await _setLoading(false);
    }
  }
 }
}