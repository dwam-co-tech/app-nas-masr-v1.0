// widgets/ad_details/car_details_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarDetailsPanel extends StatelessWidget {
  const CarDetailsPanel({super.key});

  Widget _buildDetailRow(BuildContext context, String label, String value, {IconData icon = Icons.info_outline}) { 
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20.sp),
          SizedBox(width: 8.w),
          Text('$label:', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المواصفات الأساسية للسيارة', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Divider(height: 20.h, thickness: 1),

          _buildDetailRow(context, 'موديل السيارة', 'توسان'), 
          _buildDetailRow(context, 'سنة الصنع', '2024', icon: Icons.calendar_month_outlined),
          _buildDetailRow(context, 'ناقل الحركة', 'أوتوماتيك'),
          _buildDetailRow(context, 'المسافة المقطوعة', '5,000 كم', icon: Icons.speed),
        ],
      ),
    );
  }
}