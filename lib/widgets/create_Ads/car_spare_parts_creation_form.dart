// widgets/create_Ads/car_spare_parts_creation_form.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/make.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';

class CarSparePartsCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final List<Make> makes;
  final TextStyle? labelStyle;
  final String? initialMainCategory;
  final String? initialSubCategory;
  final String? initialMake;
  final String? initialModel;
  final ValueChanged<String?>? onMainCategoryChanged;
  final ValueChanged<String?>? onSubCategoryChanged;
  final ValueChanged<String?>? onMakeChanged;
  final ValueChanged<String?>? onModelChanged;
  final ValueChanged<String?>? onTitleChanged;

  const CarSparePartsCreationForm({
    super.key,
    required this.fieldsConfig,
    required this.makes,
    this.labelStyle,
    this.initialMainCategory,
    this.initialSubCategory,
    this.initialMake,
    this.initialModel,
    this.onMainCategoryChanged,
    this.onSubCategoryChanged,
    this.onMakeChanged,
    this.onModelChanged,
    this.onTitleChanged,
  });

  @override
  State<CarSparePartsCreationForm> createState() =>
      CarSparePartsCreationFormState();
}

class CarSparePartsCreationFormState extends State<CarSparePartsCreationForm> {
  CategoryFieldConfig? _getField(String fieldName) => widget.fieldsConfig
      .cast<CategoryFieldConfig?>()
      .firstWhere((f) => f?.fieldName == fieldName, orElse: () => null);

  String? _selectedMainCategory;
  String? _selectedSubCategory;
  String? _selectedMake;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _selectedMainCategory = widget.initialMainCategory;
    _selectedSubCategory = widget.initialSubCategory;
    _selectedMake = widget.initialMake;
    _selectedModel = widget.initialModel;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Main Category
    final mainCatFieldConfig = _getField('main_category');
    final List<String> mainCatOptions =
        mainCatFieldConfig?.options.map((e) => e.toString()).toList() ?? [];

    final Widget mainCategoryField = CustomDropdownField(
      label: 'القسم الرئيسي',
      options: mainCatOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedMainCategory,
      onChanged: (val) {
        setState(() {
          _selectedMainCategory = val;
          // Logic to clear sub category if needed, though options are flat currently
        });
        widget.onMainCategoryChanged?.call(val);
        _emitTitle();
      },
    );

    // 2. Sub Category
    final subCatFieldConfig = _getField('sub_category');
    final List<String> subCatOptions =
        subCatFieldConfig?.options.map((e) => e.toString()).toList() ?? [];

    final Widget subCategoryField = CustomDropdownField(
      label: 'القسم الفرعي',
      options: subCatOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedSubCategory,
      onChanged: (val) {
        setState(() => _selectedSubCategory = val);
        widget.onSubCategoryChanged?.call(val);
        _emitTitle();
      },
    );

    // 3. Make
    final List<String> makeOptions = widget.makes.map((m) => m.name).toList();
    final Widget makeField = CustomDropdownField(
      label: 'الماركة',
      options: makeOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedMake,
      onChanged: (val) {
        setState(() {
          _selectedMake = val;
          _selectedModel = null;
        });
        widget.onMakeChanged?.call(val);
        _emitTitle();
      },
    );

    // 4. Model
    final List<String> modelOptions = () {
      if (_selectedMake == null || _selectedMake!.trim().isEmpty) {
        return widget.makes
            .expand((m) => m.models.map((mm) => mm.name))
            .toList();
      }
      try {
        final mk = widget.makes.firstWhere((m) =>
            m.name.trim().toLowerCase() == _selectedMake!.trim().toLowerCase());
        return mk.models.map((mm) => mm.name).toList();
      } catch (_) {
        return const <String>[];
      }
    }();

    final Widget modelField = CustomDropdownField(
      key: ValueKey('model-${_selectedMake ?? 'any'}'),
      label: 'الموديل',
      options: modelOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedModel,
      emptyOptionsHint:
          _selectedMake == null ? 'اختر الماركة أولاً' : 'لا توجد موديلات',
      onChanged: (val) {
        setState(() => _selectedModel = val);
        widget.onModelChanged?.call(val);
        _emitTitle();
      },
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: subCategoryField),
            const SizedBox(width: 12),
            Expanded(child: mainCategoryField),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: makeField),
            const SizedBox(width: 12),
            Expanded(child: modelField),
          ],
        ),
      ],
    );
  }

  void _emitTitle() {
    final parts = <String>[];
    if (_selectedSubCategory != null &&
        _selectedSubCategory!.trim().isNotEmpty) {
      parts.add(_selectedSubCategory!.trim());
    }
    if (_selectedMainCategory != null &&
        _selectedMainCategory!.trim().isNotEmpty) {
      parts.add(_selectedMainCategory!.trim());
    }
    if (_selectedMake != null && _selectedMake!.trim().isNotEmpty) {
      parts.add(_selectedMake!.trim());
    }
    if (_selectedModel != null && _selectedModel!.trim().isNotEmpty) {
      parts.add(_selectedModel!.trim());
    }

    final title = parts.join(' ');
    if (title.trim().isEmpty) return;
    widget.onTitleChanged?.call(title);
  }

  Map<String, String?> getSelectedAttributes() {
    return {
      'main_category': _selectedMainCategory,
      'sub_category': _selectedSubCategory,
    };
  }

  String? get selectedMake => _selectedMake;
  String? get selectedModel => _selectedModel;
}
