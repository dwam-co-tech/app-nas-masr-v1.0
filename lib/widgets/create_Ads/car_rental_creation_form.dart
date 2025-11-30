import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/make.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';

class CarRentalCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final List<Make> makes;
  final TextStyle? labelStyle;
  final String? initialMake;
  final String? initialModel;
  final String? initialYear;
  final String? initialDriverOption;
  final ValueChanged<String?>? onMakeChanged;
  final ValueChanged<String?>? onModelChanged;
  final ValueChanged<String?>? onTitleChanged;

  const CarRentalCreationForm({
    super.key,
    required this.fieldsConfig,
    required this.makes,
    this.labelStyle,
    this.initialMake,
    this.initialModel,
    this.initialYear,
    this.initialDriverOption,
    this.onMakeChanged,
    this.onModelChanged,
    this.onTitleChanged,
  });

  @override
  State<CarRentalCreationForm> createState() => CarRentalCreationFormState();
}

class CarRentalCreationFormState extends State<CarRentalCreationForm> {
  CategoryFieldConfig? _getField(String fieldName) => widget.fieldsConfig
      .cast<CategoryFieldConfig?>()
      .firstWhere((f) => f?.fieldName == fieldName, orElse: () => null);

  String? _selectedMake;
  String? _selectedModel;
  String? _year;
  String? _driver;

  @override
  void initState() {
    super.initState();
    _selectedMake = widget.initialMake;
    _selectedModel = widget.initialModel;
    _year = widget.initialYear;
    _driver = widget.initialDriverOption;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> makeOptions = widget.makes.map((m) => m.name).toList();
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

    final List<String> yearOptions =
        _getField('year')?.options.map((e) => e.toString()).toList() ??
            const <String>[];
    final Widget yearField = CustomDropdownField(
      label: 'السنة',
      options: yearOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _year,
      onChanged: (val) {
        setState(() => _year = val);
        _emitTitle();
      },
    );

    final Widget driverField = CustomDropdownField(
      label: 'السائق',
      options: const ['بسائق', 'بدون سائق'],
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _driver,
      onChanged: (val) {
        setState(() => _driver = val);
        _emitTitle();
      },
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: makeField),
            const SizedBox(width: 12),
            Expanded(child: modelField),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: yearField),
            const SizedBox(width: 12),
            Expanded(child: driverField),
          ],
        ),
      ],
    );
  }

  void _emitTitle() {
    final parts = <String>[];
    if (_selectedMake != null && _selectedMake!.trim().isNotEmpty) {
      parts.add(_selectedMake!.trim());
    }
    if (_selectedModel != null && _selectedModel!.trim().isNotEmpty) {
      parts.add(_selectedModel!.trim());
    }
    if (_year != null && _year!.trim().isNotEmpty) {
      parts.add(_year!.trim());
    }
    if (_driver != null && _driver!.trim().isNotEmpty) {
      parts.add(_driver!.trim());
    }

    final title = parts.join(' - ');
    if (title.trim().isEmpty) return;
    widget.onTitleChanged?.call(title);
  }

  Map<String, String?> getSelectedAttributes() {
    return {
      'year': _year,
      'driver_option': _driver,
    };
  }

  String? get selectedMake => _selectedMake;
  String? get selectedModel => _selectedModel;
}
