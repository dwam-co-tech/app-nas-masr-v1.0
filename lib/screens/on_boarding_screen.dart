// screens/Onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// نماذج للبيانات اللي هتظهر في الـ Carousel
class OnboardingPageModel {
  final String title;
  // صورة اختيارية لعرضها داخل الكارد
  final String? imagePath;
  const OnboardingPageModel(this.title, {this.imagePath});
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _imageAssets = const [
    'assets/images/imag2.jpg',
    'assets/images/imag1.jpg',
    
    'assets/images/Image3.png',
  ];

  // دي البيانات الثابتة اللي هتظهر (تقدري تغيريها)
  final List<OnboardingPageModel> _pages = const [
    OnboardingPageModel('إعلانات وإرشادات'),
    OnboardingPageModel('مميزات منصتنا'),
    OnboardingPageModel('مميزات منصتنا'),
  ];

  // وصف كل صفحة (مفصول عن بيانات الكارد)
  final List<String> _descriptions = const [
    'منصة تجمع أقوى المتاجر والعروض والخدمات \nابدأ تجربتك الآن بكل سهولة وأمان',
    'منصة تجمع أقوى المتاجر والعروض والخدمات \nابدأ تجربتك الآن بكل سهولة وأمان',
    'منصة تجمع أقوى المتاجر والعروض والخدمات \nابدأ تجربتك الآن بكل سهولة وأمان',
  ];

  @override
  void initState() {
    super.initState();
    // Listener لمتابعة رقم الصفحة الحالية لتحديث النقط (Indicators)
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // الدالة الخاصة ببناء صفحة واحدة داخل الـ Onboarding
  Widget _buildPageContent(
    BuildContext context,
    int index,
    OnboardingPageModel page, {
    required bool isLand,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final height = MediaQuery.of(context).size.height;
    final double cardHeight =
        isLand ? (height * .01).clamp(20.0, 200.0) : 330.h;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // البطاقة الرئيسية بشكل Card فلات بدون ظل
          if (isLand)
            Expanded(
              child: Card(
                elevation: 3, // فلات بدون ظل
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  child: Column(
                    children: [
                      SizedBox(height: 0),
                      if (isLand)
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: tt.titleLarge?.copyWith(fontSize: 10.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: tt.titleLarge,
                        ),
                      SizedBox(height: isLand ? 2.h : 12.h),
                      if (isLand)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              _imageAssets[index % _imageAssets.length],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                color: const Color(0xFFF3F5F6),
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 36.sp,
                                  color: ColorManager.primary_font_color
                                      .withOpacity(0.25),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: SizedBox(
                            height: 180.h,
                            width: double.infinity,
                            child: Image.asset(
                              _imageAssets[index % _imageAssets.length],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  Container(
                                color: const Color(0xFFF3F5F6),
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48.sp,
                                  color: ColorManager.primary_font_color
                                      .withOpacity(0.25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!isLand) ...[
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (dotIndex) {
                            final bool active = _currentPage == dotIndex;
                            return Container(
                              width: active ? 18.w : 8.w,
                              height: 8.h,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                color: active
                                    ? cs.secondary
                                    : cs.onSurface.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: cardHeight,
              width: double.infinity,
              child: Card(
                elevation: 3,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: tt.titleLarge,
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            _imageAssets[index % _imageAssets.length],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: const Color(0xFFF3F5F6),
                              child: Icon(
                                Icons.image_outlined,
                                size: 48.sp,
                                color: ColorManager.primary_font_color
                                    .withOpacity(0.25),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (dotIndex) {
                          final bool active = _currentPage == dotIndex;
                          return Container(
                            width: active ? 18.w : 8.w,
                            height: 8.h,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: active
                                  ? cs.secondary
                                  : cs.onSurface.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isLand) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/logo.png',
                              height: 90.h, fit: BoxFit.contain),
                          SizedBox(width: 8.w),
                          Text('لكل مصر',
                              style: tt.titleLarge
                                  ?.copyWith(fontSize: 15.sp, height: 1.0)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18.h),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _pages.length,
                                itemBuilder: (context, index) {
                                  return _buildPageContent(
                                      context, index, _pages[index],
                                      isLand: true);
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 15.h),
                              child: LayoutBuilder(
                                builder: (context, rightCons) {
                                  final bool tight = rightCons.maxHeight < 300;
                                  final side = Column(
                                    mainAxisAlignment: tight
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text('احصل على كل ما تحتاجه في مكان واحد',
                                          textAlign: TextAlign.center,
                                          style: tt.bodyMedium?.copyWith(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: cs.secondary)),
                                      SizedBox(height: tight ? 6.h : 8.h),
                                      Text(_descriptions[_currentPage],
                                          textAlign: TextAlign.center,
                                          style: tt.bodyMedium?.copyWith(
                                              fontSize: 8.sp,
                                              color: cs.onSurface,
                                              height: 1.5)),
                                      SizedBox(height: tight ? 10.h : 14.h),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48.h,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (_currentPage <
                                                _pages.length - 1) {
                                              _pageController.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  curve: Curves.easeIn);
                                            } else {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setBool(
                                                  'onboarding_done', true);
                                              if (!mounted) return;
                                              context.go('/login');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cs.primary,
                                            elevation: 2,
                                            shadowColor:
                                                cs.primary.withOpacity(0.4),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.h),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r)),
                                          ),
                                          child: Text('التالي',
                                              style: tt.bodyMedium?.copyWith(
                                                  fontSize: 8.sp,
                                                  color: cs.onPrimary,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ],
                                  );
                                  if (tight) {
                                    return SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
                                      child: side,
                                    );
                                  }
                                  return side;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Portrait: التخطيط الأصلي
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Column(
                    children: [
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: .8,
                          child: Image.asset('assets/images/logo.png',
                              height: 150.h, fit: BoxFit.contain),
                        ),
                      ),
                      Text('لكل مصر',
                          textAlign: TextAlign.center,
                          style: tt.titleLarge?.copyWith(height: 1.0)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(context, index, _pages[index],
                          isLand: false);
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text('احصل على كل ما تحتاجه في مكان واحد',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: cs.secondary,
                          height: 1.4)),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(_descriptions[_currentPage],
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                          height: 1.6)),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h),
                  child: Center(
                    child: SizedBox(
                      width: 334.w,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeIn);
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('onboarding_done', true);
                            if (!mounted) return;
                            context.go('/login');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          elevation: 2,
                          shadowColor: cs.primary.withOpacity(0.4),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text('التالي',
                            style: tt.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
