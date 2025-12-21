import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'doctor_detail_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  bool _loading = true;
  List<dynamic> _doctors = [];
  String _query = '';
  String? _category;
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['category'] != null) {
        _category = args['category'] as String;
        _activeFilters['category'] = _category;
      }
      _fetch();
    });
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      final filtersToSend = Map<String, dynamic>.from(_activeFilters);

      // ضمان أن التخصص موجود ضمن الفلاتر لو مفيش أقسام مختارة
      if (_category != null && !filtersToSend.containsKey('department_ids') && !filtersToSend.containsKey('category')) {
        filtersToSend['category'] = _category;
      }

      final data = await api.getDoctors(filtersToSend);

      if (mounted) setState(() => _doctors = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load doctors: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _doctors.where((d) {
      final name = (d['user']?['full_name'] ?? d['full_name'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_query.toLowerCase());

      bool matchesCategory = true;
      if (_category != null && _category!.isNotEmpty) {
        final deptName = d['department']?['name']?.toString();
        if (deptName != null && deptName.isNotEmpty) {
          matchesCategory = deptName == _category;
        } else {
          final spec = (d['specialization'] ?? d['category'] ?? '').toString().toLowerCase();
          final target = _category!.toLowerCase();
          matchesCategory = spec.contains(target) || target.contains(spec);
        }
      }

      bool matchesFee = true;
      if (_activeFilters.containsKey('min_fee') && _activeFilters.containsKey('max_fee')) {
        final minVal = (_activeFilters['min_fee'] as num).toDouble();
        final maxVal = (_activeFilters['max_fee'] as num).toDouble();

        final docFee = d['consultation_fee'] ?? 0;
        final feeVal = (docFee is num) ? docFee.toDouble() : double.tryParse(docFee.toString()) ?? 0.0;

        if (feeVal < minVal || feeVal > maxVal) {
          matchesFee = false;
        }
      }

      bool matchesRating = true;
      if (_activeFilters.containsKey('min_rating')) {
        final minRate = (_activeFilters['min_rating'] as num).toDouble();
        final docRate = d['average_rating'] ?? d['rating'] ?? 0;
        final rateVal = (docRate is num) ? docRate.toDouble() : double.tryParse(docRate.toString()) ?? 0.0;
        if (rateVal < minRate) matchesRating = false;
      }

      return matchesSearch && matchesCategory && matchesFee && matchesRating;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Text(
          _category == null ? 'All Doctors' : _category!,
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search doctor...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(context, '/filters');

                              if (result != null && result is Map<String, dynamic>) {
                                setState(() {
                                  if (result.isEmpty) {
                                    // لو رجعنا من الـ Reset (فاضي)
                                    _activeFilters = {};
                                    // نرجع القسم الأساسي عشان الصفحة متفضاش
                                    if (_category != null) {
                                      _activeFilters['category'] = _category;
                                    }
                                  } else {
                                    // لو فيه فلاتر جديدة
                                    if (result.containsKey('department_ids')) {
                                      _category = null;
                                      _activeFilters = result;
                                    } else {
                                      _activeFilters = result;
                                      if (_category != null) {
                                        _activeFilters['category'] = _category;
                                      }
                                    }
                                  }
                                });
                                _fetch();
                              }
                            },
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_activeFilters.isNotEmpty && (_category == null || _activeFilters.length > 1))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Row(
                children: [
                  Text(
                      'Filters active',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeFilters = {};
                        if (_category != null) {
                          _activeFilters['category'] = _category;
                        }
                      });
                      _fetch();
                    },
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  )
                ],
              ),
            ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    _category != null
                        ? 'No doctors found in $_category'
                        : 'No doctors found',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final d = filtered[i];
                final name = d['user']?['full_name'] ?? d['full_name'] ?? 'Doctor';
                final spec = d['specialization'] ?? '-';
                final rating = d['average_rating'] ?? 0;
                final fee = d['consultation_fee'] ?? 0;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorProfileScreen(doctor: d),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blue.shade50,
                              image: d['avatar'] != null
                                  ? DecorationImage(image: NetworkImage(d['avatar']), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: d['avatar'] == null
                                ? const Icon(Icons.person, size: 35, color: Colors.blue)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  spec,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$rating',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$$fee',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}