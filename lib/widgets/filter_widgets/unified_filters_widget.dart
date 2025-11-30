import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';

class UnifiedFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value) onNavigate;

  const UnifiedFiltersWidget({
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

  CategoryFieldConfig? _getField(String fieldName) {
    try {
      return config.categoryFields
          .firstWhere((f) => f.fieldName == fieldName);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CategoryListingProvider>(context, listen: true);

    // 1. Location Filters (Always present)
    final governorates = config.governorates;
    // Simple logic for cities: flatten all cities from all governorates
    // In a real app, you might want to filter cities based on selected governorate
    final allCities = config.governorates.expand((g) => g.cities).toList();

    // 2. Dynamic Category Filters
    final mainCategoryField = _getField('main_category');
    final subCategoryField = _getField('sub_category');

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
                onTap: () => _openFilterModal(
                    context, 'city_id', 'المدينة', allCities),
                isSelected: provider.isFilterSelected('city_id'),
                selectedValue: provider.selectedFilters['city_id']?.toString(),
              ),
            ],
          ),

          // Row 2: Categories
          Row(
            children: [
              if (mainCategoryField != null)
                FilterDropdownButton(
                  label: mainCategoryField.displayName,
                  onTap: () => _openFilterModal(
                    context,
                    mainCategoryField.fieldName,
                    mainCategoryField.displayName,
                    mainCategoryField.options,
                  ),
                  isSelected:
                      provider.isFilterSelected(mainCategoryField.fieldName),
                  selectedValue: provider
                      .selectedFilters[mainCategoryField.fieldName]
                      ?.toString(),
                ),
              if (subCategoryField != null)
                FilterDropdownButton(
                  label: subCategoryField.displayName,
                  onTap: () => _openFilterModal(
                    context,
                    subCategoryField.fieldName,
                    subCategoryField.displayName,
                    subCategoryField.options,
                  ),
                  isSelected:
                      provider.isFilterSelected(subCategoryField.fieldName),
                  selectedValue: provider
                      .selectedFilters[subCategoryField.fieldName]
                      ?.toString(),
                ),
                
               // Spacer if one is missing to keep alignment
               if (mainCategoryField == null || subCategoryField == null)
                 const Spacer(flex: 1),
            ],
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
