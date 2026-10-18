import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/card_doctor.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _doctors = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() async {
    setState(() => _loading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.get('/doctors');
      setState(() => _doctors = res is List ? res : (res['data'] ?? []));
    } catch (e) {
      print('fetch error: \$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Doctors')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _doctors.length,
                itemBuilder: (_, idx) => DoctorCard(
                  doctor: _doctors[idx],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/doctor',
                    arguments: {'id': _doctors[idx]['id']},
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 2) Navigator.pushNamed(context, '/profile');
          // add other nav
        },
      ),
    );
  }
}
