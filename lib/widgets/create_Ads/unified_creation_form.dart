import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/create_Ads/form_layout_builder.dart';

class UnifiedCreationForm extends StatelessWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final TextStyle? labelStyle;
  final ValueChanged<String?>? onMainCategoryChanged;
  final ValueChanged<String?>? onSubCategoryChanged;
  final String? initialMainCategory;
  final String? initialSubCategory;

  const UnifiedCreationForm({
    super.key,
    required this.fieldsConfig,
    this.labelStyle,
    this.onMainCategoryChanged,
    this.onSubCategoryChanged,
    this.initialMainCategory,
    this.initialSubCategory,
  });

  CategoryFieldConfig? _getField(String name) {
    try {
      return fieldsConfig.firstWhere((f) => f.fieldName == name);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainCategoryOptions =
        _getField('main_category')?.options.map((e) => e.toString()).toList() ??
            const <String>[];
    final subCategoryOptions =
        _getField('sub_category')?.options.map((e) => e.toString()).toList() ??
            const <String>[];

    final Widget mainCategoryField = CustomDropdownField(
      label: 'القسم الرئيسي',
      options: mainCategoryOptions,
      isRequired: true,
      labelStyle: labelStyle,
      initialValue: initialMainCategory,
      onChanged: onMainCategoryChanged,
    );

    final Widget subCategoryField = CustomDropdownField(
      label: 'القسم الفرعي',
      options: subCategoryOptions,
      isRequired: true,
      labelStyle: labelStyle,
      initialValue: initialSubCategory,
      onChanged: onSubCategoryChanged,
    );

    final List<Widget> widgets = [mainCategoryField, subCategoryField];

    return build2ColFormLayout(widgets);
  }
}
