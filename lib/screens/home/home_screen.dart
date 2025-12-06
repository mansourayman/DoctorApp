// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../doctors/doctor_detail_screen.dart'; // تأكد أن المسار صحيح واسم الملف مطابق

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<dynamic> _doctors = [];
  List<dynamic> _appointments = [];
  String _searchQuery = '';
  int _navIndex = 0;

  // dummy categories (يمكن جلبها من API لاحقاً)
  final List<String> _categories = [
    'Dentist',
    'Cardiology',
    'Orthopedics',
    'ENT',
    'Dermatology',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      final doctors = await api.getDoctors();
      final appointments = await api.getMyAppointments();

      if (mounted) {
        setState(() {
          _doctors = doctors;
          _appointments = appointments;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل البيانات: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // زر التنقل العام: يحمي الوصول إذا كان المستخدم غير مسجّل دخول
  void _goTo(String routeName, {Object? arguments}) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      return;
    }
    if (arguments != null) {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  Widget _buildAppointmentCard(dynamic a) {
    final docName =
        a['doctor']?['user']?['full_name'] ?? a['doctor_name'] ?? 'Doctor';
    final datetime = a['start_datetime'] ?? a['start'] ?? '';
    final timeStr = datetime.toString();
    return GestureDetector(
      onTap: () {
        _goTo('/appointment_detail', arguments: a);
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    docName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a['doctor']?['specialization'] ?? a['specialization'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          timeStr,
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorTile(dynamic d) {
    final name = d['user']?['full_name'] ?? d['full_name'] ?? 'Doctor';
    final spec = d['specialization'] ?? d['spec'] ?? '-';
    final rating = d['average_rating'] ?? d['rating'] ?? 0;
    final fee = d['consultation_fee'] ?? d['fee'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primary.withOpacity(0.12),
          child: const Icon(Icons.person),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              spec,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  (rating is num) ? rating.toStringAsFixed(1) : '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '\$${fee.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        // هنا مررت 'd' بدل doctorMap
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: d)),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: d)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // حماية: لو المستخدم غير مصادق redirect to login
    if (!auth.isAuthenticated && !auth.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Find trusted doctors',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _goTo('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // search
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: const InputDecoration(
                                hintText: 'search doctor by name',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: () => _goTo('/filters'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // My Appointments header
                    Row(
                      children: [
                        Text(
                          'My Appointments',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${_appointments.length}'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _goTo('/appointments'),
                          child: Text(
                            'see all',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // appointments horizontal
                    SizedBox(
                      height: 130,
                      child: _appointments.isEmpty
                          ? Center(
                              child: Text(
                                'No upcoming appointments',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _appointments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (_, i) =>
                                  _buildAppointmentCard(_appointments[i]),
                            ),
                    ),

                    const SizedBox(height: 18),

                    // categories row
                    Row(
                      children: [
                        Text(
                          'Doctor Categories',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _goTo('/departments'),
                          child: Text(
                            'see all',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // categories chips
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final name = _categories[i];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/doctors',
                              arguments: {'category': name},
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Top Doctors',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    // doctors list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _doctors.length,
                      itemBuilder: (ctx, i) {
                        final d = _doctors[i];
                        final name =
                            (d['user']?['full_name'] ?? d['full_name'] ?? '')
                                .toString();
                        if (_searchQuery.isNotEmpty &&
                            !name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            )) {
                          return const SizedBox.shrink();
                        }
                        return _buildDoctorTile(d);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey[700],
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0:
              break;
            case 1:
              _goTo('/appointments');
              break;
            case 2:
              _goTo('/chat');
              break;
            case 3:
              _goTo('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
