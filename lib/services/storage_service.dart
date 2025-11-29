// import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static StorageService? _instance;
  final FlutterSecureStorage _secureStorage;

  StorageService._(this._secureStorage);

  /// call StorageService.getInstance() where needed
  static Future<StorageService> getInstance() async {
    if (_instance != null) return _instance!;
    // no async init needed for flutter_secure_storage, but keep signature
    final storage = const FlutterSecureStorage();
    _instance = StorageService._(storage);
    return _instance!;
  }

  // token helpers
  static const _keyToken = 'app_token';

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // generic helpers
  Future<void> setItem(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getItem(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeItem(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
