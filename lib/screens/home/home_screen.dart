import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../doctors/doctor_detail_screen.dart';
import '../doctors/explore_doctors_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<dynamic> _doctors = [];
  List<dynamic> _appointments = [];
  List<Map<String, dynamic>> _departments = [];
  String _searchQuery = '';
  int _navIndex = 0;
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHomeData());
  }

  Future<void> _loadHomeData() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      final doctorsFuture = api.getDoctors(_activeFilters);
      final appointmentsFuture = api.getMyAppointments();
      final deps = await api.getDepartments();

      List<Map<String, dynamic>> parsedDeps = [];
      if (deps is List) {
        for (final d in deps) {
          if (d is Map<String, dynamic>) {
            parsedDeps.add({
              'name': (d['name'] ?? '').toString(),
              'image_url': d['image_url'] ?? d['image'] ?? d['icon'],
            });
          }
        }
      }

      final doctors = await doctorsFuture;
      final appointments = await appointmentsFuture;

      if (mounted) {
        setState(() {
          _doctors = doctors;
          _appointments = appointments;
          _departments = parsedDeps;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goTo(String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  Widget _buildHomeContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
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
                          setState(() => _activeFilters = result);
                          _loadHomeData();
                        }
                      },
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Appointments', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(onPressed: () => _goTo('/appointments'), child: const Text('See All')),
              ],
            ),
            if (_appointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text("No appointments yet", style: TextStyle(color: Colors.grey))),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final a = _appointments[i];
                    final docName = a['doctor']?['user']?['full_name'] ?? a['doctor_name'] ?? 'Doctor';
                    final time = a['start_datetime'] ?? a['start'] ?? '';

                    // التعديل 1: إضافة GestureDetector هنا عشان الحجز يفتح التفاصيل
                    return GestureDetector(
                      onTap: () => _goTo('/appointment-details', arguments: a),
                      child: Container(
                        width: 260,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(docName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                Text('$time', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Departments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Departments', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(onPressed: () => _goTo('/departments'), child: const Text('See All')),
              ],
            ),
            if (_departments.isEmpty)
              const Center(child: Text("No departments"))
            else
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _departments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final d = _departments[i];

                    // التعديل 2: إضافة GestureDetector للقسم عشان يفتح صفحة الدكاترة بالفلتر ده
                    return GestureDetector(
                      onTap: () {
                        // الانتقال لصفحة الدكاترة مع تمرير اسم القسم
                        Navigator.pushNamed(context, '/doctors', arguments: {'category': d['name']});
                      },
                      child: Chip(
                        avatar: d['image_url'] != null ? CircleAvatar(backgroundImage: NetworkImage(d['image_url'])) : null,
                        label: Text(d['name']),
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Top Doctors
            Text('Top Doctors', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _doctors.length,
              itemBuilder: (ctx, i) {
                final d = _doctors[i];
                final name = (d['user']?['full_name'] ?? d['full_name'] ?? '').toString();
                if (_searchQuery.isNotEmpty && !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink();
                }
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: d['avatar'] != null ? NetworkImage(d['avatar']) : null,
                      child: d['avatar'] == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(d['specialization'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: d))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    Widget bodyContent;
    if (_navIndex == 0) {
      bodyContent = _buildHomeContent();
    } else if (_navIndex == 1) {
      bodyContent = const ExploreDoctorsScreen();
    } else {
      bodyContent = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello,', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text(
              auth.user?['name'] ?? 'User',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () => _goTo('/notifications'),
          ),
        ],
      ),
      body: bodyContent,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 2) {
            _goTo('/appointments');
            return;
          }
          if (i == 3) {
            return;
          }
          if (i == 4) {
            _goTo('/profile');
            return;
          }
          setState(() => _navIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Appts'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}