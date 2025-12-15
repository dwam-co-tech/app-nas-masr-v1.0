// widgets/ad_card_widget/car_spare_parts_ad_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/widgets/price_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_details_repository.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarSparePartsAdCardWidget extends StatelessWidget {
  final AdCardModel ad;
  const CarSparePartsAdCardWidget({super.key, required this.ad});

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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final repo = AdDetailsRepository();
        final details = await repo.fetchAdDetails(
            categorySlug: ad.categorySlug,
            adId: ad.id.toString(),
            token: token);
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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final repo = AdDetailsRepository();
        final details = await repo.fetchAdDetails(
            categorySlug: ad.categorySlug,
            adId: ad.id.toString(),
            token: token);
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
    final labelColor = cs.primary;

    final mainSection =
        (ad.mainSection ?? ad.attributes['main_section']?.toString() ?? '')
            .toString();
    final subSection =
        (ad.subSection ?? ad.attributes['sub_section']?.toString() ?? '')
            .toString();
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

    final gov = ad.governorate.trim().isNotEmpty
        ? ad.governorate.trim()
        : (ad.attributes['governorate']?.toString() ??
                ad.attributes['governorate_name']?.toString() ??
                '')
            .trim();
    final cty = ad.city.trim().isNotEmpty
        ? ad.city.trim()
        : (ad.attributes['city']?.toString() ??
                ad.attributes['city_name']?.toString() ??
                '')
            .trim();
    final locationText = [gov, cty].where((e) => e.isNotEmpty).join('، ');

    // Line 3: Make - Model
    // final makeModel =
    //     [make, model].where((e) => e.trim().isNotEmpty).join(' - ');

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
                  if (subSection.trim().isNotEmpty)
                    Text(
                      subSection,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16.sp),
                    ),
                  if (subSection.trim().isNotEmpty &&
                      mainSection.trim().isNotEmpty)
                    SizedBox(height: 2.h),
                  if (mainSection.trim().isNotEmpty)
                    Text(
                      mainSection,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                  if (make.trim().isNotEmpty || model.trim().isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${make.trim()}  ${model.trim()}',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 6.h),
                  if (locationText.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 16.sp, color: cs.primary),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            locationText,
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
