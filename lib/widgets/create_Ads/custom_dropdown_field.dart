// widgets/custom_dropdown_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
// Note: سنستخدم ColorManager إذا كان مُتاحاً (لوجوده في كود الـ CustomTextField)

class CustomDropdownField extends StatefulWidget {
  final String label;
  final List<String> options; // قائمة الاختيارات (القيم المعروضة)
  final bool isRequired;
  final String? initialValue;
  final Function(String? value)? onChanged;
  final String? emptyOptionsHint;
  final TextStyle? labelStyle;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.options,
    this.isRequired = false,
    this.initialValue,
    this.onChanged,
    this.emptyOptionsHint,
    this.labelStyle,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  String? _selectedValue;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller.text = _selectedValue ?? '';
  }

  @override
  void didUpdateWidget(covariant CustomDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إعادة ضبط القيمة عند تغيّر الخيارات بحيث لا تبقى قيمة غير موجودة
    if (_selectedValue != null && !widget.options.contains(_selectedValue)) {
      setState(() => _selectedValue = null);
      _controller.text = '';
    }
    // مزامنة أي تغيير وارد في initialValue
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _selectedValue) {
      setState(() => _selectedValue = widget.initialValue);
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> opts = widget.options.toSet().toList();
    final bool enabled = opts.isNotEmpty;
    // تنسيق الـ Input مشابه للـ CustomTextField
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide:
          BorderSide(color: Color.fromRGBO(255, 255, 255, 1), width: 1.0),
    );
    final Color effectiveFill = Color.fromRGBO(255, 255, 255, 1);

    Future<void> _openOptions() async {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          final bool keyboardOpen = MediaQuery.of(ctx).viewInsets.bottom > 0;
          return FractionallySizedBox(
            heightFactor: keyboardOpen ? 1 : 0.7,
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: FilterOptionsModal(
                title: widget.label,
                options: opts,
                requireApply: false,
                onSelected: (val) {
                  final String selected = val.toString();
                  setState(() {
                    _selectedValue = selected;
                    _controller.text = selected;
                  });
                  widget.onChanged?.call(selected);
                },
              ),
            ),
          );
        },
      );
    }

    final Widget dropdown = Material(
      elevation: 4.0,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.25).withOpacity(.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: TextField(
        controller: _controller,
        readOnly: true,
        enableInteractiveSelection: false,
        onTap: enabled ? _openOptions : null,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          ),
          filled: true,
          fillColor: effectiveFill,
          hintText: enabled
              ? (_selectedValue == null ? 'اختر...' : null)
              : (widget.emptyOptionsHint ?? '—'),
          hintStyle: enabled
              ? null
              : TextStyle(
                  fontSize: 12.sp,
                  color: const Color.fromRGBO(118, 129, 130, 1),
                  fontWeight: FontWeight.w400,
                ),
          suffixIcon: const Icon(Icons.keyboard_arrow_down,
              color: Color.fromRGBO(118, 129, 130, 1)),
        ),
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );

    // الجزء الذي يضيف الـ Label فوق الـ Dropdown
    final Widget topLabelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.label,
            textAlign: TextAlign.right,
            style: widget.labelStyle ??
                const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(1, 22, 24, 0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: 2),
        dropdown,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: topLabelContent,
    );
  }
}
