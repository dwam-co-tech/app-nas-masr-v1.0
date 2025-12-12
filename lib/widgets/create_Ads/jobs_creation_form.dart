import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/main_section.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/create_Ads/form_layout_builder.dart';

class JobsCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final List<MainSection> mainSections;
  final TextStyle? labelStyle;
  final ValueChanged<String?>? onMainCategoryChanged;
  final ValueChanged<String?>? onSubCategoryChanged;
  final String? initialMainCategory;
  final String? initialSubCategory;

  const JobsCreationForm({
    super.key,
    required this.fieldsConfig,
    this.mainSections = const [],
    this.labelStyle,
    this.onMainCategoryChanged,
    this.onSubCategoryChanged,
    this.initialMainCategory,
    this.initialSubCategory,
  });

  @override
  State<JobsCreationForm> createState() => JobsCreationFormState();
}

class JobsCreationFormState extends State<JobsCreationForm> {
  String? _selectedMainCategory;
  String? _selectedSubCategory;

  final Map<String, String> _attributes = {};

  Map<String, String> getAttributes() => _attributes;

  @override
  void initState() {
    super.initState();
    _selectedMainCategory = widget.initialMainCategory;
    _selectedSubCategory = widget.initialSubCategory;
  }

  @override
  void didUpdateWidget(covariant JobsCreationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMainCategory != oldWidget.initialMainCategory) {
      _selectedMainCategory = widget.initialMainCategory;
    }
    if (widget.initialSubCategory != oldWidget.initialSubCategory) {
      _selectedSubCategory = widget.initialSubCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Main Section Options (Classification)
    final mainSectionOptions = widget.mainSections.map((e) => e.name).toList();

    // 2. Prepare Sub Section Options based on selection (Specialization)
    List<String> subSectionOptions = [];
    if (_selectedMainCategory != null) {
      final selectedMain = widget.mainSections.firstWhere(
        (e) => e.name == _selectedMainCategory,
        orElse: () => const MainSection(id: 0, name: '', subSections: []),
      );
      subSectionOptions = selectedMain.subSections.map((e) => e.name).toList();
    }

    final Widget mainCategoryField = CustomDropdownField(
      label: 'التصنيف',
      options: mainSectionOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedMainCategory,
      onChanged: (val) {
        setState(() {
          _selectedMainCategory = val;
          _selectedSubCategory = null; // Reset sub category
        });
        widget.onMainCategoryChanged?.call(val);
        widget.onSubCategoryChanged?.call(null);
      },
    );

    final Widget subCategoryField = CustomDropdownField(
      label: 'التخصص',
      options: subSectionOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedSubCategory,
      onChanged: (val) {
        setState(() {
          _selectedSubCategory = val;
        });
        widget.onSubCategoryChanged?.call(val);
      },
    );

    final List<Widget> widgets = [mainCategoryField, subCategoryField];

    // 3. Dynamic Attributes (Salary, Contact Via, etc.)
    for (final field in widget.fieldsConfig) {
      // Skip fields that are handled specially or globally (if any)
      // Usually generic attributes have options (dropdown) or null (text)
      if (field.fieldName == 'main_section_id' ||
          field.fieldName == 'sub_section_id') continue;

      if (field.options.isNotEmpty) {
        // Dropdown
        widgets.add(CustomDropdownField(
          label: field.displayName,
          options: field.options.map((e) => e.toString()).toList(),
          isRequired: field.isRequired,
          labelStyle: widget.labelStyle,
          onChanged: (val) {
            if (val != null)
              _attributes[field.fieldName] = val;
            else
              _attributes.remove(field.fieldName);
          },
        ));
      } else {
        // Text/Number Field
        widgets.add(CustomTextField(
          labelText: field.displayName,
          showTopLabel: true,
          labelStyle: widget.labelStyle,
          keyboardType: field.type == 'decimal' || field.type == 'integer'
              ? TextInputType.number
              : TextInputType.text,
          onChanged: (val) {
            if (val.isNotEmpty)
              _attributes[field.fieldName] = val;
            else
              _attributes.remove(field.fieldName);
          },
          validator: (val) {
            if (field.isRequired && (val == null || val.isEmpty)) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
        ));
      }
    }

    return build2ColFormLayout(widgets);
  }
}
