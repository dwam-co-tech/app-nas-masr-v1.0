// screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/providers/home_provider.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/core/theming/styles.dart';
import 'package:nas_masr_app/screens/home.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custome_phone_filed.dart';

import 'package:flutter/foundation.dart' as foundation;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _phone = '';
  String _password = '';
  bool _loading = false;
  final TextEditingController _phoneController = TextEditingController();
  String? _countryIso;

  Future<void> _submit() async {
    final phone = _phone.trim();
    final pass = _password;
    // أولاً: تحقق من الحقول الفارغة برسالة مناسبة
    if (phone.isEmpty || pass.isEmpty) {
      String msg;
      if (phone.isEmpty && pass.isEmpty) {
        msg = 'من فضلك أدخل رقم الهاتف وكلمة المرور';
      } else if (phone.isEmpty) {
        msg = 'من فضلك أدخل رقم الهاتف';
      } else {
        msg = 'من فضلك أدخل كلمة المرور';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(msg, textAlign: TextAlign.right),
          ),
        ),
      );
      return;
    }
    final e164Valid = RegExp(r'^\+?[1-9]\d{6,14}$').hasMatch(phone);
    final egyptLocalValid = RegExp(r'^01[0-9]{9}$').hasMatch(phone);
    final phoneValid = e164Valid || egyptLocalValid;
    if (!phoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child:
                const Text('رقم الهاتف غير صحيح', textAlign: TextAlign.right),
          ),
        ),
      );
      return;
    }

    if (pass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child:
                const Text('كلمة المرور غير صحيحة', textAlign: TextAlign.right),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final token = await auth.register(phone: phone, password: pass);
      if (token != null && token.isNotEmpty) {
        if (!mounted) return;
        // استبدال Navigator بـ go_router
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(e.toString(), textAlign: TextAlign.right),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final Color bg = const Color(0xFFF1F1F1);
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
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
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: isLand ? 90.h : 150.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.image_not_supported_outlined,
                                size: isLand ? 36.sp : 48.sp,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'لكل مصر',
                          textAlign: TextAlign.center,
                          style: tt.titleLarge?.copyWith(height: 1.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isLand ? 8.h : 12.h),
                  Text(
                    'تسجيل دخول',
                    textAlign: TextAlign.center,
                    style: tt.titleLarge?.copyWith(
                        fontSize: isLand ? 18.sp : 22.sp, color: cs.onSurface),
                  ),
                  SizedBox(height: isLand ? 0 : 1.h),
                  Text(
                    'مرحباً بعودتك مجدداً',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontSize: isLand ? 11.sp : 12.sp,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: isLand ? 6.h : 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'رقم الهاتف',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ColorManager.primary_font_color,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      CustomPhoneField(
                        controller: _phoneController,
                        onPhoneNumberChanged: (v) {
                          _phone = v;
                        },
                        onCountryChanged: (iso) {
                          _countryIso = iso;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  CustomTextField(
                    labelText: 'كلمة المرور',
                    isPassword: true,
                    hintText: '***',
                    onChanged: (v) => _password = v,
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: GestureDetector(
                            onTap: _launchWhatsAppSupport,
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontSize: isLand ? 12.sp : 14.sp,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomTextField(
                    labelText: 'كود المندوب',
                    isOptional: true,
                    hintText: 'XXXX',
                    showTopLabel: true,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: isLand ? 10.h : 16.h),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      elevation: 2,
                      shadowColor: cs.primary.withOpacity(0.4),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      _loading ? 'جاري التحميل...' : 'تسجيل الدخول',
                      style: tt.bodyMedium?.copyWith(
                        fontSize: isLand ? 14.sp : 16.sp,
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: isLand ? 8.h : 12.h),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'بالتسجيل، أنت توافق\n',
                        style: tt.bodyMedium?.copyWith(
                            fontSize: isLand ? 11.sp : 12.sp,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w400),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'على ',
                            style: tt.bodyMedium?.copyWith(
                                fontSize: isLand ? 11.sp : 12.sp,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: 'الشروط والأحكام',
                            style: tt.bodyMedium?.copyWith(
                                fontSize: isLand ? 11.sp : 12.sp,
                                color: cs.secondary,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push('/terms');
                              },
                          ),
                          TextSpan(
                            text: ' و ',
                            style: tt.bodyMedium?.copyWith(
                                fontSize: isLand ? 11.sp : 12.sp,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: 'سياسة الخصوصية',
                            style: tt.bodyMedium?.copyWith(
                                fontSize: isLand ? 11.sp : 12.sp,
                                color: cs.secondary,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push('/privacy');
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
