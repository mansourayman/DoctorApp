import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final Map doctor;
  final VoidCallback onTap;
  const DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = doctor['user'] ?? {};
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null ? Icon(Icons.person) : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Dr. Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      doctor['specialization'] ?? 'General',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text((doctor['average_rating'] ?? 0).toString()),
                  SizedBox(height: 8),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
