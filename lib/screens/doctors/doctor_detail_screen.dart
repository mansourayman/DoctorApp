import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../appointments/book_appointment_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;
  const DoctorProfileScreen({Key? key, this.doctor}) : super(key: key);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen>
    with SingleTickerProviderStateMixin {
  late final Map<String, dynamic> doc;
  bool aboutExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    doc = widget.doctor ?? _mockDoctor(); // fallback mock data for preview
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 280),
    );
    _arrowAnim = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleAbout() {
    setState(() {
      aboutExpanded = !aboutExpanded;
      if (aboutExpanded)
        _controller.forward();
      else
        _controller.reverse();
    });
  }

  // simple star widget (supports decimal rating)
  Widget _buildStars(double rating, {double size = 16}) {
    final full = rating.floor();
    final partial = rating - full;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return Icon(Icons.star, color: Colors.amber, size: size);
        if (i == full && partial >= 0.25) {
          if (partial >= 0.75)
            return Icon(Icons.star, color: Colors.amber, size: size);
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        }
        return Icon(Icons.star_border, color: Colors.amber, size: size);
      }),
    );
  }

  Widget _ratingBar(int star, double fraction) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text('$star', style: TextStyle(fontSize: 12)),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          '${(fraction * 100).round()}%',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // small helper to navigate to booking panel (passes initialDateTime if BookAppointmentScreen supports it)
  Future<void> _openBooking({DateTime? initial}) async {
    // If BookAppointmentScreen constructor accepts initialDateTime, pass it.
    // Here we try to pass; if your screen doesn't accept it, simply remove this parameter.
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.88,
        child: BookAppointmentScreen(
          doctor: doc,
          // if your BookAppointmentScreen doesn't take initialDateTime, remove the next line:
          // initialDateTime: initial,
        ),
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Appointment booked')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        doc['user']?['full_name'] ?? doc['full_name'] ?? 'Dr. John Smith';
    final specialization = doc['specialization'] ?? 'Cardiologist';
    final department = doc['department_name'] ?? 'Heart Department';
    final rating = (doc['average_rating'] is num)
        ? (doc['average_rating'] as num).toDouble()
        : 4.8;
    final reviewsCount = doc['reviews_count'] ?? 230;
    final fee = doc['consultation_fee'] ?? 50;
    final years = doc['years_experience'] ?? 12;
    final bio = doc['bio'] ?? '';

    final available =
        (doc['available_dates'] as List<dynamic>?) ??
        _mockAvailableDates(); // list of {date: DateTime, times: List<String>}

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar and main info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avatar(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$specialization • $department',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: AppTheme.primary,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    _buildStars(rating, size: 14),
                                    SizedBox(width: 8),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$years yrs experience',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14),

              // Fee + Book button
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$$fee',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Consultation Fee',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () => _openBooking(),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: AppTheme.primary,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text('Book Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18),

              // About with expand animation
              Row(
                children: [
                  Text(
                    'About',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: toggleAbout,
                    child: Row(
                      children: [
                        Text(
                          aboutExpanded ? 'Show less' : 'Read more',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                        RotationTransition(
                          turns: _arrowAnim,
                          child: Icon(
                            Icons.expand_more,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              AnimatedCrossFade(
                firstChild: Text(
                  bio.length > 160 ? '${bio.substring(0, 160)}...' : bio,
                  style: TextStyle(color: Colors.grey[800], height: 1.35),
                ),
                secondChild: Text(
                  bio,
                  style: TextStyle(color: Colors.grey[800], height: 1.35),
                ),
                crossFadeState: aboutExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 260),
              ),

              SizedBox(height: 18),

              // Department tile
              Text(
                'Department & Specialization',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // navigate to doctors list filtered by department
                  Navigator.pushNamed(
                    context,
                    '/doctors',
                    arguments: {'category': department},
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              department,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              specialization,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18),

              // Ratings & reviews summary
              Row(
                children: [
                  Text(
                    'Ratings & Reviews',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Text(
                    '$reviewsCount reviews',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 6),
                      _buildStars(rating, size: 14),
                    ],
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _ratingBar(5, 0.6),
                        SizedBox(height: 8),
                        _ratingBar(4, 0.2),
                        SizedBox(height: 8),
                        _ratingBar(3, 0.12),
                        SizedBox(height: 8),
                        _ratingBar(2, 0.05),
                        SizedBox(height: 8),
                        _ratingBar(1, 0.03),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14),

              // one sample review card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    'Emily Johnson',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        'Dr. Smith is excellent! Highly recommended.',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '5 days ago',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: _buildStars(5.0, size: 14),
                ),
              ),

              SizedBox(height: 18),

              // Available appointments - horizontal list
              Row(
                children: [
                  Text(
                    'Available Appointments',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  TextButton(onPressed: () {}, child: Text('See all')),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: available.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12),
                  padding: EdgeInsets.only(right: 8),
                  itemBuilder: (ctx, i) {
                    final block = available[i] as Map<String, dynamic>;
                    final date = block['date'] as DateTime;
                    final times = (block['times'] as List<dynamic>)
                        .cast<String>();
                    return Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_weekdayShort(date.weekday)}, ${date.day} ${_monthShort(date.month)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: times.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8),
                              itemBuilder: (ctx2, j) {
                                final t = times[j];
                                return GestureDetector(
                                  onTap: () {
                                    // parse t (HH:mm) to DateTime
                                    final parts = t
                                        .split(':')
                                        .map((s) => int.tryParse(s) ?? 0)
                                        .toList();
                                    final picked = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      parts[0],
                                      parts[1],
                                    );
                                    _openBooking(initial: picked);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        t,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
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
                  },
                ),
              ),

              SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    final avatar = doc['avatar_url'] as String?;
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6)),
        ],
      ),
      child: ClipOval(
        child: avatar != null && avatar.isNotEmpty
            ? Image.network(avatar, fit: BoxFit.cover)
            : Image.asset('assets/images/doctor.png', fit: BoxFit.cover),
      ),
    );
  }

  String _weekdayShort(int wd) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(wd - 1) % 7];
  }

  String _monthShort(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(m - 1) % 12];
  }

  // ---------- MOCK helpers (remove when using real API) ----------
  Map<String, dynamic> _mockDoctor() {
    return {
      'id': 2,
      'user': {'full_name': 'Dr. John Smith'},
      'full_name': 'Dr. John Smith',
      'specialization': 'Cardiologist',
      'department_name': 'Heart Department',
      'average_rating': 4.8,
      'reviews_count': 230,
      'years_experience': 12,
      'consultation_fee': 50,
      'bio':
          'Cardiologist with over 12 years experience, focused on cardiovascular diseases and patient care. Experienced in interventions and long-term follow-ups. Passionate about patient education and prevention.',
      'avatar_url': null,
      'available_dates': _mockAvailableDates(),
    };
  }

  List<Map<String, dynamic>> _mockAvailableDates() {
    final now = DateTime.now();
    List<Map<String, dynamic>> out = [];
    for (int i = 0; i < 6; i++) {
      final d = now.add(Duration(days: i));
      out.add({
        'date': d,
        'times': ['09:00', '09:30', '10:00', '11:00', '14:00'],
      });
    }
    return out;
  }
}
