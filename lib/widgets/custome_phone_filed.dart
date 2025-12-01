// ملف: custom_phone_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:nas_masr_app/core/theming/colors.dart';

class CustomPhoneField extends StatelessWidget {
  final Function(String)? onCountryChanged;
  final Function(String)?
      onPhoneNumberChanged; // Callback جديد لإرسال الرقم الكامل
  final TextEditingController controller;
  final TextDirection? textDirection;
  final String? label;
  final TextStyle? labelStyle;
  final bool showTopLabel;

  const CustomPhoneField({
    super.key,
    this.onCountryChanged,
    this.onPhoneNumberChanged, // تمت إضافته هنا
    required this.controller,
    this.textDirection,
    this.label,
    this.labelStyle,
    this.showTopLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // الحل النهائي لمشكلة لون النص في البحث عبر تغليف الويدجت بـ Theme
    final themedField = Theme(
      data: Theme.of(context).copyWith(
        // تحديد خصائص حقول الإدخال
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
              labelStyle: const TextStyle(color: Colors.white),
              floatingLabelStyle: TextStyle(color: cs.onSurface),
            ),
        // تحديد لون النص الذي يتم كتابته داخل حقل البحث
        textTheme: Theme.of(context)
            .textTheme
            .copyWith(
              titleMedium: TextStyle(color: cs.onSurface), // لـ Material 3
              // subtitle1: const TextStyle(color: cs.onSurface),   // لـ Material 2 (احتياطي)
            )
            .apply(
              bodyColor: cs.onSurface,
              displayColor: cs.onSurface,
            ),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: IntlPhoneField(
          controller: controller,
          initialCountryCode: 'EG',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "01030623153",
            hintStyle: const TextStyle(
                color: Color.fromRGBO(129, 126, 126, 1),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 1)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 1)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide:
                  BorderSide(color: ColorManager.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red.shade700, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
            ),
            counterText: '',
          ),
          dropdownTextStyle: TextStyle(
            color: cs.onSurface,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
          pickerDialogStyle: PickerDialogStyle(
            searchFieldInputDecoration: InputDecoration(
              labelText: "بحث",
            ),
            countryNameStyle: TextStyle(color: cs.onSurface),
          ),
          dropdownIconPosition: IconPosition.leading,

          // ✨ التعديل الأهم هنا ✨
          // يتم استدعاؤه عند تغيير الرقم أو الدولة
          onChanged: (PhoneNumber phone) {
            if (onPhoneNumberChanged != null) {
              // نمرر الرقم الكامل (مثال: "+971501234567") للخارج
              onPhoneNumberChanged!(phone.completeNumber);
            }
          },

          // هذه تبقى كما هي للتعامل مع تغيير الدولة فقط
          onCountryChanged: (country) {
            if (onCountryChanged != null) {
              onCountryChanged!(country.code);
            }
          },
        ),
      ),
    );

    final fieldWithShadow = Material(
      elevation: 4.0,
      shadowColor: Color.fromRGBO(0, 0, 0, 0.25).withOpacity(.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: themedField,
    );

    if (!(showTopLabel && (label?.isNotEmpty ?? false))) {
      return fieldWithShadow;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label!,
            textAlign: TextAlign.right,
            style: labelStyle ??
                const TextStyle(
                  fontSize: 15,
                  color: ColorManager.primaryColor,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: 4),
        fieldWithShadow,
      ],
    );
  }
}
