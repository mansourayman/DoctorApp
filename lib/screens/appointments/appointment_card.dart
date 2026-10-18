// lib/screens/appointments/appointment_card.dart

import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onEdit;
  final VoidCallback onVerify;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'] as String? ?? 'pending';

    return Card(
      // ... (بقية تصميم البطاقة)
      child: Column(
        children: [
          // ... تفاصيل الموعد
          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // زر التعديل
              if (status != 'verified')
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('تعديل'),
                  onPressed: onEdit, // 👈 ربط الدالة
                ),

              const SizedBox(width: 8),

              // زر التأكيد
              if (status == 'pending') // مثال لشرط الظهور
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('تأكيد'),
                  onPressed: onVerify, // 👈 ربط الدالة
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
      // ...
    );
  }
}
