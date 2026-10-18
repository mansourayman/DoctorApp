import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'appointment_details_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      final res = await api.getMyAppointments();

      if (!mounted) return;
      setState(() {
        data = List<Map<String, dynamic>>.from(res);
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

  bool _isUpcoming(String s) => s == 'pending' || s == 'confirmed';
  bool _isPast(String s) => s == 'completed';
  bool _isCancelled(String s) => s == 'cancelled' || s == 'rejected';

  int? _appointmentId(Map<String, dynamic> a) {
    final id = a['id'];
    if (id is int) return id;
    return int.tryParse('$id');
  }

  DateTime? _parseDt(String? iso) =>
      iso == null ? null : DateTime.tryParse(iso);

  String _fmtDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
  }

  String _fmtTime(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _prettyStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  List<Map<String, dynamic>> _filterTab(int index) {
    final items = data.where((a) {
      final status = (a['status'] ?? '').toString();
      if (index == 0) return _isUpcoming(status);
      if (index == 1) return _isPast(status);
      return _isCancelled(status);
    }).toList();

    items.sort((a, b) {
      final aStart = _parseDt((a['start_datetime'] ?? '').toString());
      final bStart = _parseDt((b['start_datetime'] ?? '').toString());
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;

      if (index == 0) {
        return aStart.compareTo(bStart);
      }
      return bStart.compareTo(aStart);
    });

    return items;
  }

  Future<void> _openDetails(int appointmentId) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointmentId: appointmentId),
      ),
    );
    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _cancelAppointment(Map<String, dynamic> a) async {
    final id = _appointmentId(a);
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.authService.api.cancelAppointment(id);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    }
  }

  Widget _statusChip(String status) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Text(
        _prettyStatus(status),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: c,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.calendar_month_outlined, size: 52, color: Colors.black26),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'No appointments here',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 52, color: Colors.red),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Failed to load:\n$error',
            style: GoogleFonts.poppins(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ),
      ],
    );
  }

  Widget _appointmentCard(Map<String, dynamic> a) {
    final status = (a['status'] ?? '').toString();

    final docName = a['doctor']?['user']?['full_name'] ?? 'Doctor';
    final spec = a['doctor']?['specialization'] ?? 'Specialist';

    final startIso = (a['start_datetime'] ?? '').toString();
    final endIso = (a['end_datetime'] ?? '').toString();

    final start = _parseDt(startIso);
    final end = _parseDt(endIso);

    final dateText = start == null ? '-' : _fmtDate(start);
    final timeText = (start == null || end == null)
        ? '-'
        : '${_fmtTime(start)} - ${_fmtTime(end)}';

    final id = _appointmentId(a);

    final canCancel = _isUpcoming(status);
    final canOpen = id != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docName.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      spec.toString(),
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
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black45),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateText,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black45),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timeText,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: canOpen ? () => _openDetails(id!) : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: canCancel ? () => _cancelAppointment(a) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? _errorState()
            : TabBarView(
                controller: _tab,
                children: List.generate(3, (idx) {
                  final items = _filterTab(idx);
                  if (items.isEmpty) return _emptyState();

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _appointmentCard(items[i]),
                  );
                }),
              ),
      ),
    );
  }
}
