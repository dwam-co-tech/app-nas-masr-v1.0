import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
            'الشروط والأحكام',
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
                  title: 'نبذة عامة',
                  body:
                      'باستخدامك هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام. نحتفظ بحق تعديلها في أي وقت مع إشعار مناسب داخل التطبيق.',
                  icon: Icons.description_outlined,
                ),
                _section(
                  context: context,
                  title: 'استخدام التطبيق',
                  body:
                      'يجب استخدام التطبيق لأغراض مشروعة فقط، وعدم إساءة استخدام الخدمات أو محاولة تعطيلها. يتحمل المستخدم مسؤولية دقة المعلومات المُدخلة.',
                  icon: Icons.verified_user_outlined,
                ),
                _section(
                  context: context,
                  title: 'إنشاء الحساب والخصوصية',
                  body:
                      'عند إنشاء حساب، تلتزم بتقديم معلومات صحيحة ومحدثة. نحن نعمل على حماية بياناتك وفق سياسة الخصوصية المرفقة.',
                  icon: Icons.lock_person_outlined,
                ),
                _section(
                  context: context,
                  title: 'المسؤولية وإخلاء المسؤولية',
                  body:
                      'الخدمات تُقدّم كما هي. لا نتحمل مسؤولية أي أضرار مباشرة أو غير مباشرة نتيجة سوء الاستخدام أو الأعطال الخارجة عن إرادتنا.',
                  icon: Icons.gavel_outlined,
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