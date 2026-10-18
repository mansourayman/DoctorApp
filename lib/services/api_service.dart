import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  final String baseUrl;
  final StorageService storage;
  final http.Client client;

  ApiService({
    required this.baseUrl,
    required this.storage,
    http.Client? client,
  }) : client = client ?? http.Client();
  //here we prepare header to send with auth ->for some endpoint need that
  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final token = await storage.getToken();
    final h = <String, String>{'Accept': 'application/json'};
    if (withAuth && token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  //make login as store token
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
    final headers = await _headers(withAuth: false);
    headers['Content-Type'] = 'application/json';

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

  Future<List<dynamic>> getDoctors({
    String? q,
    int? departmentId,
    String? category,
    double? minFee,
    double? maxFee,
    double? minRating,
    bool? available,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (departmentId != null) params['department_id'] = departmentId.toString();
    if (minFee != null) params['min_fee'] = minFee.toString();
    if (maxFee != null) params['max_fee'] = maxFee.toString();
    if (minRating != null) params['min_rating'] = minRating.toString();
    if (available != null) params['available'] = available ? 'true' : 'false';
    params['page'] = page.toString();
    params['per_page'] = perPage.toString();

    final uri = Uri.parse('$baseUrl/doctors').replace(queryParameters: params);
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getDoctors failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getTopRatedDoctors({int limit = 10}) async {
    final uri = Uri.parse(
      '$baseUrl/doctors/top-rated',
    ).replace(queryParameters: {'limit': limit.toString()});

    final res = await client.get(uri, headers: await _headers(withAuth: false));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getTopRatedDoctors failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> getDoctorById(int id) async {
    final uri = Uri.parse('$baseUrl/doctors/$id');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('getDoctorById failed: ${res.statusCode} ${res.body}');
  }

  Future<List<Map<String, dynamic>>> getDoctorSchedule(int doctorId) async {
    final uri = Uri.parse('$baseUrl/doctors/$doctorId/schedule');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception('getDoctorSchedule failed: ${res.statusCode} ${res.body}');
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

    throw Exception(
      'createAppointment failed: ${res.statusCode} ${res.body} | sent=$body',
    );
  }

  Future<List<dynamic>> getMyAppointments() async {
    final uri = Uri.parse('$baseUrl/appointments/my-appointments');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getMyAppointments failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> getAppointmentDetails(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/appointments/$id');
      final res = await client.get(uri, headers: await _headers());

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }

      if (res.statusCode != 404) {
        throw Exception(
          'getAppointmentDetails failed: ${res.statusCode} ${res.body}',
        );
      }
    } catch (_) {}

    final list = await getMyAppointments();
    final items = List<Map<String, dynamic>>.from(list);

    final match = items.where((e) {
      final x = e['id'];
      final aid = (x is int) ? x : int.tryParse('$x');
      return aid == id;
    }).toList();

    if (match.isEmpty) {
      throw Exception('Appointment not found in my-appointments');
    }

    return match.first;
  }

  Future<void> cancelAppointment(dynamic id) async {
    final uri = Uri.parse('$baseUrl/appointments/$id/cancel');

    final res = await client.delete(uri, headers: await _headers());

    if (res.statusCode == 200 || res.statusCode == 204) return;

    throw Exception('cancelAppointment failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/reviews/');

    final res = await client.post(
      uri,
      headers: await _headers()
        ..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception('createReview failed: ${res.statusCode} ${res.body}');
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

  Future<List<Map<String, dynamic>>> getDepartmentsCategories() async {
    final uri = Uri.parse('$baseUrl/departments/categories');

    final res = await client.get(uri, headers: await _headers(withAuth: false));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      throw Exception('Invalid departments/categories response: ${res.body}');
    }

    throw Exception(
      'getDepartmentsCategories failed: ${res.statusCode} ${res.body}',
    );
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
    final uri = Uri.parse('$baseUrl/notifications');
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
    request.headers.addAll(await _headers());

    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'upload.jpg';

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath, filename: filename),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);

      if (body is Map<String, dynamic>) {
        if (body.containsKey('url')) return body['url'] as String;
        if (body.containsKey('file_url')) return body['file_url'] as String;
        if (body.containsKey('data') &&
            body['data'] is Map &&
            body['data']['url'] != null) {
          return body['data']['url'] as String;
        }
      }
      if (res.body.isNotEmpty) return res.body;
      throw Exception('uploadImage: unexpected response: ${res.body}');
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
      if (body.containsKey('secure_url')) return body['secure_url'] as String;
      if (body.containsKey('url')) return body['url'] as String;
      throw Exception(
        'uploadImageToCloudinary: unexpected response: ${res.body}',
      );
    } else {
      throw Exception(
        'uploadImageToCloudinary failed: ${res.statusCode} ${res.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final dateStr = '$yyyy-$mm-$dd';

    final uri = Uri.parse(
      '$baseUrl/doctors/$doctorId/available-slots',
    ).replace(queryParameters: {'date_': dateStr});

    final res = await client.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception('getAvailableSlots failed: ${res.statusCode} ${res.body}');
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

  Future<Map<String, dynamic>?> updateProfileAndGetUser(
    Map<String, dynamic> fields,
  ) async {
    final uri = Uri.parse('$baseUrl/users/me');
    final headers = await _headers()
      ..addAll({'Content-Type': 'application/json'});

    final res = await client.put(
      uri,
      headers: headers,
      body: jsonEncode(fields),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['detail'] != null) {
        throw Exception(body['detail'].toString());
      }
    } catch (_) {}

    throw Exception(
      'updateProfileAndGetUser failed: ${res.statusCode} ${res.body}',
    );
  }

  Future<Map<String, dynamic>> requestOtp({
    required String email,
    String purpose = 'register',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/request-otp');
    final payload = {'email': email, 'purpose': purpose};

    final res = await client.post(
      uri,
      headers: await _headers(withAuth: false)
        ..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return {'message': res.body};
      }
    }

    throw Exception('requestOtp failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
    String purpose = 'register',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/verify-otp');
    final payload = {'email': email, 'purpose': purpose, 'code': code};

    final res = await client.post(
      uri,
      headers: await _headers(withAuth: false)
        ..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        return {'message': res.body};
      }
    }

    throw Exception('verifyOtp failed: ${res.statusCode} ${res.body}');
  }

  void dispose() {
    client.close();
  }
}
