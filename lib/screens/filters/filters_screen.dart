import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
