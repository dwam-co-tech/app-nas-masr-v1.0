import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:nas_masr_app/core/data/providers/user_listings_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/user_listings_repository.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';

import 'package:nas_masr_app/widgets/ad_card_widget.dart/car_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/car_rental_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/car_spare_parts_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/real_estate_ad_card_widget.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/unified_ad_card_widget.dart';

class SellerListingsScreen extends StatelessWidget {
  final int userId;
  final String? initialSlug;
  final String? sellerName;
  const SellerListingsScreen(
      {super.key, required this.userId, this.initialSlug, this.sellerName});

  Widget _buildBanner(BuildContext context, UserListingsProvider prov) {
    final cs = Theme.of(context).colorScheme;
    final url = prov.bannerUrl;
    return ClipRRect(
      child: SizedBox(
        width: double.infinity,
        height: 180.h,
        child: url == null || url.isEmpty
            ? Transform.scale(
                scale: 2,
                child: Container(color: cs.surface),
              )
            : Transform.scale(
                scale: 1.05,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, _) =>
                      Container(color: const Color(0xFFF0F2F5)),
                  errorWidget: (context, _, __) => Container(
                    color: const Color(0xFFF0F2F5),
                    child: Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.grey.shade400, size: 28.sp),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCardByCategory(AdCardModel ad) {
    switch (ad.categorySlug) {
      case 'cars':
        return CarAdCardWidget(ad: ad);
      case 'cars_rent':
        return CarRentalAdCardWidget(ad: ad);
      case 'spare-parts':
        return CarSparePartsAdCardWidget(ad: ad);
      case 'real_estate':
        return RealEstateAdCardWidget(ad: ad);
      default:
        return UnifiedAdCardWidget(ad: ad);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (context) => UserListingsProvider(
        repository: UserListingsRepository(),
        userId: userId,
        initialSlug: initialSlug,
      ),
      child: Consumer<UserListingsProvider>(
        builder: (context, prov, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
                bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(Icons.notifications_rounded,
                        color: cs.onSurface, size: isLand ? 15.sp : 30.sp),
                  ),
                ],
                title: Text('جميع اعلانات المعلن',
                    style: TextStyle(color: cs.onSurface)),
              ),
              body: prov.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                            //   child: _buildBanner(context, prov),
                            // ),
                            // SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Text(
                                sellerName ?? 'المعلن',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Builder(builder: (context) {
                                      final allSelected =
                                          prov.selectedSlug == null ||
                                              prov.selectedSlug!.isEmpty;
                                      return ChoiceChip(
                                        label: Text(
                                          'الكل',
                                          style: TextStyle(
                                            color: allSelected
                                                ? Colors.white
                                                : cs.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        selected: allSelected,
                                        onSelected: (_) =>
                                            prov.selectCategory(null),
                                        selectedColor: cs.primary,
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color:
                                                cs.onSurface.withOpacity(0.12)),
                                        labelPadding: EdgeInsets.symmetric(
                                            horizontal: 15.w, vertical: 1.h),
                                      );
                                    }),
                                    SizedBox(width: 8.w),
                                    ...prov.categories.entries.map((e) {
                                      final selected =
                                          prov.selectedSlug == e.key;
                                      return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            end: 8.w),
                                        child: ChoiceChip(
                                          label: Text(
                                            e.value,
                                            style: TextStyle(
                                              color: selected
                                                  ? Colors.white
                                                  : cs.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          selected: selected,
                                          onSelected: (_) =>
                                              prov.selectCategory(e.key),
                                          selectedColor: cs.primary,
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                              color: cs.onSurface
                                                  .withOpacity(0.12)),
                                          labelPadding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 1.h),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            ...prov.listings
                                .map((ad) => GestureDetector(
                                      onTap: () {
                                        context.pushNamed('ad_details', extra: {
                                          'categorySlug': ad.categorySlug,
                                          'categoryName': ad.categoryName,
                                          'adId': ad.id.toString(),
                                        });
                                      },
                                      child: _buildCardByCategory(ad),
                                    ))
                                .toList(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
