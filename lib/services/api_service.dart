// lib/services/api_service.dart
import 'dart:convert';
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

  /// Build headers. Use withAuth: false for endpoints like login/register.
  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final token = await storage.getToken();
    final h = <String, String>{
      'Accept': 'application/json',
      // 'Content-Type' set per-request because login uses form encoding
    };
    if (withAuth && token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ---------------- Auth ----------------

  /// Login (the backend expects OAuth2 form -> application/x-www-form-urlencoded)
  /// identifier: can be email or phone (backend accepts both via username)
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final uri = Uri.parse('$baseUrl/auth/token');
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };

    // OAuth2PasswordRequestForm expects fields: username, password, scope, grant_type, client_id, client_secret
    // We only need username & password for this simple flow.
    final body =
        'username=${Uri.encodeComponent(identifier)}&password=${Uri.encodeComponent(password)}';

    final res = await client.post(uri, headers: headers, body: body);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    // return server message to help debugging
    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }

  /// Register with flexible body as Map (JSON) - matches UserCreate pydantic model
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

  /// Get current user profile (note: backend exposes GET /users/me)
  Future<Map<String, dynamic>> me() async {
    final uri = Uri.parse('$baseUrl/users/me'); // <-- fixed path
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('me() failed: ${res.statusCode} ${res.body}');
  }

  /// تغيير كلمة المرور (تتطلب كلمة المرور الحالية والجديدة في الجسم Body)
  /// نفترض أن نقطة النهاية هي /users/password وتستخدم PATCH
  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/users/password');

    final res = await client.patch(
      // يفضل استخدام PATCH لتحديث جزئي
      uri,
      headers: await _headers()
        ..addAll({'Content-Type': 'application/json'}), // تتطلب Auth و JSON
      body: jsonEncode(body), // يحتوي على 'current_password' و 'new_password'
    );

    if (res.statusCode == 200) {
      // قد يعيد الخادم رسالة نجاح أو حالة المستخدم المحدثة
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    // رمي استثناء إذا كان هناك خطأ (مثل كلمة المرور الحالية غير صحيحة)
    throw Exception('Change password failed: ${res.statusCode} ${res.body}');
  }

  // ---------------- Doctors (filters & pagination) ----------------

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

  // ---------------- Appointments ----------------

  Future<Map<String, dynamic>> createAppointment(
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl/appointments');
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
    final res = await client.post(uri, headers: await _headers());
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('cancelAppointment failed: ${res.statusCode} ${res.body}');
  }
  // ... (دوال createAppointment, getMyAppointments, cancelAppointment موجودة هنا)

  /// تحديث بيانات موعد موجود (تعديل)
  /// id: معرف الموعد، body: البيانات الجديدة للتعديل
  Future<Map<String, dynamic>> updateAppointment(
    dynamic id,
    Map<String, dynamic>
    body, // يحتوي على البيانات الجديدة (مثل التاريخ والوقت)
  ) async {
    final uri = Uri.parse('$baseUrl/appointments/$id');

    // يفضل استخدام PATCH للتحديث الجزئي للبيانات
    final res = await client.patch(
      uri,
      headers: await _headers()
        ..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // رمي استثناء في حالة الفشل (مثلاً: المدخلات غير صحيحة)
    throw Exception('Update appointment failed: ${res.statusCode} ${res.body}');
  }

  Future<bool> checkEditPermission(dynamic id) async {
    // نفترض أن مسار الـ API هو /appointments/{id}/can-edit (يستخدم GET للفحص)
    final uri = Uri.parse('$baseUrl/appointments/$id/can-edit');

    final res = await client.get(uri, headers: await _headers());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // نفترض أن الخادم يعيد { "allowed": true/false }
      return data['allowed'] == true;
    }
    // في حالة خطأ في الاتصال، نعتبره غير مسموح به احتياطًا
    return false;
  }

  /// تأكيد أو تغيير حالة الموعد إلى (Verified)
  Future<void> verifyAppointment(dynamic id) async {
    // نفترض أن مسار الـ API هو /appointments/{id}/verify (يستخدم POST أو PATCH)
    final uri = Uri.parse('$baseUrl/appointments/$id/verify');

    // استخدام POST لتنفيذ عملية تغيير حالة
    final res = await client.post(uri, headers: await _headers());

    // 200 أو 204 (نجاح بدون محتوى) يعني أن العملية تمت
    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    }
    throw Exception('Verify appointment failed: ${res.statusCode} ${res.body}');
  }

  // ---------------- Departments & Categories ----------------

  Future<List<dynamic>> getDepartments() async {
    final uri = Uri.parse('$baseUrl/departments');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getDepartments failed: ${res.statusCode} ${res.body}');
  }

  Future<List<dynamic>> getCategories() async {
    // backend doesn't have a dedicated /departments/categories in your code;
    // you can use /departments and map them to categories if needed.
    final uri = Uri.parse('$baseUrl/departments');
    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('getCategories failed: ${res.statusCode} ${res.body}');
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

  // ---------------- Notifications ----------------

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

  void dispose() {
    client.close();
  }
}
