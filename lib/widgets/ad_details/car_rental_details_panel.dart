import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarRentalDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> attributes;
  const CarRentalDetailsPanel({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final make = attributes['make']?.toString() ?? '';
    final model = attributes['model']?.toString() ?? '';
    final year = attributes['year']?.toString() ?? '';
    final driver = attributes['driver_option']?.toString() ??
        attributes['driver']?.toString() ??
        '';

    final makeModel = [make, model].where((e) => e.isNotEmpty).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Make - Model (Like Sub Category / Property Type)
        Text(
          makeModel,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),

        // Year (Like Main Category / Contract Type)
        Text(
          year,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),

        // Driver
        if (driver.isNotEmpty)
          Text(
            driver,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
      ],
    );
  }
}
