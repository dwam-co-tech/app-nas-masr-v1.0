import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/core/data/models/premium_advertiser.dart';
import 'package:nas_masr_app/core/data/models/premium_listing_item.dart';
import 'package:nas_masr_app/screens/public/ad_details_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/widgets/price_text.dart';

// هذا هو الشكل رقم (1): الشبكة الأفقية لكروت المعلنين المميزين (للأقسام مثل العقارات والسيارات)
class GeneralGridPremiumSellersWidget extends StatelessWidget {
  final List<PremiumAdvertiser> advertisers;
  final String categorySlug;
  final String categoryName;

  const GeneralGridPremiumSellersWidget({
    super.key,
    required this.advertisers,
    required this.categorySlug,
    required this.categoryName,
  });

  // هذه دالة مُساعِدة لبناء 'قسم' واحد من إعلانات شركة مميزة (في تصميمك هي الأجزاء المتكررة)
  Widget _buildCompanyAdsSection(BuildContext context, PremiumAdvertiser adv) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. عنوان الشركة المعلنة المُميزة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                adv.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
              InkWell(
                onTap: () {
                  context.pushNamed('user_listings', extra: {
                    'userId': adv.id,
                    'sellerName': adv.name,
                    'initialSlug': categorySlug,
                  });
                },
                child: Text(
                  "عرض كل الاعلانات",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: cs.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: cs.secondary,
                    decorationThickness: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // 2. صف العرض الأفقي للإعلانات المصغرة
          SizedBox(
            height: 140.h,
            child: ListView.builder(
              itemCount: adv.listings.length,
              scrollDirection: Axis.horizontal,
              // نترك الفيزيائيات الافتراضية بدون Bounce
              reverse: false,
              padding: EdgeInsetsDirectional.zero,
              itemBuilder: (context, index) {
                final PremiumListingItem item = adv.listings[index];
                return Padding(
                  padding:
                      EdgeInsetsDirectional.only(start: index == 0 ? 0 : 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // أ- الكارد والصورة (مستخدمين Expanded عشان الـ Column يتأقلم)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdDetailsScreen(
                                  categorySlug: categorySlug,
                                  categoryName: categoryName,
                                  adId: item.id.toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 126.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CachedNetworkImage(
                                      imageUrl: item.mainImageUrl ??
                                          'assets/images/logo.png',
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Container(
                                              color: Colors.grey.shade200,
                                              child: Center(
                                                  child: Icon(Icons.error,
                                                      size: 24.sp))),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0.h,
                                    left: 0.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromRGBO(249, 250, 251, 0.54),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: PriceText(
                                        price: item.price,
                                        placeholder: '—',
                                        style: TextStyle(
                                            color: cs.secondary,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ميثود الـ Build الرئيسية للمكون بالكامل
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلنين المميزين',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 8.h),
          Builder(
            builder: (context) {
              final valid =
                  advertisers.where((a) => a.listings.isNotEmpty).toList();
              if (valid.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text('هذا الجزء خاص بالمعلنين المتميزين',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: valid
                    .map((adv) => _buildCompanyAdsSection(context, adv))
                    .toList(),
              );
            },
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
