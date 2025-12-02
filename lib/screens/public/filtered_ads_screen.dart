// screens/filtered_ads_screen.dart (Final Safety Build)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:nas_masr_app/widgets/search_control_widget.dart';

import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/governorate.dart';
import 'package:nas_masr_app/core/data/models/city.dart';
import 'package:nas_masr_app/core/data/reposetory/filter_repository.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/main_ad_list_wrapper.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';
import 'package:nas_masr_app/core/data/providers/ad_search_provider.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/widgets/filter_widgets/real_estate_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/car_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/unified_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/car_rental_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/car_spare_parts_filters_widget.dart';
import 'package:nas_masr_app/widgets/filter_widgets/doctors_filters_widget.dart';
import 'package:nas_masr_app/core/constatants/unified_categories.dart';
import 'package:nas_masr_app/core/data/models/main_section.dart';
import 'package:nas_masr_app/core/data/models/sub_section.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class FilteredAdsScreen extends StatefulWidget {
  final String categorySlug;
  final String categoryName;
  final Map<String, dynamic> currentFilters;

  const FilteredAdsScreen({
    super.key,
    required this.categorySlug,
    required this.categoryName,
    required this.currentFilters,
  });

  @override
  State<FilteredAdsScreen> createState() => _FilteredAdsScreenState();
}

