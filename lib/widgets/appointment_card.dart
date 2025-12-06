import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  AppointmentCard({required this.appointment});
  @override
  Widget build(BuildContext context) {
    final doctor = appointment['doctor']?['user']?['full_name'] ?? 'Doctor';
    final datetime = appointment['start_datetime'] ?? '';
    final status = appointment['status'] ?? '';
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(doctor),
        subtitle: Text(formatDate(datetime)),
        trailing: Text(status),
      ),
    );
  }
}
