import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'doctor_detail_screen.dart';

class ExploreDoctorsScreen extends StatefulWidget {
  const ExploreDoctorsScreen({Key? key}) : super(key: key);

  @override
  State<ExploreDoctorsScreen> createState() => _ExploreDoctorsScreenState();
}

class _ExploreDoctorsScreenState extends State<ExploreDoctorsScreen> {
  bool _loading = true;
  List<dynamic> _doctors = [];
  List<Map<String, dynamic>> _departments = [];

  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;

      // تحميل الأقسام والدكاترة
      final docs = await api.getDoctors();
      final deps = await api.getDepartments();

      final parsedDeps = <Map<String, dynamic>>[];
      if (deps is List) {
        for (final d in deps) {
          if (d is Map<String, dynamic>) {
            final name = (d['name'] ?? d['title'] ?? '').toString();
            final image = d['image_url'] ?? d['image'] ?? d['icon'];
            parsedDeps.add({'name': name, 'image': image});
          }
        }
      }

      if (mounted) {
        setState(() {
          _doctors = docs;
          _departments = parsedDeps;
        });
      }
    } catch (e) {
      // Error handling silently or toast
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // تصفية الدكاترة بناءً على البحث والقسم المختار
    final filtered = _doctors.where((d) {
      final name = (d['user']?['full_name'] ?? d['full_name'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase());

      bool matchesCategory = true;
      if (_selectedCategory != null) {
        final deptName = d['department']?['name']?.toString();
        final spec = (d['specialization'] ?? d['category'] ?? '').toString();

        if (deptName != null && deptName.isNotEmpty) {
          matchesCategory = deptName == _selectedCategory;
        } else {
          matchesCategory = spec.contains(_selectedCategory!) || _selectedCategory!.contains(spec);
        }
      }

      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      children: [
        // 1. شريط البحث
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search for a doctor...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),

        // 2. الأقسام (شريط أفقي)
        if (_departments.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _departments.length + 1, // +1 for "All"
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  final isSelected = _selectedCategory == null;
                  return ChoiceChip(
                    label: const Text('All'),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedCategory = null),
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    backgroundColor: Colors.white,
                  );
                }
                final dep = _departments[i - 1];
                final isSelected = _selectedCategory == dep['name'];
                return ChoiceChip(
                  label: Text(dep['name']),
                  selected: isSelected,
                  onSelected: (v) => setState(() => _selectedCategory = v ? dep['name'] : null),
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.white,
                  avatar: dep['image'] != null
                      ? CircleAvatar(backgroundImage: NetworkImage(dep['image']))
                      : null,
                );
              },
            ),
          ),

        const SizedBox(height: 10),

        // 3. قائمة الدكاترة
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
              ? Center(child: Text("No doctors found", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final d = filtered[i];
              final name = d['user']?['full_name'] ?? d['full_name'] ?? 'Doctor';
              final spec = d['specialization'] ?? '-';
              final rating = d['average_rating'] ?? 0;
              final fee = d['consultation_fee'] ?? 0;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: d)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue.shade50,
                            image: d['avatar'] != null
                                ? DecorationImage(image: NetworkImage(d['avatar']), fit: BoxFit.cover)
                                : null,
                          ),
                          child: d['avatar'] == null
                              ? const Icon(Icons.person, size: 35, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                spec,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text('\$$fee', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}