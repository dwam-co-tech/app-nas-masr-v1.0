// widgets/ad_list/real_estate_ad_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:url_launcher/url_launcher.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_details_repository.dart';
import 'package:nas_masr_app/widgets/price_text.dart';

// هذا الكارد خاص بـ "العقارات" ويغطي أقسام الـ List الأساسية
class RealEstateAdCardWidget extends StatelessWidget {
  final AdCardModel ad;

  const RealEstateAdCardWidget({
    super.key,
    required this.ad,
  });

  // دالة مساعدة لعمل الزرار الأخضر والأسود
  Widget _buildActionButton(
      BuildContext context, String text, IconData icon, Color backgroundColor,
      {VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: EdgeInsets.symmetric(vertical: 0.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
            elevation: 0,
          ),
          // icon: Icon(icon, size: 16.sp, color: Colors.white),
          label: Text(text,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }

  Future<void> _launchWhatsAppFromCard(BuildContext context) async {
    String? number = ad.attributes['whatsapp_phone']?.toString();
    number ??= ad.attributes['contact_phone']?.toString();
    if (number == null || number.isEmpty) {
      try {
        final repo = AdDetailsRepository();
        final details = await repo.fetchAdDetails(
            categorySlug: ad.categorySlug, adId: ad.id.toString());
        number = details.whatsappPhone ?? details.contactPhone;
      } catch (_) {}
    }
    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text('تعذر الحصول على رقم المعلن',
                textAlign: TextAlign.right),
          ),
        ),
      );
      return;
    }
    var sanitized = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.startsWith('00')) {
      sanitized = sanitized.substring(2);
    }
    String normalized = sanitized;
    if (sanitized.startsWith('0') && !sanitized.startsWith('20')) {
      normalized = '20${sanitized.substring(1)}';
    }
    final encodedText = Uri.encodeComponent('مرحبا!');
    final deepNoPlus =
        Uri.parse('whatsapp://send?phone=$normalized&text=$encodedText');
    final deepPlus =
        Uri.parse('whatsapp://send?phone=%2B$normalized&text=$encodedText');
    final waUri = Uri.parse('https://wa.me/$normalized?text=$encodedText');
    final apiUri = Uri.parse(
        'https://api.whatsapp.com/send?phone=$normalized&text=$encodedText');

    try {
      if (foundation.kIsWeb) {
        final ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        if (ok) return;
        final okWeb = await launchUrl(
          apiUri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration:
              const WebViewConfiguration(enableJavaScript: true),
        );
        if (!okWeb) throw Exception('No handler');
        return;
      } else {
        var ok =
            await launchUrl(deepNoPlus, mode: LaunchMode.externalApplication);
        if (ok) return;
        ok = await launchUrl(deepPlus, mode: LaunchMode.externalApplication);
        if (ok) return;
        ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        if (ok) return;
        ok = await launchUrl(apiUri, mode: LaunchMode.externalApplication);
        if (ok) return;
        final okWebView = await launchUrl(
          apiUri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration:
              const WebViewConfiguration(enableJavaScript: true),
        );
        if (!okWebView) throw Exception('No handler');
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text('تعذر فتح واتساب', textAlign: TextAlign.right),
          ),
        ),
      );
    }
  }

  Future<void> _launchPhoneFromCard(BuildContext context) async {
    String? number = ad.attributes['contact_phone']?.toString();
    number ??= ad.attributes['whatsapp_phone']?.toString();
    if (number == null || number.isEmpty) {
      try {
        final repo = AdDetailsRepository();
        final details = await repo.fetchAdDetails(
            categorySlug: ad.categorySlug, adId: ad.id.toString());
        number = details.contactPhone;
        number ??= details.whatsappPhone;
      } catch (_) {}
    }
    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text('تعذر الحصول على رقم المعلن',
                textAlign: TextAlign.right),
          ),
        ),
      );
      return;
    }
    var sanitized = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.startsWith('00')) {
      sanitized = sanitized.substring(2);
    }
    String normalized = sanitized;
    if (sanitized.startsWith('0') && !sanitized.startsWith('20')) {
      normalized = '20${sanitized.substring(1)}';
    }
    final telUri = Uri.parse('tel:+$normalized');
    try {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text('تعذر إجراء الاتصال', textAlign: TextAlign.right),
          ),
        ),
      );
    }
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
        ? 'مميز'
        : (ad.planType == 'standard' ? 'ستاندرد' : 'مجاني');
    final labelColor = statusLabel == 'متميز'
        ? cs.primary
        : cs.primary;
    final propertyType =
        ad.attributes['property_type']?.toString() ?? 'غير محدد';
    final contractType = ad.attributes['contract_type']?.toString() ?? '';
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      color: Colors.grey.shade300,
                      child: CachedNetworkImage(
                        imageUrl: ad.mainImageUrl ??
                            'https://via.placeholder.com/600x400/94A5A2/FFFFFF?text=ناص',
                        fit: BoxFit.cover,
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
                        // border: Border.all(color: labelColor.withOpacity(0.4)),
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
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        // border: Border.all(color: labelColor.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.favorite_border,
                          color: cs.secondary, size: 20.sp),
                    ),
                  ),
                  Positioned(
                    bottom: 0.h,
                    left: 0.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                        // border: Border.all(color: labelColor.withOpacity(0.4)),
                      ),
                      child: PriceText(
                        price: ad.price,
                        currencySuffix: 'ج',
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
                    propertyType,
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    contractType,
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
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _buildActionButton(context, 'اتصال',
                          Icons.chat_bubble_outline, cs.onSurface,
                          onPressed: () => _launchPhoneFromCard(context)),
                      _buildActionButton(
                          context, 'واتساب', Icons.phone_outlined, cs.primary,
                          onPressed: () => _launchWhatsAppFromCard(context)),
                    ],
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
