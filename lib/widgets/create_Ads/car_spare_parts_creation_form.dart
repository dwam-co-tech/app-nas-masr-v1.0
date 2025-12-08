// widgets/create_Ads/car_spare_parts_creation_form.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/make.dart';
import 'package:nas_masr_app/core/data/models/main_section.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';

class CarSparePartsCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final List<Make> makes;
  final List<MainSection> mainSections;
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
    this.mainSections = const [],
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
    final List<String> mainCatOptions =
        widget.mainSections.map((e) => e.name).toList();

    final Widget mainCategoryField = CustomDropdownField(
      label: 'القسم الرئيسي',
      options: mainCatOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedMainCategory,
      onChanged: (val) {
        setState(() {
          _selectedMainCategory = val;
          _selectedSubCategory = null;
        });
        widget.onMainCategoryChanged?.call(val);
        widget.onSubCategoryChanged?.call(null);
        _emitTitle();
      },
    );

    // 2. Sub Category
    final List<String> subCatOptions = () {
      if (_selectedMainCategory == null ||
          _selectedMainCategory!.trim().isEmpty) {
        return const <String>[];
      }
      try {
        final main = widget.mainSections.firstWhere(
          (e) => e.name == _selectedMainCategory,
          orElse: () => const MainSection(id: 0, name: '', subSections: []),
        );
        return main.subSections.map((e) => e.name).toList();
      } catch (_) {
        return const <String>[];
      }
    }();

    final Widget subCategoryField = CustomDropdownField(
      label: 'القسم الفرعي',
      options: subCatOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _selectedSubCategory,
      enabled: _selectedMainCategory != null &&
          _selectedMainCategory!.trim().isNotEmpty,
      onDisabledTap: () {
        if (_selectedMainCategory == null ||
            _selectedMainCategory!.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى اختيار القسم الرئيسي أولاً'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
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
        return const <String>[];
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
      enabled: _selectedMake != null && _selectedMake!.trim().isNotEmpty,
      onDisabledTap: () {
        if (_selectedMake == null || _selectedMake!.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى اختيار الماركة أولاً'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
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
            Expanded(child: mainCategoryField),
            const SizedBox(width: 12),
            Expanded(child: subCategoryField),
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
      'main_section': _selectedMainCategory,
      'sub_section': _selectedSubCategory,
    };
  }

  String? get selectedMake => _selectedMake;
  String? get selectedModel => _selectedModel;
}
