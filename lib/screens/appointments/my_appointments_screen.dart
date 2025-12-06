// lib/screens/appointments/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/appointment_card.dart' hide AppointmentCard;
import 'appointment_edit_screen.dart';
import 'appointment_card.dart';

class MyAppointmentsScreen extends StatefulWidget {
  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> appointments = [];
  bool loading = true;

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
    );
  }
}
