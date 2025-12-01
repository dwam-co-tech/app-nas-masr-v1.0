import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnifiedDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> attributes;
  final String? mainSection;
  final String? subSection;

  const UnifiedDetailsPanel(
      {super.key, required this.attributes, this.mainSection, this.subSection});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Extract Data
    // Extract Data
    final subCategory =
        subSection ?? attributes['sub_category']?.toString() ?? 'غير محدد';
    final mainCategory =
        mainSection ?? attributes['main_category']?.toString() ?? 'غير محدد';

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
