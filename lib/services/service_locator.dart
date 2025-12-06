import 'api_service.dart';
import 'storage_service.dart';

class ServiceLocator {
  static StorageService? storage;
  static ApiService? api;

  /// Call this once at app startup (inside main)
  static Future<void> init() async {
    storage = await StorageService.getInstance();
    api = ApiService(baseUrl: "http://10.0.2.2:8000", storage: storage!);
  }
}
