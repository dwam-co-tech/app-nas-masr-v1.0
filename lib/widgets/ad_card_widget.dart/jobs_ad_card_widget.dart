import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/widgets/price_text.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/favorites_provider.dart';

class JobsAdCardWidget extends StatelessWidget {
  final AdCardModel ad;

  const JobsAdCardWidget({
    super.key,
    required this.ad,
  });

  Future<void> _copyContactInfo(BuildContext context) async {
    final contactInfo = ad.attributes['contact_via']?.toString() ?? '';
    if (contactInfo.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: contactInfo));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'تم نسخ طريقة التواصل بنجاح',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _toArabicDigits(String s) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = s;
    for (var i = 0; i < en.length; i++) {
      out = out.replaceAll(en[i], ar[i]);
    }
    return out;
  }

  String _formatArabicDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString();
    final d = dt.day.toString();
    return _toArabicDigits('$y/$m/$d');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusLabel = ad.planType == 'featured'
        ? 'متميز'
        : (ad.planType == 'standard' ? 'ستاندرد' : 'مجاني');
    final labelColor = statusLabel == 'متميز' ? cs.primary : cs.primary;

    // Jobs Specific Logic:
    // Sub Category -> Specialization (Sub Section)
    final subCategory = ad.subSection ??
        ad.attributes['sub_section_id']?.toString() ?? // Fallback attempts
        ad.attributes['specialization']?.toString() ?? // Fallback legacy
        ad.attributes['sub_category']?.toString() ??
        'غير محدد';

    // Main Category -> Classification (Main Section)
    final mainCategory = ad.mainSection ??
        ad.attributes['main_section_id']?.toString() ?? // Fallback attempts
        ad.attributes['job_category']?.toString() ?? // Fallback legacy
        ad.attributes['main_category']?.toString() ??
        '';

    String createdAt = '';
    if (ad.createdAt != null) {
      createdAt = _formatArabicDate(ad.createdAt!);
    } else {
      final raw = ad.attributes['created_at']?.toString();
      if (raw != null) {
        final dt = DateTime.tryParse(raw);
        createdAt = dt != null ? _formatArabicDate(dt) : _toArabicDigits(raw);
      }
    }

    final contactText =
        ad.attributes['contact_via']?.toString() ?? 'اضغط للنسخ';

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 160.w,
              height: 140.h,
              child: Stack(
                children: [
                  // Image logic: For Jobs, we might not have a main image, so show placeholder or category icon
                  // But layout requires an image area. Use standard component logic.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: ad.mainImageUrl ??
                            'https://via.placeholder.com/600x400/94A5A2/FFFFFF?text=وظائف',
                        fit: BoxFit.contain,
                        width: 160.w,
                        height: 140.h,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.h,
                    right: 0.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favProvider, child) {
                        final isFav = favProvider.isFavorite(ad.id);
                        return InkWell(
                          onTap: () async {
                            final wasFav = favProvider.isFavorite(ad.id);
                            await favProvider.toggle(ad.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    wasFav
                                        ? 'تم الحذف من المفضلة'
                                        : 'تم الإضافة للمفضلة',
                                    style: TextStyle(fontFamily: 'Tajawal'),
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                backgroundColor:
                                    wasFav ? Colors.grey.shade800 : cs.primary,
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : cs.secondary,
                              size: 20.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Price Logic (Salary) - Hide if redundant or keep?
                  // User layout showed a price (Salary). Let's keep it.
                  if (ad.categorySlug != 'missing' &&
                      ad.price != null) // Keep simple check
                    Positioned(
                      bottom: 0.h,
                      left: 0.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8)),
                        ),
                        child: PriceText(
                          price: ad.price, // This will be Salary
                          currencySuffix: 'ج', // Or generic?
                          style: TextStyle(
                            color: cs.secondary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategory,
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    mainCategory,
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 16.sp, color: cs.primary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${ad.governorate}، ${ad.city}',
                          style: TextStyle(
                              color: Color.fromRGBO(1, 22, 24, 0.45),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  if (createdAt.isNotEmpty)
                    Text(
                      createdAt,
                      style: TextStyle(
                          color: cs.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  SizedBox(height: 8.h),
                  // Custom Footer for Jobs: Copy Contact Info
                  InkWell(
                    onTap: () => _copyContactInfo(context),
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF0F4C5C), // Dark Teal like color from image/theme
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          contactText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
