import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/widgets/price_text.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/favorites_provider.dart';

class FavoriteCardWidget extends StatelessWidget {
  final AdCardModel ad;
  final VoidCallback? onTap;
  const FavoriteCardWidget({super.key, required this.ad, this.onTap});

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
    String createdAt = '';
    if (ad.createdAt != null) {
      createdAt = _formatArabicDate(ad.createdAt!);
    }
    final desc = ad.attributes['description']?.toString() ?? '';
    final statusLabel = ad.planType == 'featured'
        ? 'متميز'
        : (ad.planType == 'standard' ? 'ستاندرد' : 'مجاني');

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150.w,
                height: 130.h,
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
                          width: 150.w,
                          height: 150.h,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.h,
                      right: 0.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(7),
                              bottomLeft: Radius.circular(8)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: InkWell(
                        onTap: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              final cs2 = Theme.of(ctx).colorScheme;
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  title: const Text('تأكيد',
                                      textAlign: TextAlign.right),
                                  content: const Text(
                                      'هل تريد إزالة الإعلان من المفضلة؟',
                                      textAlign: TextAlign.right),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text('إلغاء',
                                          style:
                                              TextStyle(color: cs2.onSurface)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: cs2.primary),
                                      child: const Text('تأكيد'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          if (ok == true) {
                            final success = await context
                                .read<FavoritesProvider>()
                                .remove(ad.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                          success
                                              ? 'تم الإزالة من المفضلة'
                                              : 'تعذر الإزالة من المفضلة',
                                          textAlign: TextAlign.right))),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(15.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(Icons.favorite_rounded,
                              color: cs.secondary, size: 20.sp),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.h,
                      left: 0.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
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
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50.h,
                      child: Text(
                        desc,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 18.sp, color: cs.primary),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            '${ad.governorate}، ${ad.city}',
                            style: TextStyle(
                              color: const Color.fromRGBO(1, 22, 24, 0.45),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    if (createdAt.isNotEmpty)
                      Text(
                        createdAt,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
