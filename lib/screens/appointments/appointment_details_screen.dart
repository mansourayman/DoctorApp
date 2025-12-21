import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../doctors/doctor_detail_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget { // الاسم بالـ S
  final Map<dynamic, dynamic> appointment; // استبدال dynamic بـ Map لاستقبال البيانات

  const AppointmentDetailsScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  // إزالة متغير _loading لأنه غير مستخدم الآن

  // إلغاء دالة _cancelAppointment
  void _cancelAppointment(dynamic appointmentId) {
    // ترك الدالة فارغة أو إضافة ScaffoldMessenger لإظهار رسالة
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancel action is currently disabled.')),
      );
    }
  }

  // إلغاء دالة _reschedule
  void _reschedule(Map<String, dynamic> doctor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule action is currently disabled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.appointment;

    final id = args['id'];
    final status = args['status'] ?? 'Upcoming';
    final dateStr = args['start_datetime'] ?? args['start'] ?? '';
    DateTime? date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {}

    final doctor = args['doctor'] ?? {};
    final user = doctor['user'] ?? {};
    final docName = user['full_name'] ?? args['doctor_name'] ?? 'Doctor';
    final docSpec = doctor['specialization'] ?? args['specialization'] ?? '';
    final docImage = doctor['avatar'] ?? user['avatar'];
    final fee = doctor['consultation_fee'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Appointment Details', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView( // إزالة check الـ loading
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade50,
                      image: docImage != null
                          ? DecorationImage(image: NetworkImage(docImage), fit: BoxFit.cover)
                          : null,
                    ),
                    child: docImage == null ? const Icon(Icons.person, size: 40, color: Colors.blue) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(docName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(docSpec, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'Cancelled' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == 'Cancelled' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildRow(Icons.calendar_today, 'Date', date != null ? DateFormat('EEEE, d MMMM y').format(date) : '-'),
                  const Divider(height: 30),
                  _buildRow(Icons.access_time, 'Time', date != null ? DateFormat('hh:mm a').format(date) : '-'),
                  const Divider(height: 30),
                  _buildRow(Icons.monetization_on, 'Fee', '\$$fee'),
                ],
              ),
            ),

            const SizedBox(height: 40),

            if (status != 'Cancelled')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {}, // تم إرجاعها إلى حالة عدم العمل
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {}, // تم إرجاعها إلى حالة عدم العمل
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reschedule', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}