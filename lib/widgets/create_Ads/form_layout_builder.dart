// widgets/form_layout_builder.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// دالة تفيد في تجميع الـ Widgets في Layout (هذا يوفر عليكِ كتابة Row متكررة)
// تأخذ قائمة Widgets وتقسمهم لصفوف بناءً على العدد المُحدد
Widget build2ColFormLayout(List<Widget> widgets, {int columns = 2, double horizontalSpacing = 8.0, double verticalSpacing = 8.0}) {
  List<Widget> rows = [];
  
  // تقسيم الـ List إلى صفوف بناءً على عدد الأعمدة (عادة 2 أو 3)
  for (int i = 0; i < widgets.length; i += columns) {
    List<Widget> rowChildren = [];
    
    for (int j = 0; j < columns; j++) {
      int index = i + j;
      if (index < widgets.length) {
        // نضع الـ Widget في Expanded ليأخذ نفس المساحة في الـ Row
        rowChildren.add(
          Expanded(
            child: widgets[index],
          )
        );
      } else {
        // نضع Spacer لضمان أن آخر Row لديه 2 Column (لو كانت فردية)
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }
      
      // نضيف مسافة بينية بين الأعمدة
      if (j < columns - 1) {
        rowChildren.add(SizedBox(width: horizontalSpacing.w));
      }
    }
    
    rows.add(
      Padding(
        padding: EdgeInsets.only(bottom: verticalSpacing.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      ),
    );
  }
  
  return Column(children: rows);
}