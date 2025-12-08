// lib/screens/filters_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({Key? key}) : super(key: key);

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues _feeRange = RangeValues(50, 300);
  bool _onlyAvailable = false;
  double _minRating = 4.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              // return filters
              Navigator.pop(context, {
                'fee_min': _feeRange.start,
                'fee_max': _feeRange.end,
                'onlyAvailable': _onlyAvailable,
                'minRating': _minRating,
              });
            },
            child: Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consultation fee',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              min: 0,
              max: 500,
              values: _feeRange,
              onChanged: (v) => setState(() => _feeRange = v),
              labels: RangeLabels(
                '\$${_feeRange.start.toInt()}',
                '\$${_feeRange.end.toInt()}',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Only available', style: GoogleFonts.poppins()),
                Switch(
                  value: _onlyAvailable,
                  onChanged: (v) => setState(() => _onlyAvailable = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Minimum rating',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            Slider(
              min: 0,
              max: 5,
              value: _minRating,
              onChanged: (v) => setState(() => _minRating = v),
              divisions: 5,
              label: _minRating.toStringAsFixed(1),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _feeRange = RangeValues(50, 300);
                    _onlyAvailable = false;
                    _minRating = 4.0;
                  });
                },
                child: Text('Reset'),
  List<Map<String, dynamic>> _departments = [];
  List<int> _selectedDeptIds = [];
  String _deptQuery = '';
  double _minFee = 0;
  double _maxFee = 500; // تعديل افتراضي
  RangeValues _feeRange = const RangeValues(0, 500);
  double _minRating = 0;
  double _rating = 0;
  bool _onlyAvailable = false;

  bool _loading = true;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _loadDeps();
  }

  Future<void> _loadDeps() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.authService.api;
      final deps = await api.getDepartments();

      final parsed = <Map<String, dynamic>>[];
      if (deps is List) {
        for (final d in deps) {
          if (d is Map<String, dynamic>) {
            final id = d['id'] ?? d['department_id'] ?? d['dept_id'];
            final name = (d['name'] ?? d['title'] ?? d['department_name'] ?? '')
                .toString();
            final image = d['image_url'] ?? d['image'] ?? d['icon'] ?? null;
            parsed.add({'id': id, 'name': name, 'image': image});
          }
        }
      }

      // fallback empty -> keep empty list
      if (mounted) setState(() => _departments = parsed);
    } catch (e) {
      // إذا فشل النداء، نظهر toast بسيط لكن لا نكسر الواجهة
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed loading departments: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDeptIds.clear();
      _deptQuery = '';
      _feeRange = RangeValues(_minFee, _maxFee);
      _rating = 0;
      _onlyAvailable = false;
    });
  }

  void _applyFilters() {
    setState(() => _applying = true);
    // نحَضّر خريطة الفلاتر ونرجعها
    final filters = <String, dynamic>{};
    if (_selectedDeptIds.isNotEmpty)
      filters['department_ids'] = _selectedDeptIds;
    if (_feeRange.start > _minFee || _feeRange.end < _maxFee) {
      filters['min_fee'] = _feeRange.start.round();
      filters['max_fee'] = _feeRange.end.round();
    }
    if (_rating > 0) filters['min_rating'] = _rating;
    if (_onlyAvailable) filters['available'] = true;

    // Simulate short delay để تحسين UX
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _applying = false);
        Navigator.of(context).pop(filters); // ارجع الفلاتر للشاشة السابقة
      }
    });
  }

  List<Map<String, dynamic>> get _filteredDepartments {
    final q = _deptQuery.trim().toLowerCase();
    if (q.isEmpty) return _departments;
    return _departments.where((d) {
      final name = (d['name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  Widget _buildDeptCard(Map<String, dynamic> d) {
    final id = d['id'];
    final name = d['name'] ?? '';
    final image = d['image'] as String?;
    final selected = _selectedDeptIds.contains(id);

    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedDeptIds.remove(id);
          } else {
            _selectedDeptIds.add(id);
          }
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.grey.withOpacity(0.12),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // thumbnail
            if (image != null && image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.medical_services,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final themePrimary = AppTheme.primary;
    final media = MediaQuery.of(context).size;
    final crossAxis = media.width > 700 ? 4 : (media.width > 520 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filters',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text('Reset', style: TextStyle(color: themePrimary)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Search box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search departments',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _deptQuery = v),
                            ),
                          ),
                          if (_deptQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => _deptQuery = ''),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Departments grid
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Departments',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _filteredDepartments.isEmpty
                          ? Center(
                              child: Text(
                                'No departments found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _filteredDepartments.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxis,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.88,
                                  ),
                              itemBuilder: (ctx, i) =>
                                  _buildDeptCard(_filteredDepartments[i]),
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Fee range
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation fee',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '\$${_feeRange.start.round()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${_feeRange.end.round()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _feeRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            '\$${_feeRange.start.round()}',
                            '\$${_feeRange.end.round()}',
                          ),
                          activeColor: themePrimary,
                          onChanged: (v) => setState(() => _feeRange = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Rating + Availability
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Min rating',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Slider(
                                value: _rating,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                label: _rating == 0
                                    ? 'Any'
                                    : _rating.toStringAsFixed(1),
                                activeColor: themePrimary,
                                onChanged: (v) => setState(() => _rating = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Available now',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            Switch(
                              value: _onlyAvailable,
                              activeColor: themePrimary,
                              onChanged: (v) =>
                                  setState(() => _onlyAvailable = v),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Apply button (sticky like)
                    SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _applying ? null : _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themePrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _applying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Apply filters',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
 }
}