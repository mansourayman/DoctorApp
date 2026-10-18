import 'package:appoinment/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

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
  double _maxFee = 500;
  RangeValues _feeRange = const RangeValues(0, 500);

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

      final deps = await api.getDepartmentsCategories();

      if (!mounted) return;
      setState(() {
        _departments = deps.cast<Map<String, dynamic>>();
        _loading = false;
        _feeRange = RangeValues(_minFee, _maxFee);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed loading departments: $e')));
    }
  }

  List<Map<String, dynamic>> get _filteredDepartments {
    final q = _deptQuery.trim().toLowerCase();
    if (q.isEmpty) return _departments;
    return _departments
        .where((d) => (d['name'] ?? '').toString().toLowerCase().contains(q))
        .toList();
  }

  bool get _hasActiveFilters {
    return _selectedDeptIds.isNotEmpty ||
        (_feeRange.start > _minFee || _feeRange.end < _maxFee) ||
        _rating > 0 ||
        _onlyAvailable;
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

    final filters = <String, dynamic>{};

    if (_selectedDeptIds.isNotEmpty) {
      filters['department_id'] = _selectedDeptIds.first;
    }

    if (_feeRange.start > _minFee || _feeRange.end < _maxFee) {
      filters['min_fee'] = _feeRange.start;
      filters['max_fee'] = _feeRange.end;
    }

    if (_rating > 0) filters['min_rating'] = _rating;

    if (_onlyAvailable) filters['available'] = true;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _applying = false);
      Navigator.of(context).pop(filters);
    });
  }

  String _selectedDeptName() {
    if (_selectedDeptIds.isEmpty) return '';
    final selectedId = _selectedDeptIds.first;
    final dep = _departments.firstWhere(
      (d) => d['id'] == selectedId,
      orElse: () => {'name': 'Selected'},
    );
    return (dep['name'] ?? 'Selected').toString();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Filters',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _hasActiveFilters ? _resetFilters : null,
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                color: _hasActiveFilters ? AppColors.primary : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black12.withOpacity(0.06),
                              ),
                            ),
                            child: TextField(
                              onChanged: (v) => setState(() => _deptQuery = v),
                              decoration: InputDecoration(
                                hintText: 'Search department...',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.black45,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (_selectedDeptIds.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_hospital,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedDeptName(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => setState(
                                      () => _selectedDeptIds.clear(),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_filteredDepartments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No departments found',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _filteredDepartments.map((dep) {
                                final id = dep['id'] as int;
                                final name = (dep['name'] ?? '').toString();
                                final selected =
                                    _selectedDeptIds.isNotEmpty &&
                                    _selectedDeptIds.first == id;

                                return ChoiceChip(
                                  selected: selected,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.check_circle
                                            : Icons.local_hospital_outlined,
                                        size: 16,
                                        color: selected
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  selectedColor: AppColors.primary,
                                  backgroundColor: const Color(0xFFF6F7FB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: selected
                                          ? AppColors.primary
                                          : Colors.black12.withOpacity(0.08),
                                    ),
                                  ),
                                  onSelected: (v) {
                                    setState(() {
                                      _selectedDeptIds = v ? [id] : [];
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Consultation Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_feeRange.start.toStringAsFixed(0)} - ${_feeRange.end.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          RangeSlider(
                            min: _minFee,
                            max: _maxFee,
                            values: _feeRange,
                            divisions: 50,
                            labels: RangeLabels(
                              _feeRange.start.toStringAsFixed(0),
                              _feeRange.end.toStringAsFixed(0),
                            ),
                            onChanged: (v) => setState(() => _feeRange = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Minimum Rating',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _rating,
                              min: 0,
                              max: 5,
                              divisions: 5,
                              label: _rating.toStringAsFixed(0),
                              onChanged: (v) => setState(() => _rating = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_rating.toStringAsFixed(0)} ★',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SwitchListTile(
                      value: _onlyAvailable,
                      onChanged: (v) => setState(() => _onlyAvailable = v),
                      title: Text(
                        'Only available doctors',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applying ? null : _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _applying
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Apply',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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