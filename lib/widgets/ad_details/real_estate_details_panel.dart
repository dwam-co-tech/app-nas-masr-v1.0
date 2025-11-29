// widgets/ad_details/real_estate_details_panel.dart (الكود النهائي والديناميكي)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RealEstateDetailsPanel extends StatelessWidget {
  // أصبح يستقبل الخصائص المتغيرة (Attributes) كـ Map
  final Map<String, dynamic> attributes;

  const RealEstateDetailsPanel({super.key, required this.attributes});

  // هذه هي الدالة اللي بتشتغل بالـ Layout الذي ظهر في التصميم (القيمة يمين - Label يسار)
  Widget _buildPropertyRow(BuildContext context, String label) {
     final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(label,
          style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.w500, color: cs.onSurface)),
    );
  }
  

  @override
  Widget build(BuildContext context) {
     final cs = Theme.of(context).colorScheme;
  
    // 1. استخراج الـ Data الفعلية من الـ Attributes بأمان
    final propertyType = attributes['property_type']?.toString() ?? 'غير محدد';
    final contractType = attributes['contract_type']?.toString() ?? 'غير محدد';
    // ممكن يكون فيه attribute آخر يمثل الـ Status القانوني مثلاً

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(propertyType,
          style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.w500, color: cs.onSurface)),
  
 Text(contractType,
          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w500, color: cs.onSurface)),
  
       
      ],
    );
  }
}
