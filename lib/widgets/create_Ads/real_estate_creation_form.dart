import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/create_Ads/form_layout_builder.dart';

class RealEstateCreationForm extends StatelessWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final TextStyle? labelStyle;
  final ValueChanged<String?>? onPropertyTypeChanged;
  final ValueChanged<String?>? onContractTypeChanged;
  final String? initialPropertyType;
  final String? initialContractType;

  const RealEstateCreationForm({
    super.key,
    required this.fieldsConfig,
    this.labelStyle,
    this.onPropertyTypeChanged,
    this.onContractTypeChanged,
    this.initialPropertyType,
    this.initialContractType,
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
    final propertyTypeOptions =
        _getField('property_type')?.options.map((e) => e.toString()).toList() ??
            const <String>[];
    final contractTypeOptions =
        _getField('contract_type')?.options.map((e) => e.toString()).toList() ??
            const <String>[];

    final Widget propertyType = CustomDropdownField(
      label: 'نوع العقار',
      options: propertyTypeOptions,
      isRequired: true,
      labelStyle: labelStyle,
      initialValue: initialPropertyType,
      onChanged: onPropertyTypeChanged,
    );

    final Widget contractType = CustomDropdownField(
      label: 'نوع العقد',
      options: contractTypeOptions,
      isRequired: true,
      labelStyle: labelStyle,
      initialValue: initialContractType,
      onChanged: onContractTypeChanged,
    );

    final List<Widget> widgets = [propertyType, contractType];

    return build2ColFormLayout(widgets);
  }
}
