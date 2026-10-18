import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool loading = true;
  bool actionLoading = false;
  String? error;

  Map<String, dynamic>? appt;

  int rating = 5;
  final commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _load(),
    ); // is important beacuse if the context not ready or mediaQuery
  }

  @override
  void dispose() {
    commentCtrl.dispose();
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

      final res = await api.getAppointmentDetails(widget.appointmentId);

      if (!mounted) return;
      setState(() {
        appt = Map<String, dynamic>.from(res);
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

  String _fmtDateTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final l = dt.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}  '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _cancel() async {
    if (appt == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text('This will cancel your appointment.'),
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

    setState(() => actionLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      await api.cancelAppointment(widget.appointmentId);

      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (appt == null) return;

    setState(() => actionLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      await api.createReview({
        'appointment_id': widget.appointmentId,
        'rating': rating,
        'comment': commentCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review submitted')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Review failed: $e')));
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointment Details')),
        body: Center(child: Text('Error: $error')),
      );
    }

    final a = appt ?? {};
    final status = (a['status'] ?? '').toString();

    final doctorName = a['doctor']?['user']?['full_name'] ?? 'Doctor';
    final spec = a['doctor']?['specialization'] ?? 'Specialist';

    final startIso = (a['start_datetime'] ?? '').toString();
    final endIso = (a['end_datetime'] ?? '').toString();

    final reason = (a['reason'] ?? '').toString();

    final canCancel = status == 'pending' || status == 'confirmed';
    final canReview = status == 'completed';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'Appointment Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: actionLoading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  spec.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _row('Status', status),
                const SizedBox(height: 6),
                _row('Start', _fmtDateTime(startIso)),
                const SizedBox(height: 6),
                _row('End', _fmtDateTime(endIso)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  reason.isEmpty ? '—' : reason,
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (canCancel)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: actionLoading ? null : _cancel,
                icon: const Icon(Icons.cancel),
                label: Text(
                  'Cancel Appointment',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

          if (canReview) ...[
            const SizedBox(height: 14),
            Text(
              'Leave a Review',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<int>(
                    value: rating,
                    onChanged: actionLoading
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() => rating = v);
                          },
                    items: [1, 2, 3, 4, 5]
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text('$r Stars'),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: actionLoading ? null : _submitReview,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: actionLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit Review',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
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

  Widget _row(String k, String v) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            k,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
