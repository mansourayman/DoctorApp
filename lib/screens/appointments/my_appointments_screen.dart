// lib/screens/appointments/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/appointment_card.dart' hide AppointmentCard;
import 'appointment_edit_screen.dart';
import 'appointment_card.dart';
import 'package:flutter/material.dart';
import '../../services/service_locator.dart';

class MyAppointmentsScreen extends StatefulWidget {
  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> appointments = [];
  bool loading = true;


class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  bool loading = true;
  bool error = false;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
  }

  /// جلب وتحميل قائمة المواعيد من الخادم
  Future<void> _refreshAppointments() async {
    // نضع setLoading هنا للتأكد من تحديث القائمة بعد أي إجراء (تعديل/تأكيد)
    setState(() => loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final res = await auth.authService.api.getMyAppointments();
      setState(() => appointments = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  //  منطق التعامل مع ضغط زر 'تأكيد' (Verify)
  Future<void> _handleVerify(dynamic id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => loading = true); // يفضل إظهار مؤشر تحميل مؤقت
    try {
      // 1. استدعاء دالة التأكيد
      await auth.authService.api.verifyAppointment(id);

      // 2. إظهار رسالة نجاح
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تأكيد الموعد بنجاح!')));

      // 3. إعادة تحميل القائمة لرؤية التغيير
      await _refreshAppointments();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل التأكيد: ${e.toString()}')));
    } finally {
      setState(() => loading = false); // إخفاء مؤشر التحميل
    }
  }

  //  منطق التعامل مع ضغط زر 'تعديل' (Edit)
  Future<void> _handleEdit(dynamic id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      // 1. الفحص الأولي: هل مسموح بالتعديل؟
      final canEdit = await auth.authService.api.checkEditPermission(id);

      if (canEdit) {
        // 2. إذا كان مسموحًا: انتقل إلى شاشة التعديل
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentEditScreen(appointmentId: id),
          ),
        );
        // 3. بعد العودة من شاشة التعديل، إذا كانت النتيجة "true" (تم التعديل)، أعد التحميل
        if (result == true) {
          await _refreshAppointments();
        }
      } else {
        // إذا لم يكن مسموحًا: اعرض رسالة للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن تعديل الموعد حالياً. يرجى مراجعة الشروط.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في فحص التعديل: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (appointments.isEmpty)
      return const Center(child: Text('لا توجد مواعيد حالياً'));

    return RefreshIndicator(
      // إضافة خاصية السحب للتحديث
      onRefresh: _refreshAppointments,
      child: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, i) {
          final a = appointments[i];
          return AppointmentCard(
            appointment: a,
            // 4. ربط الدوال بالـ Card
            onEdit: () =>
                _handleEdit(a['id']), // نفترض أن الـ id موجود في الـ Map
            onVerify: () =>
                _handleVerify(a['id']), // نفترض أن الـ id موجود في الـ Map
          );
        },
      ),
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ServiceLocator.api!.getMyAppointments();
      setState(() {
        items = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  Color getStatusColor(String s) {
    switch (s) {
      case "pending":
        return Colors.orange;
      case "confirmed":
        return Colors.green;
      case "completed":
        return Colors.blue;
      case "cancelled":
        return Colors.red;
      case "rejected":
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  String capitalize(String s) =>
      s.isEmpty ? s : "${s[0].toUpperCase()}${s.substring(1)}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
          ? const Center(child: Text("Error loading appointments"))
          : items.isEmpty
          ? const Center(child: Text("No appointments found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final ap = items[i];

                final doctorUser = ap["doctor"]["user"];
                final dep = ap["doctor"]["department"];

                String doctorName = doctorUser["full_name"];
                String avatar = doctorUser["avatar_url"] ?? "";
                String department = dep != null ? dep["name"] : "Unknown";

                // datetime
                final startDT = DateTime.parse(ap["start_datetime"]);
                final date = "${startDT.day}-${startDT.month}-${startDT.year}";
                final time =
                    "${startDT.hour.toString().padLeft(2, '0')}:${startDT.minute.toString().padLeft(2, '0')}";

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/appointment-details",
                      arguments: ap,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: avatar.isNotEmpty
                              ? NetworkImage(avatar)
                              : null,
                          child: avatar.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                department,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "$date • $time",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(
                              ap["status"],
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            capitalize(ap["status"]),
                            style: TextStyle(
                              color: getStatusColor(ap["status"]),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
 }
}