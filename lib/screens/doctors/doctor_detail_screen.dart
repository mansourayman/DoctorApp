import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
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

  List<DateTime> _days = const [];
  int _selectedDayIndex = 0;

  bool _slotsLoading = true;
  String? _slotsError;
  List<Map<String, dynamic>> _slots = [];

  String? _selectedSlotStartIso;
  String? _selectedSlotEndIso;

  @override
  void initState() {
    super.initState();
    doc = widget.doctor ?? _mockDoctor();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _arrowAnim = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    final now = DateTime.now();
    _days = List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlotsForSelectedDay();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _doctorId() {
    final id = doc['id'] ?? doc['doctor_id'];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? '');
  }

  String _formatDay(DateTime d) {
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final w = wd[(d.weekday - 1).clamp(0, 6)];
    return '$w ${d.day}/${d.month}';
  }

  String _fmtTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _loadSlotsForSelectedDay() async {
    final doctorId = _doctorId();
    if (doctorId == null) {
      setState(() {
        _slotsLoading = false;
        _slotsError = 'Doctor id is missing';
        _slots = [];
      });
      return;
    }
    if (_days.isEmpty) return;

    setState(() {
      _slotsLoading = true;
      _slotsError = null;
      _slots = [];

      _selectedSlotStartIso = null;
      _selectedSlotEndIso = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      final day = _days[_selectedDayIndex];

      final slots = await api.getAvailableSlots(doctorId: doctorId, date: day);

      if (!mounted) return;
      setState(() {
        _slots = slots;
        _slotsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _slotsLoading = false;
        _slotsError = e.toString();
      });
    }
  }

  void toggleAbout() {
    setState(() {
      aboutExpanded = !aboutExpanded;
      if (aboutExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _openBooking({
    required String slotStartIso,
    required String slotEndIso,
  }) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentScreen(
          doctor: doc,
          slotStartIso: slotStartIso,
          slotEndIso: slotEndIso,
        ),
      ),
    );

    if (ok == true && mounted) {
      await _loadSlotsForSelectedDay();
    }
  }

  Widget _badge({
    required IconData icon,
    required String text,
    Color? bg,
    Color? fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? AppTheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (fg ?? AppTheme.primary).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg ?? AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: fg ?? AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        t,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = doc['user']?['full_name'] ?? doc['full_name'] ?? 'Doctor';
    final specialization = doc['specialization'] ?? 'Specialist';
    final department =
        doc['department']?['name'] ?? doc['department_name'] ?? 'Department';

    final rating = (doc['average_rating'] is num)
        ? (doc['average_rating'] as num).toDouble()
        : double.tryParse('${doc['average_rating'] ?? ''}') ?? 0.0;

    final fee = (doc['consultation_fee'] is num)
        ? (doc['consultation_fee'] as num).toDouble()
        : double.tryParse('${doc['consultation_fee'] ?? ''}') ?? 0;

    final bio = (doc['bio'] ?? '').toString();

    final avatarUrl = (doc['user']?['avatar_url'] ?? doc['avatar_url'] ?? '')
        .toString();

    final canBook =
        !_slotsLoading &&
        _selectedSlotStartIso != null &&
        _selectedSlotEndIso != null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withOpacity(0.75),
                      const Color(0xFF111827).withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: avatarUrl.isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$specialization • $department',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _badge(
                                      icon: Icons.star_rounded,
                                      text: rating > 0
                                          ? rating.toStringAsFixed(1)
                                          : '—',
                                      bg: const Color(0xFFFFF4D6),
                                      fg: const Color(0xFF8A5B00),
                                    ),
                                    const SizedBox(width: 8),
                                    _badge(
                                      icon: Icons.payments_outlined,
                                      text: fee > 0
                                          ? '\$${fee.toStringAsFixed(0)}'
                                          : 'Fee',
                                      bg: Colors.white.withOpacity(0.14),
                                      fg: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('About'),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedCrossFade(
                          firstChild: Text(
                            bio.isEmpty
                                ? 'No bio available.'
                                : (bio.length > 170
                                      ? '${bio.substring(0, 170)}...'
                                      : bio),
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                          secondChild: Text(
                            bio.isEmpty ? 'No bio available.' : bio,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                          crossFadeState: aboutExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 220),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: toggleAbout,
                            icon: RotationTransition(
                              turns: _arrowAnim,
                              child: Icon(
                                Icons.expand_more,
                                color: AppTheme.primary,
                              ),
                            ),
                            label: Text(
                              aboutExpanded ? 'Show less' : 'Read more',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _sectionTitle('Available Times'),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _days.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final d = _days[i];
                              final selected = _selectedDayIndex == i;
                              return ChoiceChip(
                                selected: selected,
                                label: Text(
                                  _formatDay(d),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                selectedColor: AppTheme.primary,
                                backgroundColor: const Color(0xFFF6F7FB),
                                onSelected: (_) async {
                                  setState(() => _selectedDayIndex = i);
                                  await _loadSlotsForSelectedDay();
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_slotsLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_slotsError != null)
                          Text(
                            'Failed to load slots: $_slotsError',
                            style: GoogleFonts.poppins(color: Colors.red),
                          )
                        else if (_slots.isEmpty)
                          Text(
                            'No available slots for this day',
                            style: GoogleFonts.poppins(color: Colors.black54),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _slots.map((s) {
                              final startIso = (s['start_datetime'] ?? '')
                                  .toString();
                              final endIso = (s['end_datetime'] ?? '')
                                  .toString();

                              if (startIso.isEmpty || endIso.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final start = DateTime.tryParse(startIso);
                              final label = start != null
                                  ? _fmtTime(start)
                                  : 'Slot';

                              final selected =
                                  _selectedSlotStartIso == startIso;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_selectedSlotStartIso == startIso) {
                                      _selectedSlotStartIso = null;
                                      _selectedSlotEndIso = null;
                                    } else {
                                      _selectedSlotStartIso = startIso;
                                      _selectedSlotEndIso = endIso;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.primary
                                        : AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.primary
                                          : AppTheme.primary.withOpacity(0.22),
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 18,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canBook
                  ? () => _openBooking(
                      slotStartIso: _selectedSlotStartIso!,
                      slotEndIso: _selectedSlotEndIso!,
                    )
                  : null,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                canBook ? 'Book now' : 'Select a slot',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _mockDoctor() {
    return {
      'id': 1,
      'user': {'full_name': 'Dr. John Smith', 'avatar_url': ''},
      'specialization': 'Cardiologist',
      'department_name': 'Cardiology',
      'average_rating': 4.8,
      'consultation_fee': 250,
      'bio':
          'I am a board-certified doctor with 12 years of experience. I focus on patient-centered care and clear communication.',
    };
  }
}
