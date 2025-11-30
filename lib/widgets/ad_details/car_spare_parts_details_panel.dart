// widgets/ad_details/car_spare_parts_details_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarSparePartsDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> attributes;
  const CarSparePartsDetailsPanel({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final subCategory = attributes['sub_category']?.toString() ?? '';
    final mainCategory = attributes['main_category']?.toString() ?? '';
    final make = attributes['make']?.toString() ?? '';
    final model = attributes['model']?.toString() ?? '';

    final makeModel = [make, model].where((e) => e.isNotEmpty).join(' - ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub Category
        if (subCategory.isNotEmpty)
          Text(
            subCategory,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),

        // Main Category
        if (mainCategory.isNotEmpty)
          Text(
            mainCategory,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),

        // Make - Model
        if (makeModel.isNotEmpty)
          Text(
            makeModel,
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
