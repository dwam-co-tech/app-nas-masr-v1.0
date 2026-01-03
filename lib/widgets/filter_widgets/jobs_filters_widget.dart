import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';

class JobsFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value) onNavigate;

  const JobsFiltersWidget({
    super.key,
    required this.config,
    required this.onNavigate,
  });

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

  // Helper method to get custom field by name
  List<String> _getFieldOptions(String fieldName) {
    try {
      final field = config.categoryFields.firstWhere(
        (f) => f.fieldName == fieldName,
        orElse: () => config.categoryFields.first,
      );

      if (field.fieldName == fieldName && field.options.isNotEmpty) {
        return field.options.map((opt) => opt.toString()).toList();
      }
    } catch (e) {
      print('Error getting field options for $fieldName: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CategoryListingProvider>(context, listen: true);

    print(
        'DEBUG: JobsFiltersWidget build. Govs: ${config.governorates.length}, Fields: ${config.categoryFields.length}');

    // 1. Location Filters
    final governorates = config.governorates;

    // Logic for Cities: Dependent on Governorate
    List<dynamic> cities = [];
    final selectedGovId = provider.selectedFilters['governorate_id'];
    bool isCityEnabled = false;

    if (selectedGovId != null) {
      // Find the selected governorate object
      try {
        // Try to parse as ID first
        final govIdInt = int.tryParse(selectedGovId.toString());
        if (govIdInt != null) {
          final selectedGov = governorates.firstWhere((g) => g.id == govIdInt,
              orElse: () => governorates.first);
          // Verify if we actually found it by ID
          if (selectedGov.id == govIdInt) {
            cities = selectedGov.cities;
            isCityEnabled = true;
          }
        }

        // If not found by ID or parsing failed, try by Name
        if (!isCityEnabled) {
          final selectedGov = governorates.firstWhere(
              (g) => g.name == selectedGovId.toString(),
              orElse: () => governorates.first);
          if (selectedGov.name == selectedGovId.toString()) {
            cities = selectedGov.cities;
            isCityEnabled = true;
          }
        }
      } catch (e) {
        cities = [];
      }
    }

    // 2. Get Custom Fields Options (Independent Fields)
    final jobTypeOptions = _getFieldOptions('job_type');
    final specializationOptions = _getFieldOptions('specialization');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // Row 1: Location
          Row(
            children: [
              FilterDropdownButton(
                label: 'المحافظة',
                onTap: () => _openFilterModal(
                    context, 'governorate_id', 'المحافظة', governorates),
                isSelected: provider.isFilterSelected('governorate_id'),
                selectedValue:
                    provider.selectedFilters['governorate_id']?.toString(),
              ),
              FilterDropdownButton(
                label: 'المدينة',
                onTap: isCityEnabled
                    ? () =>
                        _openFilterModal(context, 'city_id', 'المدينة', cities)
                    : null,
                isSelected: provider.isFilterSelected('city_id'),
                selectedValue: provider.selectedFilters['city_id']?.toString(),
              ),
            ],
          ),

          // Row 2: Job Type & Specialization (Independent Custom Fields)
          if (jobTypeOptions.isNotEmpty || specializationOptions.isNotEmpty)
            Row(
              children: [
                // Job Type Filter
                if (jobTypeOptions.isNotEmpty)
                  FilterDropdownButton(
                    label: 'التصنيف',
                    onTap: () => _openFilterModal(
                      context,
                      'job_type',
                      'التصنيف',
                      jobTypeOptions,
                    ),
                    isSelected: provider.isFilterSelected('job_type'),
                    selectedValue:
                        provider.selectedFilters['job_type']?.toString(),
                  ),

                // Specialization Filter (Independent - Always Enabled)
                if (specializationOptions.isNotEmpty)
                  FilterDropdownButton(
                    label: 'التخصص',
                    onTap: () => _openFilterModal(
                      context,
                      'specialization',
                      'التخصص',
                      specializationOptions,
                    ),
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
