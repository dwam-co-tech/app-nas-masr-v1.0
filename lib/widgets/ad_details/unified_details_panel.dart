import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnifiedDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> attributes;

  const UnifiedDetailsPanel({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Extract Data
    final subCategory = attributes['sub_category']?.toString() ?? 'غير محدد';
    final mainCategory = attributes['main_category']?.toString() ?? 'غير محدد';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub Category (Prominent, like Property Type)
        Text(subCategory,
            style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: cs.onSurface)),

        // Main Category (Secondary, like Contract Type)
        Text(mainCategory,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: cs.onSurface)),
      ],
    );
  }
}
