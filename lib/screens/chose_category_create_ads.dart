import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nas_masr_app/core/data/providers/home_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/home_repository.dart';
import 'package:nas_masr_app/core/data/models/category_home.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:nas_masr_app/widgets/category_card.dart';
import 'package:nas_masr_app/screens/public/ad_creation_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ChoseCategoryCreateAds extends StatefulWidget {
  const ChoseCategoryCreateAds({super.key});

  @override
  State<ChoseCategoryCreateAds> createState() => _ChoseCategoryCreateAdsState();
}

class _ChoseCategoryCreateAdsState extends State<ChoseCategoryCreateAds> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ChangeNotifierProvider(
        create: (context) {
          final p = HomeProvider(repository: HomeRepository());
          Future.microtask(() => p.loadHome());
          return p;
        },
        child: Consumer<HomeProvider>(
          builder: (context, home, _) {
            final isLand =
                MediaQuery.of(context).orientation == Orientation.landscape;
            return Scaffold(
              bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
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
                      child: Icon(Icons.notifications_rounded,
                          color: cs.onSurface, size: isLand ? 15.sp : 30.sp),
                    ),
                  ],
                  title: Text('اختيار القسم \nلإضافة الاعلان',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurface))),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: 16.w, vertical: isLand ? 6.h : 12.h),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.stretch,
                      //     children: const [
                      //       _TopRowCreateAds(),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(height: isLand ? 1.h : 4.h),
                      SizedBox(height: 8.h),
                      _BannerSection(
                          bannerUrl: home.bannerUrl, loading: home.loading),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (home.error != null)
                              _ErrorBox(message: home.error!),
                            _CategoriesGridCreateAds(
                                loading: home.loading,
                                categories: home.categories),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopRowCreateAds extends StatelessWidget {
  const _TopRowCreateAds();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
      ),
      padding:
          EdgeInsets.symmetric(horizontal: 0.w, vertical: isLand ? 0.h : 0.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: Icon(Icons.arrow_forward,
                color: cs.onSurface, size: isLand ? 18.sp : 26.sp),
            tooltip: 'رجوع',
          ),
          Expanded(
            child: Center(
              child: Text(
                'اختيار القسم لإضافة الاعلان',
                style: tt.titleLarge?.copyWith(
                  fontSize: isLand ? 14.sp : 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_rounded,
                color: cs.onSurface, size: isLand ? 16.sp : 26.sp),
            tooltip: 'الإشعارات',
          ),
        ],
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  final String? bannerUrl;
  final bool loading;
  const _BannerSection({required this.bannerUrl, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    return AspectRatio(
      aspectRatio: isLand ? (16 / 4.8) : (16 / 5),
      child: Builder(
        builder: (context) {
          if (loading && (bannerUrl == null || bannerUrl!.isEmpty)) {
            return Container(color: const Color(0xFFF0F2F5));
          }
          if (bannerUrl == null || bannerUrl!.isEmpty) {
            return Container(
              color: const Color(0xFFF0F2F5),
              child: Center(
                child: Text(
                  'لا توجد صورة متاحة',
                  style: TextStyle(
                      fontSize: 13.sp, color: const Color(0xFF8A949B)),
                ),
              ),
            );
          }
          return CachedNetworkImage(
            imageUrl: bannerUrl!,
            placeholder: (context, url) =>
                Container(color: const Color(0xFFF0F2F5)),
            imageBuilder: (context, imageProvider) => Image(
              image: imageProvider,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFF0F2F5),
              child: Center(
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.grey.shade400, size: 32.sp),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFC7B8)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.secondary, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  fontSize: 12.sp, fontFamily: 'Tajawal', color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesGridCreateAds extends StatelessWidget {
  final bool loading;
  final List<dynamic> categories;
  const _CategoriesGridCreateAds(
      {required this.loading, required this.categories});

  int _columnsForWidth(double w, bool isLand) {
    if (isLand) {
      if (w >= 900) return 6;
      if (w >= 700) return 5;
      return 4;
    }
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isLand = mq.orientation == Orientation.landscape;
    final cols = _columnsForWidth(width, isLand);
    final double aspect = isLand ? 0.85 : 0.70;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loading && categories.isEmpty)
          GridView.builder(
            itemCount: cols * 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: aspect,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          )
        else
          GridView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: aspect,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index] as Category;
              return CategoryCard(
                category: cat,
                onTap: () {
                  context.push('/ad/create', extra: {
                    'categorySlug': cat.slug,
                    'categoryName': cat.name,
                  });
                },
              );
            },
          ),
      ],
    );
  }
}
