import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/doctor.dart';

class DoctorsProvider with ChangeNotifier {
  final ApiService api;
  List<Doctor> _doctors = [];
  bool _loading = false;
  DoctorsProvider(this.api);

  List<Doctor> get doctors => _doctors;
  bool get loading => _loading;

  Future<void> fetchDoctors({int? departmentId, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      final qp = <String, String>{};
      if (departmentId != null) qp['department_id'] = departmentId.toString();
      if (search != null) qp['search'] = search;
      final res = await api.get('/doctors', queryParameters: qp);
      if (res is List) {
        _doctors = res
            .map((e) => Doctor.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
