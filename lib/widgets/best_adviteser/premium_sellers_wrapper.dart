import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/widgets/best_adviteser/general_grid_premium_sellers.dart';
import 'package:nas_masr_app/core/data/models/premium_advertiser.dart';
import 'package:shimmer/shimmer.dart';
// المكونات الفرعية: (سيبني هذا الجزء بنفسه عند اللزوم)

// ======== كود Placeholders للمكونات التي لم تُبنى بعد (Doctors/Teachers) =========

class DoctorPremiumSellersWidget extends StatelessWidget {
  const DoctorPremiumSellersWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        color: Colors.blue.withOpacity(0.05),
        child: Center(
            child: Text(
                'هنا سيكون شكل القائمة الرأسية للأطباء/المعلمين (الشكل رقم 2)',
                style: TextStyle(fontSize: 16.sp))));
  }
}

class DefaultPremiumSellersWidget extends StatelessWidget {
  const DefaultPremiumSellersWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 150.h,
        color: Colors.grey.shade100,
        child: Center(child: Text('Placeholder للعرض الافتراضي')));
  }
}

// =========================================================================

class PremiumSellersWrapper extends StatelessWidget {
  final String categorySlug;
  final bool isLoading;
  final List<PremiumAdvertiser> advertisers;
  final String categoryName;

  const PremiumSellersWrapper({
    super.key,
    required this.categorySlug,
    required this.isLoading,
    required this.advertisers,
    required this.categoryName,
  });

  // هذه الدالة السحرية هي التي تختار الـ Widget الفعلي بناءً على الـ slug
  Widget _selectCategoryWidget(String slug) {
    // 1. تحديد Slugs التي تستخدم نمط Grid (النمط الذي بنيناه: العقارات/السيارات)
    final List<String> gridSlugs = [
      'cars',
      'car-rental',
      'real_estate',
    ];

    if (gridSlugs.contains(slug)) {
      return GeneralGridPremiumSellersWidget(
        advertisers: advertisers,
        categorySlug: categorySlug,
        categoryName: categoryName,
      );
    } else if (slug == 'doctors' || slug == 'teachers') {
      // 2. النمط الرأسي (لم يُبنى بعد)
      return const DoctorPremiumSellersWidget();
    } else {
      // 3. النمط الافتراضي لأي شيء آخر (شكل عام)
      return const DefaultPremiumSellersWidget();
    }
  }

  // هذه الدالة ترسم الـ Placeholder بنمط الشيمر لملء الشاشة بشكل فوري (لتجنب المساحات البيضاء)
  Widget _buildLoadingShimmer(BuildContext context, String slug) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 150.w,
                height: 16.h,
                color: Colors.white), // Placeholder Title
            SizedBox(height: 12.h),
            SizedBox(
              height: 180.h, // ارتفاع موحد للجزء الأفقي
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 130.w,
                            height: 130.h,
                            color: Colors.white), // Placeholder Card
                        SizedBox(height: 4.h),
                        Container(
                            width: 80.w,
                            height: 12.h,
                            color: Colors.white), // Placeholder Price
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // إدارة التحميل (Loading State Management)
    if (isLoading) {
      return _buildLoadingShimmer(context, categorySlug);
    }

    // إدارة عرض المحتوى (Content Switching)
    return _selectCategoryWidget(categorySlug);
  }
}
