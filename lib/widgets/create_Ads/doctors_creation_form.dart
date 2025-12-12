import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';

class DoctorsCreationForm extends StatelessWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final TextStyle? labelStyle;
  final ValueChanged<String?>? onNameChanged;
  final String? initialName;
  final ValueChanged<String?>? onSpecializationChanged;
  final String? initialSpecialization;
  final String? nameLabel;

  const DoctorsCreationForm({
    super.key,
    required this.fieldsConfig,
    this.labelStyle,
    this.onSpecializationChanged,
    this.initialSpecialization,
    this.onNameChanged,
    this.initialName,
    this.nameLabel,
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
    final specializationOptions = _getField('specialization')
            ?.options
            .map((e) => e.toString())
            .toList() ??
        const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          labelText: nameLabel ?? 'الاسم (مثال: د. أحمد محمد)',
          initialValue: initialName,
          showTopLabel: true,
          labelStyle: labelStyle,
          onChanged: onNameChanged,
        ),
        SizedBox(height: 12),
        CustomDropdownField(
          label: 'التخصص',
          options: specializationOptions,
          isRequired: true,
          labelStyle: labelStyle,
          initialValue: initialSpecialization,
          onChanged: onSpecializationChanged,
        ),
      ],
    );
  }
}
