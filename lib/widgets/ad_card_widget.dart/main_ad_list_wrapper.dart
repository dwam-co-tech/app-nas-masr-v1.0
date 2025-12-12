// widgets/ad_list/main_ad_list_wrapper.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/real_estate_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/car_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/unified_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/car_rental_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/car_spare_parts_ad_card_widget.dart';
import 'package:nas_masr_app/core/constatants/unified_categories.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/screens/public/ad_details_screen.dart';
import 'package:go_router/go_router.dart';

// ============ المكونات الفرعية (هيكل UI مُختلف) ============= //

import 'package:nas_masr_app/widgets/ad_card_widget.dart/service_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/jobs_ad_card_widget.dart';

// ============================================================== //

class MainAdListWrapper extends StatelessWidget {
  final String categorySlug;
  final String categoryName;
  final bool isLoading;
  final List<AdCardModel> adList;

  const MainAdListWrapper({
    super.key,
    required this.categorySlug,
    required this.categoryName,
    required this.isLoading,
    required this.adList,
  });

  Widget _selectAdCardWidget(String slug, AdCardModel ad) {
    // Use ad.categorySlug as the primary source of truth for the card type
    final targetSlug = ad.categorySlug.isNotEmpty ? ad.categorySlug : slug;

    if (UnifiedCategories.slugs.contains(targetSlug)) {
      return UnifiedAdCardWidget(ad: ad);
    }
    switch (targetSlug) {
      case 'real_estate':
        return RealEstateAdCardWidget(ad: ad);
      case 'cars':
        return CarAdCardWidget(ad: ad);
      case 'cars_rent':
        return CarRentalAdCardWidget(ad: ad);
      case 'spare-parts':
        return CarSparePartsAdCardWidget(ad: ad);
      case 'teachers':
        return UnifiedAdCardWidget(ad: ad);
      case 'doctors':
        return UnifiedAdCardWidget(ad: ad);
      case 'jobs':
        return JobsAdCardWidget(ad: ad);
      default:
        return UnifiedAdCardWidget(ad: ad);
    }
  }

  // الـ Placeholder/Shimmer لتمثيل التحميل
  Widget _buildLoadingShimmer() {
    // سنستخدم Shimmer اللي يتناسب مع Car Ad Card (كأغلبية)
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              height: 120.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingShimmer();
    }
    if (adList.isEmpty) {
      return const Center(child: Text('لا توجد إعلانات مطابقة للبحث.'));
    }
    final Map<String, List<AdCardModel>> grouped = {
      'featured': <AdCardModel>[],
      'standard': <AdCardModel>[],
      'free': <AdCardModel>[],
    };
    for (final ad in adList) {
      final k = (ad.planType == 'featured' || ad.planType == 'standard')
          ? ad.planType
          : 'free';
      grouped[k]!.add(ad);
    }

    final List<dynamic> items = [];
    String _title(String k) {
      switch (k) {
        case 'featured':
          return 'إعلانات مميزة';
        case 'standard':
          return 'إعلانات ستاندرد';
        default:
          return 'إعلانات مجانية';
      }
    }

    for (final k in ['featured', 'standard', 'free']) {
      final list = grouped[k]!;
      if (list.isNotEmpty) {
        items.add({'header': _title(k)});
        items.addAll(list);
      }
    }

    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];
        if (it is Map && it.containsKey('header')) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              it['header'] as String,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface),
            ),
          );
        }
        final ad = it as AdCardModel;
        return InkWell(
          onTap: () {
            context.push('/ad/details', extra: {
              'categorySlug': categorySlug,
              'categoryName': categoryName,
              'adId': ad.id.toString(),
            });
          },
          child: _selectAdCardWidget(categorySlug, ad),
        );
      },
    );
  }
}
