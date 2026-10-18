import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/doctors_provider.dart';
import '../widgets/card_doctor.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});
  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    final prov = Provider.of<DoctorsProvider>(context, listen: false);
    prov.fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DoctorsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: prov.doctors.length,
              itemBuilder: (context, i) {
                final doc = prov.doctors[i];
                return DoctorCard(doctor: doc);
              },
            ),
    );
  }
}
