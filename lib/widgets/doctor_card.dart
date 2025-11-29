import 'package:flutter/material.dart';
import '../theme.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback? onBook;
  DoctorCard({required this.doctor, this.onBook});

  @override
  Widget build(BuildContext context) {
    final name = doctor['user']?['full_name'] ?? 'Doctor';
    final spec = doctor['specialization'] ?? '-';
    final price = doctor['consultation_fee'] != null
        ? doctor['consultation_fee'].toString()
        : '-';
    final rating = doctor['average_rating'] != null
        ? double.tryParse(doctor['average_rating'].toString()) ?? 0.0
        : 0.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppTheme.primary.withOpacity(0.12),
              child: Icon(Icons.person, color: AppTheme.primary, size: 30),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(spec, style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating.round() ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : '—',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$ $price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onBook,
                  child: Text('احجز'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
