import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../doctors/doctor_detail_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  bool loading = true;
  String? error;

  List<dynamic> doctors = [];
  Map<String, dynamic>? args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args ??= (ModalRoute.of(context)?.settings.arguments as Map?)
        ?.cast<String, dynamic>();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;

    final prefetched = args?['prefetched_doctors'];
    if (prefetched is List) {
      setState(() {
        doctors = prefetched;
        loading = false;
        error = null;
      });
      return;
    }

    await _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      final q = (args?['q'] ?? '').toString();
      final depId = args?['department_id'];
      final filters = args?['filters'];

      int? depIdInt;
      if (depId != null) depIdInt = int.tryParse(depId.toString());

      double? minFee, maxFee, minRating;
      bool? available;
      String? category;

      if (filters is Map) {
        category = filters['category']?.toString();
        minFee = (filters['min_fee'] is num)
            ? (filters['min_fee'] as num).toDouble()
            : double.tryParse('${filters['min_fee'] ?? ''}');
        maxFee = (filters['max_fee'] is num)
            ? (filters['max_fee'] as num).toDouble()
            : double.tryParse('${filters['max_fee'] ?? ''}');
        minRating = (filters['min_rating'] is num)
            ? (filters['min_rating'] as num).toDouble()
            : double.tryParse('${filters['min_rating'] ?? ''}');
        if (filters['available'] is bool) available = filters['available'];
      }

      final res = await api.getDoctors(
        q: q.isEmpty ? null : q,
        departmentId: depIdInt,
        category: category,
        minFee: minFee,
        maxFee: maxFee,
        minRating: minRating,
        available: available,
        page: 1,
        perPage: 50,
      );

      if (!mounted) return;
      setState(() {
        doctors = res;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Widget _doctorTile(dynamic d) {
    final user = d['user'] ?? {};
    final name = (user['full_name'] ?? d['full_name'] ?? 'Doctor').toString();
    final spec = (d['specialization'] ?? d['spec'] ?? '-').toString();
    final avatarUrl = (user['avatar_url'] ?? d['avatar_url'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: d)),
          );
        },
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person, color: AppTheme.primary),
                      )
                    : Icon(Icons.person, color: AppTheme.primary, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spec,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = (args?['title'] ?? 'Doctors').toString();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(onPressed: _loadFromApi, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : doctors.isEmpty
          ? Center(
              child: Text(
                'No doctors found',
                style: GoogleFonts.poppins(color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (_, i) => _doctorTile(doctors[i]),
            ),
    );
  }
}
