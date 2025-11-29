// widgets/forms/car_creation_form.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/make.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/create_Ads/form_layout_builder.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
// Imports for the widgets/tools it needs

class CarCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final List<Make> makes;
  final TextStyle? labelStyle;
  final String? initialMake;
  final String? initialModel;
  final ValueChanged<String?>? onMakeChanged;
  final ValueChanged<String?>? onModelChanged;
  final ValueChanged<String?>? onTitleChanged;

  const CarCreationForm(
      {super.key,
      required this.fieldsConfig,
      required this.makes,
      this.labelStyle,
      this.initialMake,
      this.initialModel,
      this.onMakeChanged,
      this.onModelChanged,
      this.onTitleChanged});

  @override
  State<CarCreationForm> createState() => CarCreationFormState();
}

class CarCreationFormState extends State<CarCreationForm> {
  CategoryFieldConfig? _getField(String fieldName) => widget.fieldsConfig
      .cast<CategoryFieldConfig?>()
      .firstWhere((f) => f?.fieldName == fieldName, orElse: () => null);

  String? _selectedMake;
  String? _selectedModel;
  String? _year;
  String? _mileage;
  String? _type;
  String? _color;
  String? _transmission;
  String? _fuelType;

  @override
  void initState() {
    super.initState();
    _selectedMake = widget.initialMake;
    _selectedModel = widget.initialModel;
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

    final List<String> mileageOptions = _getField('mileage_range')
            ?.options
            .map((e) => e.toString())
            .toList() ??
        _getField('kilometers')?.options.map((e) => e.toString()).toList() ??
        _getField('kilometer')?.options.map((e) => e.toString()).toList() ??
        _getField('mileage')?.options.map((e) => e.toString()).toList() ??
        const <String>[];
    final Widget kilometerField = CustomDropdownField(
      label: 'الكيلو متر',
      options: mileageOptions,
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _mileage,
      onChanged: (val) {
        setState(() => _mileage = val);
        _emitTitle();
      },
    );

    final Widget typeField = CustomDropdownField(
      label: 'النوع',
      options: _getField('body_type')
              ?.options
              .map((e) => e.toString())
              .toList() ??
          _getField('type')?.options.map((e) => e.toString()).toList() ??
          _getField('car_type')?.options.map((e) => e.toString()).toList() ??
          const <String>[],
      isRequired: false,
      labelStyle: widget.labelStyle,
      initialValue: _type,
      onChanged: (val) {
        setState(() => _type = val);
        _emitTitle();
      },
    );

    final Widget exteriorColorField = CustomDropdownField(
      label: 'اللون الخارجي',
      options: _getField('exterior_color')
              ?.options
              .map((e) => e.toString())
              .toList() ??
          _getField('color')?.options.map((e) => e.toString()).toList() ??
          const <String>[],
      isRequired: false,
      labelStyle: widget.labelStyle,
      initialValue: _color,
      onChanged: (val) {
        setState(() => _color = val);
        _emitTitle();
      },
    );

    final Widget transmissionField = CustomDropdownField(
      label: 'الفتيس',
      options: _getField('transmission')
              ?.options
              .map((e) => e.toString())
              .toList() ??
          const <String>[],
      isRequired: false,
      labelStyle: widget.labelStyle,
      initialValue: _transmission,
      onChanged: (val) {
        setState(() => _transmission = val);
        _emitTitle();
      },
    );

    final Widget fuelTypeField = CustomDropdownField(
      label: 'نوع الوقود',
      options:
          _getField('fuel_type')?.options.map((e) => e.toString()).toList() ??
              const <String>[],
      isRequired: true,
      labelStyle: widget.labelStyle,
      initialValue: _fuelType,
      onChanged: (val) {
        setState(() => _fuelType = val);
        _emitTitle();
      },
    );

    final List<Widget> carFormWidgets = [
      makeField,
      modelField,
      yearField,
      kilometerField,
      typeField,
      exteriorColorField,
      transmissionField,
      fuelTypeField,
    ];

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
            Expanded(child: kilometerField),
            const SizedBox(width: 12),
            Expanded(child: typeField),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: exteriorColorField),
            const SizedBox(width: 12),
            Expanded(child: transmissionField),
            const SizedBox(width: 12),
            Expanded(child: fuelTypeField),
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
    final head = parts.join(' ');
    final attrs = <String>[];
    if (_mileage != null && _mileage!.trim().isNotEmpty) {
      final mil = _mileage!.trim();
      final isNum = double.tryParse(mil) != null;
      attrs.add(isNum ? '$mil كم' : mil);
    }
    if (_transmission != null && _transmission!.trim().isNotEmpty) {
      attrs.add(_transmission!.trim());
    }
    if (_fuelType != null && _fuelType!.trim().isNotEmpty) {
      attrs.add(_fuelType!.trim());
    }
    if (_type != null && _type!.trim().isNotEmpty) {
      attrs.add(_type!.trim());
    }
    if (_color != null && _color!.trim().isNotEmpty) {
      attrs.add(_color!.trim());
    }
    final title = [head, if (attrs.isNotEmpty) attrs.join('، ')].join(' - ');
    // تجاهل العنوان الفارغ
    if (title.trim().isEmpty) return;
    // إشعار الشاشة الأم
    (widget.onTitleChanged)?.call(title);
  }

  Map<String, String?> getSelectedAttributes() {
    String mileageKey = _getField('mileage_range') != null
        ? 'mileage_range'
        : (_getField('kilometer') != null
            ? 'kilometer'
            : (_getField('kilometers') != null
                ? 'kilometers'
                : (_getField('mileage') != null ? 'mileage' : 'kilometers')));
    String typeKey = _getField('body_type') != null
        ? 'body_type'
        : (_getField('type') != null
            ? 'type'
            : (_getField('car_type') != null ? 'car_type' : 'type'));
    String colorKey = _getField('exterior_color') != null
        ? 'exterior_color'
        : (_getField('color') != null ? 'color' : 'exterior_color');
    return {
      'year': _year,
      mileageKey: _mileage,
      typeKey: _type,
      colorKey: _color,
      'transmission': _transmission,
      'fuel_type': _fuelType,
    };
  }

  String? get selectedMake => _selectedMake;
  String? get selectedModel => _selectedModel;
}
