import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/main_section.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/create_Ads/form_layout_builder.dart';

class UnifiedCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final List<MainSection> mainSections;
  final TextStyle? labelStyle;
  final ValueChanged<String?>? onMainCategoryChanged;
  final ValueChanged<String?>? onSubCategoryChanged;
  final String? initialMainCategory;
  final String? initialSubCategory;

  const UnifiedCreationForm({
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
  State<UnifiedCreationForm> createState() => _UnifiedCreationFormState();
}

class _UnifiedCreationFormState extends State<UnifiedCreationForm> {
  String? _selectedMainCategory;
  String? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _selectedMainCategory = widget.initialMainCategory;
    _selectedSubCategory = widget.initialSubCategory;
  }

  @override
  void didUpdateWidget(covariant UnifiedCreationForm oldWidget) {
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
    // 1. Prepare Main Section Options
    final mainSectionOptions = widget.mainSections.map((e) => e.name).toList();

    // 2. Prepare Sub Section Options based on selection
    List<String> subSectionOptions = [];
    if (_selectedMainCategory != null) {
      final selectedMain = widget.mainSections.firstWhere(
        (e) => e.name == _selectedMainCategory,
        orElse: () => const MainSection(id: 0, name: '', subSections: []),
      );
      subSectionOptions = selectedMain.subSections.map((e) => e.name).toList();
    }

    final Widget mainCategoryField = CustomDropdownField(
      label: 'القسم الرئيسي',
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
      label: 'القسم الفرعي',
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

    return build2ColFormLayout(widgets);
  }
}
