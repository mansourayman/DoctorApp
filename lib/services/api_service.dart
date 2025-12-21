import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String _defaultBaseUrl = "http://10.0.2.2:8000";

  final String baseUrl;
  final StorageService storage;
  final http.Client client;

  ApiService({
    String? baseUrl,
    required this.storage,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl,
        client = client ?? http.Client();

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final token = await storage.getToken();
    final h = <String, String>{
      'Accept': 'application/json',
    };
    if (withAuth && token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final uri = Uri.parse('$baseUrl/auth/token');
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };

    final body =
        'username=${Uri.encodeComponent(identifier)}&password=${Uri.encodeComponent(password)}';

    final res = await client.post(uri, headers: headers, body: body);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final res = await client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Register failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> me() async {
    final uri = Uri.parse('$baseUrl/users/me');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('me() failed: ${res.statusCode} ${res.body}');
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    final uri = Uri.parse('$baseUrl/users/me');
    final headers = await _headers()
      ..addAll({'Content-Type': 'application/json'});

    final res = await client.put(
      uri,
      headers: headers,
      body: jsonEncode(fields),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    }

    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['detail'] != null) {
        throw Exception(body['detail'].toString());
      }
    } catch (_) {}

    throw Exception('updateProfile failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getDoctors([Map<String, dynamic>? filters]) async {
    try {
      String query = '';
      if (filters != null && filters.isNotEmpty) {
        final params = <String>[];
        filters.forEach((k, v) {
          if (v is List) {
            for (var val in v) {
              params.add('$k=$val');
            }
          } else if (v != null) {
            params.add('$k=$v');
          }
        });
        if (params.isNotEmpty) {
          query = '?${params.join('&')}';
        }
      }

      final uri = Uri.parse('$baseUrl/doctors$query');
      final res = await client.get(uri, headers: await _headers());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) return data;
        if (data is Map && data.containsKey('data')) return data['data'];
        return [];
      }
      throw Exception('getDoctors failed: ${res.statusCode} ${res.body}');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getDoctorById(int id) async {
    final uri = Uri.parse('$baseUrl/doctors/$id');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('getDoctorById failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> body,
      ) async {
    final uri = Uri.parse('$baseUrl/appointments/');

    final res = await client.post(
      uri,
      headers: await _headers()
        ..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception('createAppointment failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getMyAppointments() async {
    final uri = Uri.parse('$baseUrl/appointments/my-appointments');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getMyAppointments failed: ${res.statusCode} ${res.body}');
  }

  Future<void> cancelAppointment(dynamic id) async {
    final uri = Uri.parse('$baseUrl/appointments/$id/cancel');
    final res = await client.delete(uri, headers: await _headers());
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('cancelAppointment failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getDepartments() async {
    final uri = Uri.parse('$baseUrl/departments');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getDepartments failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getCategories() async {
    final uri = Uri.parse('$baseUrl/departments');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getCategories failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getNotifications() async {
    final uri = Uri.parse('$baseUrl/notifications/my-notifications');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('getNotifications failed: ${res.statusCode} ${res.body}');
  }

  Future<void> markNotificationRead(dynamic id) async {
    final uri = Uri.parse('$baseUrl/notifications/$id/read');
    final res = await client.patch(uri, headers: await _headers());
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception(
      'markNotificationRead failed: ${res.statusCode} ${res.body}',
    );
  }

  Future<void> sendNotification({
    String? title,
    String? body,
    int? userId,
    String? role,
  }) async {
    final uri = Uri.parse('$baseUrl/notifications/send');
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (body != null) payload['body'] = body;
    if (userId != null) payload['user_id'] = userId;
    if (role != null) payload['role'] = role;

    final res = await client.post(
      uri,
      headers: await _headers()
        ..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode(payload),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return;
    throw Exception('sendNotification failed: ${res.statusCode} ${res.body}');
  }

  Future<String> uploadImage(String filePath) async {
    final uri = Uri.parse('$baseUrl/uploads');
    final file = File(filePath);
    if (!await file.exists()) throw Exception('File not found: $filePath');

    final request = http.MultipartRequest('POST', uri);
    final headers = await _headers();
    request.headers.addAll(headers);

    final filename = file.uri.pathSegments.last;
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath, filename: filename),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        if (body.containsKey('url')) return body['url'] as String;
      }
      return res.body;
    } else {
      throw Exception('uploadImage failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<String> uploadImageToCloudinary(
      String filePath, {
        required String cloudName,
        required String uploadPreset,
      }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final file = File(filePath);
    if (!await file.exists()) throw Exception('File not found: $filePath');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;

    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'upload.jpg';

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath, filename: filename),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body.containsKey('secure_url')) {
        return body['secure_url'] as String;
      }
      if (body.containsKey('url')) {
        return body['url'] as String;
      }
      throw Exception(
        'uploadImageToCloudinary: unexpected response: ${res.body}',
      );
    } else {
      throw Exception(
        'uploadImageToCloudinary failed: ${res.statusCode} ${res.body}',
      );
    }
  }

  void dispose() {
    client.close();
  }
}