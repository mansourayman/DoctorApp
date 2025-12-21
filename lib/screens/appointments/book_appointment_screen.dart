import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  BookAppointmentScreen({required this.doctor});
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  bool loading = false;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _book() async {
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('اختر التاريخ والوقت')));
      return;
    }
    setState(() => loading = true);
    final start = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final end = start.add(Duration(minutes: 30));
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.authService.api.createAppointment({
        'doctor_id': widget.doctor['id'],
        'start_datetime': start.toUtc().toIso8601String(),
        'end_datetime': end.toUtc().toIso8601String(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم إرسال طلب الحجز')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحجز: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.doctor['user']?['full_name'] ?? 'Doctor';
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(
                  'Choose Appointment Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _date == null
                      ? 'No date'
                      : '${_date!.year}-${_date!.month}-${_date!.day}',
                ),
                trailing: Icon(Icons.calendar_today, color: AppTheme.primary),
                onTap: _pickDate,
              ),
            ),
            SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(
                  'Choose Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _time == null ? 'No time' : _time!.format(context),
                ),
                trailing: Icon(Icons.access_time, color: AppTheme.primary),
                onTap: _pickTime,
              ),
            ),
            Spacer(),
            loading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _book,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text('Confirm'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
