import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/home_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/home_repository.dart';
import 'package:nas_masr_app/core/data/providers/plan_prices_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/plan_prices_repository.dart';
import 'package:nas_masr_app/core/data/models/category_home.dart' as Models;
import 'package:go_router/go_router.dart';

class SubscribePackagesScreen extends StatefulWidget {
  final String? initialSlug;
  final String? initialName;
  final int? listingId;
  const SubscribePackagesScreen(
      {super.key, this.initialSlug, this.initialName, this.listingId});
  @override
  State<SubscribePackagesScreen> createState() =>
      _SubscribePackagesScreenState();
}

class _SubscribePackagesScreenState extends State<SubscribePackagesScreen> {
  String? _selectedSlug;
  String? _selectedName;
  String _planType = 'featured';
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _selectedSlug = widget.initialSlug;
    _selectedName = widget.initialName;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final p = HomeProvider(repository: HomeRepository());
          Future.microtask(() => p.loadHome());
          return p;
        }),
        ChangeNotifierProvider(
            create: (_) =>
                PlanPricesProvider(repository: PlanPricesRepository())),
      ],
      child: Consumer2<HomeProvider, PlanPricesProvider>(
        builder: (context, home, pricesProv, _) {
          final categories = home.categories;
          final names = categories.map((c) => c.name).toList();
          Models.Category? selectedCat;
          if (_selectedSlug != null && _selectedSlug!.isNotEmpty) {
            try {
              selectedCat =
                  categories.firstWhere((c) => c.slug == _selectedSlug);
            } catch (_) {
              selectedCat = null;
            }
          }
          _selectedName ??= selectedCat?.name;

          if (!_didInitialLoad &&
              _selectedSlug != null &&
              _selectedSlug!.isNotEmpty &&
              pricesProv.prices == null &&
              !pricesProv.loading) {
            _didInitialLoad = true;
            Future.microtask(() => pricesProv.load(_selectedSlug!));
          }

          Future<void> _onCategoryChanged(String? name) async {
            if (name == null) return;
            final cat = categories.firstWhere((c) => c.name == name,
                orElse: () =>
                    Models.Category(id: 0, slug: '', name: '', iconUrl: ''));
            setState(() {
              _selectedSlug = cat.slug;
              _selectedName = cat.name;
            });
            if (cat.slug.isNotEmpty) {
              await pricesProv.load(cat.slug);
            }
          }

          final int? displayedPrice = () {
            final p = pricesProv.prices;
            if (p == null) return null;
            if (_planType == 'featured') return p.priceFeatured;
            return p.priceStandard;
          }();

          return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                  bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
         
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text('الاشتراك في الباقات',
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
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
                ),
              //  bottomNavigationBar: const SizedBox.shrink(),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('اختيار القسم',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface)),
                        SizedBox(height: 6.h),
                        _CategoryDropdown(
                          names: names,
                          initialName: _selectedName,
                          onChanged: _onCategoryChanged,
                        ),
                        SizedBox(height: 30.h),
                        Text('اختيار الباقة',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface)),
                        SizedBox(height: 6.h),
                        _PlanTile(
                          title: 'الباقة المتميزة',
                          subtitle:
                              'إعلاناتنا تظهر في مجموعة أعلي قائمة الاعلانات',
                          selected: _planType == 'featured',
                          onTap: () => setState(() => _planType = 'featured'),
                        ),
                        SizedBox(height: 18.h),
                        _PlanTile(
                          title: 'الباقة الاستاندرد',
                          subtitle:
                              'إعلاناتنا تظهر في مجموعة بعد الاعلانات المتميزة',
                          selected: _planType == 'standard',
                          onTap: () => setState(() => _planType = 'standard'),
                        ),
                        SizedBox(height: 50.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2)),
                              ]),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('السعر',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: cs.onSurface)),
                              ),
                              Text(
                                displayedPrice == null
                                    ? '—'
                                    : 'ج ${displayedPrice}',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cs.secondary),
                              ),
                            ],
                          ),
                        ),
                         SizedBox(height: 120.h),
                 
                        ElevatedButton(
                          onPressed:
                              (_selectedSlug == null || _selectedSlug!.isEmpty)
                                  ? null
                                  : () {
                                      final priceToSend = displayedPrice;
                                      context.push('/payment/checkout', extra: {
                                        'price': priceToSend,
                                        'initialSlug': _selectedSlug,
                                        'planType': _planType,
                                      });
                                    },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              fixedSize: Size.fromHeight(46.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r))),
                          child: const Text('التالي'),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<String> names;
  final String? initialName;
  final ValueChanged<String?> onChanged;
  const _CategoryDropdown(
      {required this.names, this.initialName, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = (initialName == null || initialName!.isEmpty)
        ? 'اختر القسم'
        : initialName!;
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            final controller = TextEditingController();
            List<String> filtered = List.of(names);
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (ctx) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 35.h,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          child: TextField(
                            controller: controller,
                            onChanged: (v) {
                              filtered = names
                                  .where((n) =>
                                      n.toLowerCase().contains(v.toLowerCase()))
                                  .toList();
                              (ctx as Element).markNeedsBuild();
                            },
                            decoration: InputDecoration(
                              hintText: 'ابحث عن القسم',
                              prefixIcon:
                                  Icon(Icons.search, color: cs.onSurface),
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    width: 1.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide:
                                    BorderSide(color: cs.primary, width: 2.0),
                              ),
                            ),
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (c, i) {
                              final n = filtered[i];
                              return ListTile(
                                title: Text(n,
                                    style: TextStyle(color: cs.onSurface)),
                                onTap: () {
                                  onChanged(n);
                                  Navigator.of(ctx).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border(right: BorderSide(color: cs.primary, width: 4.w)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2)),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(display,
                            style: TextStyle(
                                fontSize: 14.sp, color: cs.onSurface)),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Color.fromRGBO(118, 129, 130, 1)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 16.w,
          right: 9.w,
          child: Container(
            height: 1.h,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTile(
      {required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 0.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border(right: BorderSide(color: cs.primary, width: 4.w)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: cs.secondary,
                      size: 20,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 16.w,
            right: 9.w,
            child: Container(
              height: 1.h,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
