import 'dart:io';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  Map<String, dynamic>? user;
  bool loading = false;

  AuthProvider({required this.authService}) {
    _tryRestore();
  }

  bool get isAuthenticated => user != null;

  Future<void> _setLoading(bool v) async {
    loading = v;
    notifyListeners();
  }

  Future<void> _tryRestore() async {
    await _setLoading(true);
    try {
      user = await authService.me();
    } catch (_) {
      user = null;
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> startRegisterRequestOtp({required String email}) async {
    await _setLoading(true);
    try {
      await authService.api.requestOtp(email: email, purpose: 'register');
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> confirmRegisterOtp({
    required String email,
    required String code,
    required String fullName,
    required String phone,
    required String password,
    String? avatarPath,
  }) async {
    await _setLoading(true);
    try {
      await authService.api.verifyOtp(
        email: email,
        code: code,
        purpose: 'register',
      );

      await authService.register({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      });

      await authService.loginAndSaveToken(email, password);
      user = await authService.me();
      notifyListeners();

      if (!kIsWeb && avatarPath != null && avatarPath.trim().isNotEmpty) {
        final f = File(avatarPath);
        if (f.existsSync()) {
          await uploadAvatarAndUpdate(avatarPath);
        }
      }
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> login(String identifier, String password) async {
    await _setLoading(true);
    try {
      await authService.loginAndSaveToken(identifier, password);
      user = await authService.me();
      notifyListeners();
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    throw Exception(
      'Direct register is disabled. Use OTP flow: startRegisterRequestOtp() then confirmRegisterOtp().',
    );
  }

  Future<void> logout() async {
    await _setLoading(true);
    try {
      await authService.logout();
      user = null;
      notifyListeners();
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    await _setLoading(true);
    try {
      final api = authService.api;
      final result = await api.updateProfile(fields);

      if (result is bool && !result) {
        throw Exception('Server rejected profile update.');
      }

      user = await authService.me();
      notifyListeners();
    } finally {
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
      if (kIsWeb) {
        throw UnsupportedError(
          'Uploading local files is not supported on web.',
        );
      }

      if (filePath.trim().isEmpty) {
        throw ArgumentError('filePath must not be empty.');
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found at provided path: $filePath');
      }

      final api = authService.api;

      String uploadedUrl;
      if (cloudinaryName != null && uploadPreset != null) {
        uploadedUrl = await api.uploadImageToCloudinary(
          filePath,
          cloudName: cloudinaryName,
          uploadPreset: uploadPreset,
        );
      } else {
        uploadedUrl = await api.uploadImage(filePath);
      }

      if (uploadedUrl.trim().isEmpty) {
        throw Exception('Upload did not return a valid URL.');
      }

      await updateProfile({'avatar_url': uploadedUrl});
    } finally {
      await _setLoading(false);
    }
  }
}
