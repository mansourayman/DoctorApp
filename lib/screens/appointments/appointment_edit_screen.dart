// lib/screens/appointments/appointment_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // نفترض أنك تستخدم Provider
import '../../services/api_service.dart'; // تأكد من المسار الصحيح لـ ApiService

class AppointmentEditScreen extends StatefulWidget {
  final dynamic appointmentId;
  // يمكن إضافة بيانات الموعد هنا إذا كانت متاحة من الشاشة السابقة

  const AppointmentEditScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentEditScreen> createState() => _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends State<AppointmentEditScreen> {
  late Future<bool> _canEditFuture;

  // هنا يمكنك إضافة متحكمات (Controllers) لحقول الإدخال
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    // 1. عند تهيئة الشاشة: نجري فحص إمكانية التعديل
    _canEditFuture = apiService.checkEditPermission(widget.appointmentId);

    // *نصيحة: هنا يمكنك استدعاء API لجلب تفاصيل الموعد الحالية وملء المتحكمات
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // دالة التعامل مع إرسال النموذج (Submit)
  void _submitEdit() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    // البيانات الجديدة التي سيتم إرسالها إلى الخادم
    final Map<String, dynamic> body = {
      'new_date': _dateController.text,
      'new_time': _timeController.text,
      // ... أي حقول أخرى
    };

    try {
      // 3. استدعاء دالة التحديث
      await apiService.updateAppointment(widget.appointmentId, body);

      // إظهار رسالة نجاح والعودة للشاشة السابقة
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تعديل الموعد بنجاح!')));
        Navigator.pop(context, true); // إرجاع true للإشارة للتحديث
      }
    } catch (e) {
      // إظهار رسالة خطأ من الخادم
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل التعديل: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الموعد')),
      body: FutureBuilder<bool>(
        future: _canEditFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // أثناء التحميل: عرض مؤشر انتظار
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == false) {
            // 2. إذا فشل الفحص: عرض رسالة عدم السماح بالتعديل
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'عفواً، لا يمكن تعديل هذا الموعد حالياً. يرجى التحقق من الشروط.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            );
          }

          // 2. إذا نجح الفحص (snapshot.data == true): عرض نموذج التعديل
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('البيانات الأصلية للموعد تظهر هنا...'),
                  const SizedBox(height: 20),

                  // حقل تعديل التاريخ
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'تاريخ جديد'),
                    readOnly: true, // يفضل استخدام DatePicker
                    onTap: () async {
                      /* فتح DatePicker هنا */
                    },
                  ),
                  const SizedBox(height: 10),

                  // حقل تعديل الوقت
                  TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(labelText: 'وقت جديد'),
                    readOnly: true, // يفضل استخدام TimePicker
                    onTap: () async {
                      /* فتح TimePicker هنا */
                    },
                  ),
                  const SizedBox(height: 40),

                  // زر الحفظ
                  ElevatedButton(
                    onPressed: _submitEdit,
                    child: const Text('حفظ التعديلات'),
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
