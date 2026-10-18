import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  final String slotStartIso;
  final String slotEndIso;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
    required this.slotStartIso,
    required this.slotEndIso,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  bool loading = false;

  DateTime? get _start => DateTime.tryParse(widget.slotStartIso);
  DateTime? get _end => DateTime.tryParse(widget.slotEndIso);

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(DateTime d) {
    final local = d.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _book() async {
    final start = _start;
    final end = _end;

    if (start == null || end == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Slot غير صالح')));
      return;
    }

    final rawId = widget.doctor['id'] ?? widget.doctor['doctor_id'];
    final doctorId = rawId is int ? rawId : int.tryParse('$rawId');
    if (doctorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Doctor ID غير صالح')));
      return;
    }

    setState(() => loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      await auth.authService.api.createAppointment({
        'doctor_id': doctorId,

        'start_datetime': widget.slotStartIso,
        'end_datetime': widget.slotEndIso,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الحجز')));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحجز: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.doctor['user']?['full_name'] ?? 'Doctor';
    final start = _start;
    final end = _end;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text('Confirm Booking - $name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text(
                  'Appointment Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(start == null ? '-' : _fmtDate(start)),
                trailing: Icon(Icons.calendar_today, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text(
                  'Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (start == null || end == null)
                      ? '-'
                      : '${_fmtTime(start)} - ${_fmtTime(end)}',
                ),
                trailing: Icon(Icons.access_time, color: AppTheme.primary),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _book,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirm'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