class _FilteredAdsScreenState extends State<FilteredAdsScreen> {
  CategoryFieldsResponse? _config;
  Map<String, dynamic> _selected = {};
  int _adsCount = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _selected = Map<String, dynamic>.from(widget.currentFilters);
    _loadConfig();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final repo = CategoryRepository();
    final cfg = await repo.getCategoryFields(widget.categorySlug);
    if (!mounted) return;
    setState(() {
      _config = cfg;
    });
  }

  Map<String, dynamic> _normalizeFilters(Map<String, dynamic> f) {
    final m = <String, dynamic>{};
    f.forEach((k, v) {
      switch (k) {
        case 'governorate_id':
        case 'governorate':
          m['governorate'] = v;
          break;
        case 'city_id':
        case 'city':
          m['city'] = v;
          break;
        case 'make_id':
        case 'make':
          m['make'] = v;
          break;
        case 'model_id':
        case 'model':
          m['model'] = v;
          break;
        default:
          m[k] = v;
      }
    });
    return m;
  }

  String _providerKeyFor(String key) {
    switch (key) {
      case 'governorate':
        return 'governorate_id';
      case 'city':
        return 'city_id';
      case 'make_id':
        return 'make';
      case 'model_id':
        return 'model';
      default:
        return key;
    }
  }

  CategoryFieldConfig? _getCustomField(String fieldName) {
    try {
      return _config?.categoryFields
          .firstWhere((f) => f.fieldName == fieldName);
    } catch (_) {
      return null;
    }
  }

  void _openFilterModal(String filterKey, String label, List<dynamic> options) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        return FractionallySizedBox(
          heightFactor: keyboardOpen ? 1 : 0.7,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: FilterOptionsModal(
              title: 'اختر $label',
              options: options,
              showAllOption: true,
              onSelected: (selectedValue) {
                final provider = Provider.of<CategoryListingProvider>(context,
                    listen: false);
                final adProvider =
                    Provider.of<AdSearchProvider>(context, listen: false);
                if (selectedValue == '__RESET__') {
                  provider.clearFilter(filterKey);
                  setState(() {
                    _selected.remove(filterKey);
                    if (filterKey == 'make') _selected.remove('model');
                    _performSearch(adProvider);
                  });
                  return;
                }
                if (selectedValue == '__ALL__') {
                  provider.setFilter(filterKey, 'الكل');
                  setState(() {
                    _selected.remove(filterKey);
                    if (filterKey == 'make') _selected.remove('model');
                    _performSearch(adProvider);
                  });
                  return;
                }
                final String val = (selectedValue is Governorate ||
                        selectedValue is City ||
                        selectedValue is MainSection ||
                        selectedValue is SubSection)
                    ? selectedValue.name
                    : selectedValue.toString();
                setState(() {
                  _selected[filterKey] = val;
                  if (filterKey == 'make') {
                    _selected.remove('model');
                  }
                  _performSearch(adProvider);
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
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
            title: Text(widget.categoryName,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700))),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
        body: SafeArea(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => CategoryListingProvider(
                  repository: CategoryRepository() as dynamic,
                  categorySlug: widget.categorySlug,
                  categoryName: widget.categoryName,
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => AdSearchProvider(),
              ),
            ],
            child: Consumer2<CategoryListingProvider, AdSearchProvider>(
              builder: (context, catProvider, adProvider, child) {
                final cfg = catProvider.fieldsConfig;

                // Initial Load
                if (cfg != null &&
                    _selected.isNotEmpty &&
                    adProvider.ads.isEmpty &&
                    !adProvider.loading &&
                    adProvider.error == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _selected.forEach((key, value) {
                      final k = _providerKeyFor(key);
                      if (!catProvider.isFilterSelected(k)) {
                        catProvider.setFilter(k, value.toString());
                      }
                    });
                    _performSearch(adProvider);
                  });
                } else if (adProvider.ads.isEmpty &&
                    !adProvider.loading &&
                    adProvider.error == null) {
                  // Trigger search if no ads and not loading (first run)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _performSearch(adProvider);
                  });
                }

                void performFilterChange(
                    String filterKey, dynamic selectedValue) {
                  if (selectedValue == '__RESET__') {
                    catProvider.clearFilter(filterKey);
                    setState(() {
                      _selected.remove(filterKey);
                      if (filterKey == 'make') _selected.remove('model');
                      _performSearch(adProvider);
                    });
                    return;
                  }
                  if (selectedValue == '__ALL__') {
                    catProvider.setFilter(filterKey, 'الكل');
                    setState(() {
                      _selected.remove(filterKey);
                      if (filterKey == 'make') _selected.remove('model');
                      _performSearch(adProvider);
                    });
                    return;
                  }
                  final String val = (selectedValue is Governorate ||
                          selectedValue is City ||
                          selectedValue is MainSection ||
                          selectedValue is SubSection)
                      ? selectedValue.name
                      : selectedValue.toString();
                  catProvider.setFilter(filterKey, val);
                  setState(() {
                    _selected[filterKey] = val;
                    if (filterKey == 'make') _selected.remove('model');
                    _performSearch(adProvider);
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (cfg != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.w),
                        child: _selectFiltersWidget(context,
                            widget.categorySlug, cfg, performFilterChange),
                      ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (adProvider.loading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (adProvider.error != null) {
                            return Center(
                                child: Text('خطأ: ${adProvider.error}'));
                          }
                          final ads = adProvider.ads;
                          _adsCount = ads.length;
                          if (ads.isEmpty) {
                            return const Center(child: Text('لا توجد نتائج'));
                          }
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SearchControlWidget(
                                  totalAdsCount: _adsCount,
                                  showPriceToggle: true,
                                  showDistanceToggle: true,
                                  isSortByNearest: adProvider.sortByNearest,
                                  isSortByPrice: adProvider.sortByPrice,
                                  onToggleChanged: (key, value) {
                                    if (key == 'sort_distance') {
                                      adProvider.toggleSortByNearest();
                                    } else if (key == 'sort_price') {
                                      adProvider.toggleSortByPrice();
                                    }
                                  },
                                ),
                                MainAdListWrapper(
                                  categorySlug: widget.categorySlug,
                                  categoryName: widget.categoryName,
                                  isLoading: false,
                                  adList: ads,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performSearch(AdSearchProvider provider) async {
    final mapped = _normalizeFilters(_selected);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    provider.performSearch(
        categorySlug: widget.categorySlug, filters: mapped, token: token);
  }

  Widget _selectFiltersWidget(BuildContext context, String slug,
      CategoryFieldsResponse config, Function(String, dynamic) onAction) {
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
      case 'doctors':
        return DoctorsFiltersWidget(
          config: config,
          onNavigate: onAction,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
