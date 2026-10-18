import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static SharedPreferences? _prefs;
  static String baseUrl =
      'http://10.0.2.2:8000'; // Adjust for emulator or your server

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get token => _prefs?.getString('token');
  static set token(String? v) {
    if (v == null)
      _prefs?.remove('token');
    else
      _prefs?.setString('token', v);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
