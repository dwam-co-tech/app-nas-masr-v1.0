import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/widgets/price_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_details_repository.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';

class CarAdCardWidget extends StatelessWidget {
  final AdCardModel ad;
  const CarAdCardWidget({super.key, required this.ad});

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
        const SnackBar(content: Text('تعذر الحصول على رقم المعلن')),
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
      var ok =
          await launchUrl(deepNoPlus, mode: LaunchMode.externalApplication);
      if (ok) return;
      ok = await launchUrl(deepPlus, mode: LaunchMode.externalApplication);
      if (ok) return;
      ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
      if (ok) return;
      ok = await launchUrl(apiUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذر فتح واتساب')));
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
          const SnackBar(content: Text('تعذر الحصول على رقم المعلن')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تعذر إجراء الاتصال')));
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

  String _toEnglishDigits(String s) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var out = s;
    for (var i = 0; i < en.length; i++) {
      out = out.replaceAll(ar[i], en[i]);
      out = out.replaceAll(fa[i], en[i]);
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
        ? " متميز"
        : (ad.planType == 'standard' ? 'ستاندرد' : 'مجاني');
    final labelColor = cs.primary;

    final make = (ad.make ??
            ad.attributes['make']?.toString() ??
            ad.attributes['car_make']?.toString() ??
            '')
        .toString();
    final model = (ad.model ??
            ad.attributes['model']?.toString() ??
            ad.attributes['car_model']?.toString() ??
            '')
        .toString();
    final year = ad.attributes['year']?.toString() ?? '';
    String kilometers = '';
    final kmRaw = ad.attributes['kilometers'];
    if (kmRaw != null) {
      kilometers = kmRaw.toString().trim();
      if (kilometers.toLowerCase() == 'null') kilometers = '';
    }

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

    final titleLine = [make, model].where((e) => e.trim().isNotEmpty).join(' ');
    final infoLineParts = <String>[];
    if (year.trim().isNotEmpty)
      infoLineParts.add(_toEnglishDigits(year.trim()));
    if (kilometers.trim().isNotEmpty) {
      final mil = kilometers.trim();
      final display = _toEnglishDigits(mil);
      infoLineParts.add('$display ك.م');
    }
    final infoLine = infoLineParts.join(' ، ');

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
                      decoration: const BoxDecoration(
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
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
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
                    titleLine,
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  if (infoLine.isNotEmpty)
                    Text(
                      infoLine,
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 14.sp),
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
                          style: const TextStyle(
                              color: Color.fromRGBO(1, 22, 24, 0.45),
                              fontSize: 14,
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
                      _buildActionButton(
                          context, 'اتصال', Icons.phone_outlined, cs.onSurface,
                          onPressed: () => _launchPhoneFromCard(context)),
                      _buildActionButton(context, 'واتساب',
                          Icons.chat_bubble_outline, cs.primary,
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
