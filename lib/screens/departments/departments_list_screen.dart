import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';

class DepartmentsListScreen extends StatefulWidget {
  const DepartmentsListScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentsListScreen> createState() => _DepartmentsListScreenState();
}

class _DepartmentsListScreenState extends State<DepartmentsListScreen> {
  bool _loading = true;
  List<dynamic> _departments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;
      // ADAPT: ensure ApiService has getDepartments()
      final data = await api.getDepartments();
      if (mounted) setState(() => _departments = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load departments: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Departments', style: GoogleFonts.poppins())),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final d = _departments[i];
                final name = d['name'] ?? d['title'] ?? 'Department';
                final count =
                    d['doctors_count'] ?? d['doctors']?.length ?? null;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.local_hospital)),
                    title: Text(
                      name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: count != null ? Text('$count doctors') : null,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/doctors',
                        arguments: {'category': name},
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
