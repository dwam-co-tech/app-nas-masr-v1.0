import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/providers/user_listings_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/user_listings_repository.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/main_ad_list_wrapper.dart';
import 'package:nas_masr_app/core/data/providers/favorites_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/favorites_repository.dart';

class SellerListingsScreen extends StatelessWidget {
  final int userId;
  final String? initialSlug;
  final String? sellerName;
  const SellerListingsScreen(
      {super.key, required this.userId, this.initialSlug, this.sellerName});

  // _buildBanner removed as it was unused and causing lint warnings.

  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserListingsProvider(
            repository: UserListingsRepository(),
            userId: userId,
            initialSlug: initialSlug,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FavoritesProvider(repository: FavoritesRepository()),
        ),
      ],
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
                            SizedBox(height: 2.h),
                            MainAdListWrapper(
                              categorySlug: prov.selectedSlug ?? '',
                              categoryName: prov.selectedSlug != null
                                  ? (prov.categories[prov.selectedSlug] ?? '')
                                  : 'الكل',
                              isLoading: false, // Loading handled by parent
                              adList: prov.listings,
                            ),
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
