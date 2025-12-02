// widgets/filters/doctors_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';

class DoctorsFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value) onNavigate;

  const DoctorsFiltersWidget(
      {super.key, required this.config, required this.onNavigate});

  void _openFilterModal(BuildContext context, String filterKey, String label,
      List<dynamic> options) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        return FractionallySizedBox(
          heightFactor: keyboardOpen ? 1 : 0.7,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: FilterOptionsModal(
              title: 'اختر $label',
              options: options,
              showAllOption: true,
              onSelected: (selectedValue) {
                onNavigate(filterKey, selectedValue);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CategoryListingProvider>(context, listen: true);

    // Specialization Logic
    CategoryFieldConfig? specializationField;
    try {
      specializationField = config.categoryFields
          .firstWhere((f) => f.fieldName == 'specialization');
    } catch (_) {}

    final List<dynamic> specializationOptions =
        specializationField?.options ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // Row 1: Governorate & City
          Row(
            children: [
              FilterDropdownButton(
                label: 'المحافظة',
                onTap: () => _openFilterModal(
                    context, 'governorate_id', 'المحافظة', config.governorates),
                isSelected: provider.isFilterSelected('governorate_id'),
                selectedValue:
                    provider.selectedFilters['governorate_id']?.toString(),
              ),
              FilterDropdownButton(
                label: 'المدينة',
                onTap: () {
                  final allCities =
                      config.governorates.expand((g) => g.cities).toList();
                  _openFilterModal(context, 'city_id', 'المدينة', allCities);
                },
                isSelected: provider.isFilterSelected('city_id'),
                selectedValue: provider.selectedFilters['city_id']?.toString(),
              ),
            ],
          ),

          // Row 2: Specialization
          Row(
            children: [
              FilterDropdownButton(
                label: 'التخصص',
                onTap: () => _openFilterModal(
                    context, 'specialization', 'التخصص', specializationOptions),
                isSelected: provider.isFilterSelected('specialization'),
                selectedValue:
                    provider.selectedFilters['specialization']?.toString(),
              ),
            ],
          ),

          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
