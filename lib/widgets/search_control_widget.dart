// widgets/search_control_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // لتسهيل التحكم في الأبعاد

// هذا الـ Widget سيكون موحداً لكن يتم تمرير بيانات التحكم فيه
class SearchControlWidget extends StatelessWidget {
  final int totalAdsCount; // عدد الإعلانات الإجمالي الذي جاء من الـ API
  final bool
      showPriceToggle; // هل نظهر زرار "الأقل سعراً" (مثل قسم الخدمات والمفقودات)
  final bool
      showDistanceToggle; // هل نظهر زرار "الأقرب أولاً" (مثل الإعلانات البعيدة)

  // دالة تُستدعى لما نغيّر حالة أي مفتاح
  final Function(String key, bool value)? onToggleChanged;

  const SearchControlWidget({
    super.key,
    required this.totalAdsCount,
    this.showPriceToggle = true,
    this.showDistanceToggle = true,
    this.onToggleChanged,
  });

  // مكوّن التوجل الواحد اللي بيضم النص والـ Switch
  Widget _buildToggle(
      BuildContext context, String label, bool isShown, String key) {
    if (!isShown)
      return const SizedBox.shrink(); // لو الـ Config قال إنه مايظهرش، مانعرضوش

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // هنا يجب ان تكون القيمة الحالية لـ Switch جايالك من State
    // لكن مؤقتاً هنستخدم قيمة False افتراضية للـ Demo
    final bool currentValue = false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: Row(
        children: [
           Text(label,
              style: TextStyle(fontSize: 12.sp,fontWeight: FontWeight.w600,
                  color: cs.onSurface),),
           SizedBox(width: 8.w),
           Switch(
             activeColor: cs.primary,
            inactiveTrackColor:cs.primary,
            inactiveThumbColor: Colors.white,
            value: currentValue,
            onChanged: (v) {
              // بنبعت الإشارة للـ Provider عشان يغيّر الـ State ويبحث تاني
              if (onToggleChanged != null) {
                onToggleChanged!(key, v);
              }
            },
           // activeColor: color, // لون التبديل لما يكون شغال
            // التبديل الصغير للتصميم بتاعك
            // thumbColor: MaterialStateProperty.all(
            //     currentValue ? Colors.white : Colors.grey.shade400),
            // trackColor: MaterialStateProperty.all(
            //     currentValue ? color.withOpacity(0.8) : Colors.grey.shade200),
          ),
        
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
        fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // الأقسام زي "الأطباء" أو "المدرسين" مش هيكون عندهم Toggles عشان كده لازم يكون ده موجود
    if (!showPriceToggle && !showDistanceToggle) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عداد الإعلانات في اليسار
          Text('عدد الإعلانات: $totalAdsCount',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: cs.onSurface),
              textAlign: TextAlign.right
              ),
         // SizedBox(height: 2.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToggle(
                  context, 'الأقرب أولاً', showDistanceToggle, 'sort_distance'),
              _buildToggle(
                  context, 'الاقل سعراً أولاً', showPriceToggle, 'sort_price'),
            ],
          ),

          // عشان يبقى فاصل خفيف بين التوجل والمحتوى اللي جاي
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}
