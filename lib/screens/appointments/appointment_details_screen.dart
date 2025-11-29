import 'package:flutter/material.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Map appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final doctor = appointment["doctor"]["user"];
    final spec = appointment["doctor"]["specialization"];
    final dep = appointment["department"];
    final startDT = DateTime.parse(appointment["start_datetime"]);

    String date =
        "${startDT.day.toString().padLeft(2, '0')} "
        "${_monthName(startDT.month)} "
        "${startDT.year}";

    String time =
        "${(startDT.hour % 12 == 0 ? 12 : startDT.hour % 12).toString().padLeft(2, '0')}:"
        "${startDT.minute.toString().padLeft(2, '0')} "
        "${startDT.hour >= 12 ? "PM" : "AM"}";

    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        title: const Text("Details Appointment"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- Card -----------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Details Appointment",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  _detailItem(
                    title: date,
                    subtitle: "Appointment Date",
                    icon: Icons.calendar_month,
                  ),

                  const SizedBox(height: 12),

                  _detailItem(
                    title: time,
                    subtitle: "Appointment Time",
                    icon: Icons.access_time,
                  ),

                  const SizedBox(height: 12),

                  _detailItem(
                    title: dep != null ? dep["name"] : "Unknown Hospital",
                    subtitle: "Appointment Location",
                    icon: Icons.location_city,
                  ),

                  const SizedBox(height: 18),

                  // Doctor card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xfff4f4f4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundImage: doctor["avatar_url"] != null
                              ? NetworkImage(doctor["avatar_url"])
                              : const AssetImage("assets/images/doctor.png")
                                    as ImageProvider,
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor["full_name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                spec ?? "Specialist",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.verified,
                          color: Colors.teal,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- Buttons ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _btn("Edit", Colors.grey.shade300, Colors.black),
                _btn("Verify", const Color(0xff4c9aff), Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------- Small widgets ---------

  Widget _detailItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        Icon(icon, color: Colors.grey[700], size: 22),
      ],
    );
  }

  Widget _btn(String text, Color bg, Color fg) {
    return Container(
      width: 130,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m - 1];
  }
}
