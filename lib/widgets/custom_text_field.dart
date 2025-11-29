// widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/theming/colors.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final bool isPassword;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool isOptional;
  final Function(String)? onChanged;
  final String? hintText;
  final bool showTopLabel;
  final bool filled;
  final Color? fillColor;
  final TextDirection? textDirection;
  final bool readOnly;
  final Widget? suffix;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;
  final int? maxLength;
  final TextStyle? labelStyle;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.isPassword = false,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.isOptional = false,
    this.onChanged,
    this.hintText,
    this.showTopLabel = true,
    this.filled = true,
    this.fillColor,
    this.textDirection,
    this.readOnly = false,
    this.suffix,
    this.textAlign,
    this.contentPadding,
    this.maxLines,
    this.maxLength,
    this.labelStyle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide:
          BorderSide(color: Color.fromRGBO(255, 255, 255, 1), width: 1.0),
    );

    final String fullLabel =
        widget.isOptional ? '${widget.labelText} (اختياري)' : widget.labelText;
    final Color effectiveFill =
        widget.fillColor ?? Color.fromRGBO(255, 255, 255, 1);

    final int effectiveMaxLines = _obscure ? 1 : (widget.maxLines ?? 1);
    final Widget field = TextFormField(
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      maxLines: effectiveMaxLines,
      maxLength: widget.maxLength,
      style: const TextStyle(fontSize: 16),
      textAlign: widget.textAlign ?? TextAlign.right,
      decoration: InputDecoration(
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
        filled: widget.filled,
        fillColor: effectiveFill,
        hintText: widget.isPassword
            ? null
            : (widget.hintText ?? (widget.isOptional ? 'XXXX' : null)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: ColorManager.primaryColor),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        suffix: widget.suffix,
        hintStyle: TextStyle(color: Color.fromRGBO(118, 129, 130, 1)),
      ),
    );

    // إضافة ظل للحقل بقيمة 2 ولون rgba(0,0,0,0.25)
    final Widget fieldWithShadow = Material(
      elevation: 4.0,
      shadowColor: Color.fromRGBO(0, 0, 0, 0.25).withOpacity(.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: field,
    );

    final Widget fieldWithDirection = Directionality(
      textDirection: widget.textDirection ?? Directionality.of(context),
      child: fieldWithShadow,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: widget.showTopLabel
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: widget.isOptional
                      ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: widget.labelText,
                                style: widget.labelStyle ??
                                    const TextStyle(
                                      fontSize: 14,
                                      color: ColorManager.primary_font_color,
                                      fontFamily: 'Tajawal',
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const TextSpan(
                                text: ' (اختياري)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(1, 22, 24, 0.45),
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                        )
                      : Text(
                          fullLabel,
                          textAlign: TextAlign.right,
                          style: widget.labelStyle ??
                              const TextStyle(
                                fontSize: 14,
                                color: ColorManager.primary_font_color,
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                ),
                const SizedBox(height: 2),
                fieldWithDirection,
              ],
            )
          : fieldWithDirection,
    );
  }
}
