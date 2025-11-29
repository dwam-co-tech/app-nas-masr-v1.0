import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/auth_provider.dart';
import 'package:nas_masr_app/core/data/providers/home_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool notificationsOn = true;
  String currentLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _launchWhatsAppSupport() async {
    final home = context.read<HomeProvider>();
    String? number = home.supportNumber;
    number ??= await home.ensureSupportNumber();
    if (!mounted) return;
    if (number == null || number.isEmpty) {
      foundation.debugPrint('=== WHATSAPP DEBUG ===');
      foundation.debugPrint('Support number is null/empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text('تعذر الحصول على رقم الدعم',
                textAlign: TextAlign.right),
          ),
        ),
      );
      return;
    }
    // إزالة جميع الرموز غير الرقمية ثم تطبيع الرقم لصيغة دولية إن لزم (EG: +20)
    var sanitized = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.startsWith('00')) {
      // أحياناً تُكتب الأكواد الدولية بـ 00 بدلاً من +
      sanitized = sanitized.substring(2);
    }
    String normalized = sanitized;
    if (sanitized.startsWith('0') && !sanitized.startsWith('20')) {
      // نفترض مصر كبلد افتراضي للتطبيق (nas_masr_app) => كود الدولة 20
      normalized = '20${sanitized.substring(1)}';
      foundation.debugPrint('Applied EG country code fallback (+20).');
    }
    final encodedText = Uri.encodeComponent('مرحبا!');
    final deepNoPlus =
        Uri.parse('whatsapp://send?phone=$normalized&text=$encodedText');
    final deepPlus =
        Uri.parse('whatsapp://send?phone=%2B$normalized&text=$encodedText');
    final waUri = Uri.parse('https://wa.me/$normalized?text=$encodedText');
    final apiUri = Uri.parse(
        'https://api.whatsapp.com/send?phone=$normalized&text=$encodedText');

    foundation.debugPrint('=== WHATSAPP DEBUG ===');
    foundation.debugPrint('Raw support number: $number');
    foundation.debugPrint('Sanitized number: $sanitized');
    foundation.debugPrint('Normalized number (final): $normalized');
    foundation.debugPrint('kIsWeb: ${foundation.kIsWeb}');

    try {
      if (foundation.kIsWeb) {
        final ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        foundation.debugPrint('launch wa.me (web) result: $ok');
        if (ok) return;
        final okWeb = await launchUrl(
          apiUri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration:
              const WebViewConfiguration(enableJavaScript: true),
        );
        foundation.debugPrint('launch inAppWebView (web) result: $okWeb');
        if (!okWeb)
          throw Exception('No available handler for WhatsApp links on web');
        return;
      } else {
        foundation.debugPrint('Trying deep link without plus: $deepNoPlus');
        var ok =
            await launchUrl(deepNoPlus, mode: LaunchMode.externalApplication);
        foundation.debugPrint('launch whatsapp (no plus) result: $ok');
        if (ok) return;

        foundation.debugPrint('Trying deep link with plus: $deepPlus');
        ok = await launchUrl(deepPlus, mode: LaunchMode.externalApplication);
        foundation.debugPrint('launch whatsapp (with plus) result: $ok');
        if (ok) return;

        foundation.debugPrint('Trying wa.me external: $waUri');
        ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        foundation.debugPrint('launch wa.me external result: $ok');
        if (ok) return;

        foundation.debugPrint('Trying api.whatsapp external: $apiUri');
        ok = await launchUrl(apiUri, mode: LaunchMode.externalApplication);
        foundation.debugPrint('launch api.whatsapp external result: $ok');
        if (ok) return;

        // Final fallback: open WhatsApp web page in-app
        final okWebView = await launchUrl(
          apiUri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration:
              const WebViewConfiguration(enableJavaScript: true),
        );
        foundation
            .debugPrint('launch inAppWebView (android) result: $okWebView');
        if (!okWebView)
          throw Exception('No available handler for any WhatsApp link');
        return;
      }
    } catch (e) {
      foundation.debugPrint('WHATSAPP LAUNCH ERROR: $e');
      foundation.debugPrint(
          'Root cause likely: no handler available or invalid phone format.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text('تعذر فتح واتساب', textAlign: TextAlign.right),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final double tileIconSize = isLand ? 24.sp : 28.sp;
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingsHeader(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //   SizedBox(height: 8.h),
                        _SettingTile(
                          title: 'الملف الشخصي',
                          leadingSvgAsset: 'assets/svg/person.svg',
                          iconSize: tileIconSize,
                          onTap: () {
                            context.push('/profile');
                          },
                        ),
                        SizedBox(height: 3.h),
                        _SettingTile(
                          title: 'إنشاء كود المندوب',
                          leadingSvgAsset: 'assets/svg/code.svg',
                          iconSize: tileIconSize,
                          onTap: () {},
                        ),
                        SizedBox(height: 3.h),
                        _SettingTile(
                          title: 'الإشعارات',
                          leadingIcon: Icons.notifications_rounded,
                          // iconSize: 70.sp,
                          trailing: Switch(
                            value: notificationsOn,
                            activeColor: ColorManager.primaryColor,
                            inactiveThumbColor: Colors.white,
                            //   inactiveTrackColor:ColorManager.primaryColor,
                            //  activeTrackColor:Colors.white,
                            onChanged: (v) =>
                                setState(() => notificationsOn = v),
                          ),
                          verticalPadding: 2.h,
                          iconSize: 24.sp,
                          showArrow: false,
                        ),
                        SizedBox(height: 3.h),
                        // _SettingTile(
                        //   title: 'اللغة',
                        //   leadingIcon: Icons.language,
                        //   trailing: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Text(
                        //         currentLanguage,
                        //         style: TextStyle(
                        //           fontSize: 14.sp,
                        //           fontFamily: 'Tajawal',
                        //           color: ColorManager.primaryColor,
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //       SizedBox(width: 8.w),
                        //       // _CircleIcon(icon: Icons.public,color:ColorManager.primary_font_color  , bg: ColorManager.primary_font_color.withOpacity(0.15)),
                        //     ],
                        //   ),
                        //   onTap: () {},
                        // ),
                        // SizedBox(height: 5.h),
                        _SettingTile(
                          title: 'تواصل لإضافة خدمة',
                          leadingSvgAsset: 'assets/svg/contact.svg',
                          iconSize: tileIconSize,
                          onTap: _launchWhatsAppSupport,
                        ),
                        SizedBox(height: 3.h),
                        _SettingTile(
                          title: 'تواصل للاستفسارات',
                          leadingSvgAsset: 'assets/svg/asking.svg',
                          iconSize: tileIconSize,
                          onTap: _launchWhatsAppSupport,
                        ),
                        SizedBox(height: 3.h),
                        _SettingTile(
                          title: 'الشروط والأحكام',
                          leadingSvgAsset: 'assets/svg/condetion.svg',
                          iconSize: tileIconSize,
                          onTap: () {
                            // انتقل إلى صفحة الشروط عبر go_router
                            context.push('/terms');
                          },
                        ),
                        SizedBox(height: 3.h),
                        _SettingTile(
                          title: 'الأمان والخصوصية',
                          leadingSvgAsset: 'assets/svg/safe.svg',
                          useGradientIcon: false,
                          iconSize: tileIconSize,
                          onTap: () {
                            // انتقل إلى الخصوصية عبر go_router
                            context.push('/privacy');
                          },
                        ),
                        SizedBox(height: 3.h),
                        _SettingTile(
                          title: 'تسجيل الخروج',
                          leadingSvgAsset: 'assets/svg/logout.svg',
                          iconSize: tileIconSize,
                          useGradientIcon: false,
                          centerContent: true,
                          onTap: () async {
                            // امسح التوكن ثم اذهب لشاشة تسجيل الدخول
                            await context.read<AuthProvider>().logout();
                            if (!mounted) return;
                            // استخدم go_router للانتقال وإفراغ المكدس
                            context.go('/login');
                          },
                          showArrow: false,
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 420 / 200,
            child: Image.asset(
              'assets/images/setting.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        PositionedDirectional(
          top: 12.h,
          start: 12.w,
          child: IconButton(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.arrow_back, color: cs.onSurface, size: 30.sp),
            tooltip: 'رجوع',
          ),
        ),
        Positioned(
          top: 16.h,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'الإعدادات',
              style:
                  tt.titleLarge?.copyWith(fontSize: 22.sp, color: cs.onSurface),
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              height:90.h,
              //width: 138.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final String? leadingSvgAsset;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? leadingBg;
  final Color? leadingColor;
  final double? verticalPadding;
  final double? iconSize;
  final bool showArrow;
  final bool useGradientIcon;
  final bool centerContent;

  const _SettingTile({
    required this.title,
    this.leadingIcon,
    this.leadingSvgAsset,
    this.trailing,
    this.onTap,
    this.leadingBg,
    this.leadingColor,
    this.verticalPadding,
    this.iconSize,
    this.showArrow = true,
    this.useGradientIcon = true,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      elevation: 4.0,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.25).withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 12.w, vertical: verticalPadding ?? 12.h),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFEFF2F5)),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: centerContent
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              _CircleIcon(
                icon: leadingSvgAsset == null ? leadingIcon : null,
                bg: leadingBg ?? cs.primary.withOpacity(0.15),
                color: leadingColor ?? cs.onSurface,
                useGradient: useGradientIcon,
                iconSize: iconSize ?? 32.sp,
                child: leadingSvgAsset != null
                    ? SvgPicture.asset(
                        leadingSvgAsset!,
                        width: (iconSize ?? 32.sp),
                        height: (iconSize ?? 32.sp),
                      )
                    : null,
              ),
              SizedBox(width: 8.w),
              centerContent
                  ? Text(
                      title,
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium
                          ?.copyWith(fontSize: 16.sp, color: cs.onSurface),
                    )
                  : Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.right,
                        style: tt.bodyMedium
                            ?.copyWith(fontSize: 16.sp, color: cs.onSurface),
                      ),
                    ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ],
              if (showArrow) ...[
                SizedBox(width: 8.w),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(20, 135, 111, 1),
                        Color.fromRGBO(3, 70, 74, 1),
                      ],
                    ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                  },
                  blendMode: BlendMode.srcIn,
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData? icon;
  final Color bg;
  final Color? color;
  final bool useGradient;
  final double? iconSize;
  final Widget? child;
  const _CircleIcon({
    this.icon,
    required this.bg,
    this.color,
    this.useGradient = false,
    this.iconSize,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Widget inner = child ??
        Icon(
          icon ?? Icons.circle,
          color: useGradient ? Colors.white : (color ?? cs.secondary),
          size: iconSize ?? 18.sp,
        );

    return Container(
      width: 34.w,
      height: 34.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: useGradient
          ? ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(20, 135, 111, 1),
                    Color.fromRGBO(3, 70, 74, 1),
                  ],
                ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height));
              },
              blendMode: BlendMode.srcIn,
              child: inner,
            )
          : inner,
    );
  }
}
