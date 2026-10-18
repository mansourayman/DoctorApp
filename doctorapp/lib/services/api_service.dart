import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/session.dart';

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  Map<String, String> _headers() {
    final token = Session.token;
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer \$token';
    return headers;
  }

  Future<Map<String, dynamic>> post(String path, Map body) async {
    final res = await http.post(
      Uri.parse('\$baseUrl\$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _process(res);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(
      Uri.parse('\$baseUrl\$path'),
      headers: _headers(),
    );
    return _process(res);
  }

  Future<Map<String, dynamic>> _process(http.Response res) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('API error: \${res.statusCode} - \${res.body}');
  }
}
