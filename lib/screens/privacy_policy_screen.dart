import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _section({
    required BuildContext context,
    required String title,
    required String body,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: cs.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.primary, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: tt.bodyMedium,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 1.6,
              color: cs.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: Text(
            'سياسة الخصوصية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
               padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: isLand ? 10.h : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section(
                  context: context,
                  title: 'جمع البيانات',
                  body:
                      'نقوم بجمع البيانات اللازمة لتحسين تجربتك داخل التطبيق، مثل معلومات الحساب والاستخدام. لا نقوم بجمع معلومات غير ضرورية.',
                  icon: Icons.storage_rounded,
                ),
                _section(
                  context: context,
                  title: 'استخدام البيانات',
                  body:
                      'نستخدم بياناتك لتقديم الخدمات، تخصيص المحتوى، وتحسين الأداء. لا نشارك بياناتك مع جهات خارجية إلا وفق القانون أو بموافقتك.',
                  icon: Icons.privacy_tip_outlined,
                ),
                _section(
                  context: context,
                  title: 'حماية البيانات',
                  body:
                      'نستخدم إجراءات أمان مناسبة لحماية بياناتك من الوصول غير المصرح به أو التغيير أو الإفصاح غير المشروع.',
                  icon: Icons.shield_moon_outlined,
                ),
                _section(
                  context: context,
                  title: 'حقوقك',
                  body:
                      'يمكنك طلب تحديث بياناتك أو حذف حسابك وفق الضوابط المعمول بها. لمزيد من التفاصيل، تواصل معنا عبر الدعم.',
                  icon: Icons.contact_support_outlined,
                ),
                SizedBox(height: 8.h),
                Text(
                  'آخر تحديث: اليوم',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}