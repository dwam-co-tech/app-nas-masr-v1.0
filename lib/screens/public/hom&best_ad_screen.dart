// screens/category_listing_screen.dart (الحل النهائي لـ "Undefined name 'provider'")

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/city.dart';
import 'package:nas_masr_app/core/data/models/governorate.dart';
import 'package:nas_masr_app/core/data/providers/best_advertisers_provider.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/best_advertisers_repository.dart';
import 'package:nas_masr_app/core/data/reposetory/filter_repository.dart';
import 'package:nas_masr_app/screens/public/filtered_ads_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/widgets/best_adviteser/premium_sellers_wrapper.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:nas_masr_app/widgets/filter_widgets/car_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/real_estate_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/unified_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/car_rental_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/car_spare_parts_filters_widget.dart';
import 'package:nas_masr_app/core/constatants/unified_categories.dart';
import 'package:nas_masr_app/widgets/search_control_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class CategoryListingScreen extends StatelessWidget {
  final String categorySlug;
  final String categoryName;

  const CategoryListingScreen({
    super.key,
    required this.categorySlug,
    required this.categoryName,
  });

  // هذه الدالة تم اختزالها لتكون داخل الـ Consumer Body
  // هذا فقط الجزء اللي بيختار الـ Widget (تم تغيير اسمه)
  Widget _selectFiltersWidget(BuildContext context, String slug,
      CategoryFieldsResponse? config, Function(String, dynamic) onAction) {
    if (config == null) return const SizedBox.shrink();

    if (UnifiedCategories.slugs.contains(slug)) {
      return UnifiedFiltersWidget(
        config: config,
        onNavigate: onAction,
      );
    }

    switch (slug) {
      case 'cars':
        return CarFiltersWidget(
          config: config,
          onNavigate: onAction,
        );
      case 'cars_rent':
        return CarRentalFiltersWidget(
          config: config,
          onNavigate: onAction,
        );
      case 'spare-parts':
        return CarSparePartsFiltersWidget(
          config: config,
          onNavigate: onAction,
        );

      case 'real_estate':
      case '3aqarat':
        return RealEstateFiltersWidget(
          config: config,
          onNavigate: onAction,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 1. تثبيت الـ Provider
    return ChangeNotifierProvider(
      create: (context) => CategoryListingProvider(
        // ... (الـ Constructor)
        repository:
            CategoryRepository() as dynamic, // تم تعديله للـ Logic الجديد
        categorySlug: categorySlug,
        categoryName: categoryName,
      ),
      // 2. استخدام الـ Consumer لقراءة الحالة
      child: Consumer<CategoryListingProvider>(
        builder: (context, provider, child) {
          final config = provider.fieldsConfig;
          final isScreenLoading = provider.isLoading;

          // >>> الآن نعرف الدالة بداخل الـ Consumer لتجنب خطأ الـ Scope <<<
          void performFilterAndNavigate(
              String filterKey, dynamic selectedValue) async {
            if (selectedValue == '__RESET__') {
              provider.clearFilter(filterKey);
              return;
            }
            final bool isAll = selectedValue == '__ALL__';
            final String selectedName = isAll
                ? 'الكل'
                : (selectedValue is Governorate
                    ? selectedValue.name
                    : selectedValue.toString());
            final Map<String, dynamic> filtersMap = {};
            if (!isAll) {
              filtersMap[filterKey] =
                  selectedValue is Governorate || selectedValue is City
                      ? selectedValue.name
                      : selectedValue.toString();
            }
            provider.setFilter(filterKey, selectedName);

            await context.push('/ads/filtered', extra: {
              'categorySlug': provider.categorySlug,
              'categoryName': provider.categoryName,
              'currentFilters': filtersMap,
            });
            provider.clearAllFilters();
          }

          // Logic تحديد ظهور التبديلات (Toggles)
          final bool showPrice = (config != null)
              ? !config.categoryFields.any((f) => f.fieldName == 'salary_range')
              : true;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.onSurface),
                    onPressed: () => context.pop(),
                  ),
                  notificationPredicate: (notification) =>
                      notification is! ScrollNotification,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: InkWell(
                        onTap: () => context.pushNamed('notifications'),
                        child: Icon(Icons.notifications_rounded,
                            color: cs.onSurface, size: isLand ? 15.sp : 30.sp),
                      ),
                    ),
                  ],
                  title: Text(provider.categoryName,
                      style: TextStyle(color: cs.onSurface))),
              bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
              body: SafeArea(
                child: isScreenLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? Center(
                            child: Text(
                                'خطأ في تحميل البيانات: ${provider.error!}',
                                style: const TextStyle(color: Colors.red)))
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _selectFiltersWidget(context, categorySlug,
                                    config, performFilterAndNavigate),
                                // SearchControlWidget(
                                //   totalAdsCount: 5000,
                                //   showPriceToggle: showPrice,
                                //   showDistanceToggle: true,
                                //   onToggleChanged: (key, value) {},
                                // ),
                                ChangeNotifierProvider(
                                  create: (_) => BestAdvertisersProvider(
                                    bestRepo: BestAdvertisersRepository(),
                                    categorySlug: categorySlug,
                                  ),
                                  child: Consumer<BestAdvertisersProvider>(
                                    builder: (context, bestProv, _) =>
                                        PremiumSellersWrapper(
                                      categorySlug: categorySlug,
                                      isLoading: bestProv.isLoading,
                                      advertisers: bestProv.advertisers,
                                      categoryName: provider.categoryName,
                                    ),
                                  ),
                                ),
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
