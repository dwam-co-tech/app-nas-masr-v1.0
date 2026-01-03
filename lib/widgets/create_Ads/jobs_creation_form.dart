import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/create_Ads/form_layout_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobsCreationForm extends StatefulWidget {
  final List<CategoryFieldConfig> fieldsConfig;
  final TextStyle? labelStyle;

  const JobsCreationForm({
    super.key,
    required this.fieldsConfig,
    this.labelStyle,
  });

  @override
  State<JobsCreationForm> createState() => JobsCreationFormState();
}

class JobsCreationFormState extends State<JobsCreationForm> {
  final Map<String, String> _attributes = {};

  Map<String, String> getAttributes() => _attributes;

  @override
  Widget build(BuildContext context) {
    final List<Widget> gridWidgets = [];
    Widget? salaryField;
    Widget? contactViaField;

    // Process all fields dynamically from fieldsConfig
    for (final field in widget.fieldsConfig) {
      // Handle salary and contact_via separately for special layout
      if (field.fieldName == 'salary' || field.fieldName == 'contact_via') {
        Widget fieldWidget;

        if (field.options.isNotEmpty) {
          fieldWidget = CustomDropdownField(
            label: field.displayName,
            options: field.options.map((e) => e.toString()).toList(),
            isRequired: field.isRequired,
            labelStyle: field.fieldName == 'contact_via'
                ? widget.labelStyle?.copyWith(
                    fontSize: (widget.labelStyle?.fontSize ?? 16) + 2,
                  )
                : widget.labelStyle,
            onChanged: (val) {
              if (val != null) {
                _attributes[field.fieldName] = val;
              } else {
                _attributes.remove(field.fieldName);
              }
            },
          );
        } else {
          fieldWidget = CustomTextField(
            labelText: field.displayName,
            showTopLabel: true,
            labelStyle: field.fieldName == 'contact_via'
                ? widget.labelStyle?.copyWith(
                    fontSize: (widget.labelStyle?.fontSize ?? 16) + 2,
                  )
                : widget.labelStyle,
            keyboardType: field.type == 'decimal' || field.type == 'integer'
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (val) {
              if (val.isNotEmpty) {
                _attributes[field.fieldName] = val;
              } else {
                _attributes.remove(field.fieldName);
              }
            },
            validator: (val) {
              if (field.isRequired && (val == null || val.isEmpty)) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            },
          );
        }

        if (field.fieldName == 'salary') {
          salaryField = fieldWidget;
        } else {
          contactViaField = fieldWidget;
        }
        continue;
      }

      // Handle all other fields (including job_type and specialization)
      if (field.options.isNotEmpty) {
        // Dropdown field
        gridWidgets.add(CustomDropdownField(
          label: field.displayName,
          options: field.options.map((e) => e.toString()).toList(),
          isRequired: field.isRequired,
          labelStyle: widget.labelStyle,
          onChanged: (val) {
            if (val != null) {
              _attributes[field.fieldName] = val;
            } else {
              _attributes.remove(field.fieldName);
            }
          },
        ));
      } else {
        // Text/Number Field
        gridWidgets.add(CustomTextField(
          labelText: field.displayName,
          showTopLabel: true,
          labelStyle: widget.labelStyle,
          keyboardType: field.type == 'decimal' || field.type == 'integer'
              ? TextInputType.number
              : TextInputType.text,
          onChanged: (val) {
            if (val.isNotEmpty) {
              _attributes[field.fieldName] = val;
            } else {
              _attributes.remove(field.fieldName);
            }
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

    // Build the final layout
    final List<Widget> children = [
      build2ColFormLayout(gridWidgets),
    ];

    // Add salary and contact_via in special layout if they exist
    if (salaryField != null || contactViaField != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Expanded(flex: 1, child: salaryField ?? const SizedBox.shrink()),
              SizedBox(width: 8.w),
              Expanded(
                  flex: 2, child: contactViaField ?? const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

    return Column(children: children);
  }
}
