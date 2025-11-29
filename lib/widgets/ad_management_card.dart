import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/core/theming/colors.dart';

class AdManagementCard extends StatelessWidget {
  // البيانات الأساسية المتغيرة حسب القسم
  final String title;
  final String subtitle;
  final String imageUrl;
  final String price;
  final String statusLabel; // (ستاندرد، مميز، مجاني)
  final String publishDate;
  final String expiryDate;
  final String viewsCount;

  // دالة الاستدعاء للأزرار (Actions)
  final VoidCallback onDelete;
  final VoidCallback onRenew;
  final VoidCallback onEdit;
  final VoidCallback onUpdate;

  const AdManagementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.statusLabel,
    required this.publishDate,
    required this.expiryDate,
    required this.viewsCount,
    required this.onDelete,
    required this.onRenew,
    required this.onEdit,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
     final cs = Theme.of(context).colorScheme;

    // تحديد لون الشارة بناءً على النص
    Color badgeColor = const Color(0xFFE0F2F1); // Default Light Green
    Color badgeTextColor = const Color(0xFF009688);

    if (statusLabel.contains('ستاندرد')) {
      badgeColor = ColorManager.primaryColor; // Light Orange
      badgeTextColor = ColorManager.primaryColor; // Orange
    } else if (statusLabel.contains('مجاني')) {
      badgeColor = ColorManager.primaryColor; // Light Blue
      badgeTextColor = ColorManager.primaryColor; // Blue
    } else if (statusLabel.contains('مميز') || statusLabel.contains('نشط')) {
      badgeColor = const Color(0xFFE8F5E9);
      badgeTextColor = ColorManager.primaryColor;
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // الجزء العلوي (الصورة والتفاصيل)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. قسم الصورة (يمين)
                  SizedBox(
                    width: 130.w,
                    height: 110.h,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: (imageUrl.startsWith('http'))
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                        // بادج الحالة (فوق)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ),
                        // السعر (تحت)
                        Positioned(
                          bottom: 0.h,
                          left: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.r),
                                bottomRight: Radius.circular(8.r),
                              ),
                            ),
                            child: Text(
                             " ${price} ج",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: ColorManager.secondaryColor, // برتقالي للسعر
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // 2. قسم التفاصيل (يسار)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title, // مثال: فرعي
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            subtitle, // مثال: رئيسي / تويوتا كورولا
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: cs.onSurface, // لون بترولي داكن
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildInfoRow("تاريخ النشر:", publishDate),
                          _buildInfoRow("تاريخ الانتهاء:", expiryDate),
                          SizedBox(height: 4.h),
                          Text(
                            "البحث وعدد المشاهدات ($viewsCount)",
                            style: TextStyle(
                              fontSize: 12.sp,
                               fontWeight: FontWeight.w400,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade200),

            // الجزء السفلي (الأزرار)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              child: Row(
                children: [
                  // زر تحديث (Dark Blue)
                  _buildActionButton(
                      "تحديث", ColorManager.primary_font_color , Colors.white, onUpdate),
                  SizedBox(width: 6.w),
                  // زر تعديل (Border only)
                  _buildActionButton(
                      "تعديل", Colors.white, ColorManager.primary_font_color, onEdit,
                      isOutlined: true),
                  SizedBox(width: 6.w),
                  // زر تجديد (Green)
                  _buildActionButton(
                      "تجديد", ColorManager.primaryColor, Colors.white, onRenew),
                  SizedBox(width: 6.w),
                  // زر حذف (Red)
                  _buildActionButton(
                      "حذف", const Color(0xFFD32F2F), Colors.white, onDelete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Dates
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Color.fromRGBO(1, 22, 24, 0.45)),
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
                fontSize: 12.sp,
                color: ColorManager.primaryColor), // التاريخ لونه تيل/أخضر
          ),
        ],
      ),
    );
  }

  // Helper Widget for Buttons
  Widget _buildActionButton(
      String text, Color bg, Color textCol, VoidCallback onTap,
      {bool isOutlined = false}) {
    return Expanded(
      child: SizedBox(
        height: 32.h,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: textCol,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
              side: isOutlined
                  ? const BorderSide(color: Colors.grey)
                  : BorderSide.none,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
