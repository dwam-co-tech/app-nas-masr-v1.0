// widgets/filters/car_spare_parts_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/car_model.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';

class CarSparePartsFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value) onNavigate;

  const CarSparePartsFiltersWidget(
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
                if (filterKey == 'make') {
                  Provider.of<CategoryListingProvider>(context, listen: false)
                      .clearFilter('model');
                }
                if (filterKey == 'main_category') {
                  Provider.of<CategoryListingProvider>(context, listen: false)
                      .clearFilter('sub_category');
                }
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

    // Make & Model Logic
    final selectedMakeName = provider.selectedFilters['make']?.toString();
    final List<CarModel> allModels =
        config.makes.expand((m) => m.models).toList();
    final List<CarModel> modelsForSelectedMake = selectedMakeName == null
        ? allModels
        : (config.makes
            .firstWhere((m) => m.name == selectedMakeName,
                orElse: () => config.makes.first)
            .models);

    // Main & Sub Category Logic
    final selectedMainCat =
        provider.selectedFilters['main_category']?.toString();
    CategoryFieldConfig? mainCatField;
    try {
      mainCatField = config.categoryFields
          .firstWhere((f) => f.fieldName == 'main_category');
    } catch (_) {}

    CategoryFieldConfig? subCatField;
    try {
      subCatField = config.categoryFields
          .firstWhere((f) => f.fieldName == 'sub_category');
    } catch (_) {}

    final List<dynamic> mainCategories = mainCatField?.options ?? [];
    final List<dynamic> allSubCategories = subCatField?.options ?? [];

    // Filter sub categories based on main category if needed
    // Assuming sub categories might be linked in a similar way to makes/models
    // or just flat list. For now, we'll treat them as flat unless we have specific logic.
    // If the API returns sub-categories nested, we'd need to handle that.
    // Based on previous Unified logic, they seem to be flat lists in options.
    final List<dynamic> subCategories = allSubCategories;

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

          // Row 2: Make & Model
          Row(
            children: [
              FilterDropdownButton(
                label: 'الماركة',
                onTap: () =>
                    _openFilterModal(context, 'make', 'الماركة', config.makes),
                isSelected: provider.isFilterSelected('make'),
                selectedValue: provider.selectedFilters['make']?.toString(),
              ),
              FilterDropdownButton(
                label: 'الموديل',
                onTap: () => _openFilterModal(
                    context, 'model', 'الموديل', modelsForSelectedMake),
                isSelected: provider.isFilterSelected('model'),
                selectedValue: provider.selectedFilters['model']?.toString(),
              ),
            ],
          ),

          // Row 3: Main & Sub Category
          Row(
            children: [
              FilterDropdownButton(
                label: 'رئيسي',
                onTap: () => _openFilterModal(
                    context, 'main_category', 'القسم الرئيسي', mainCategories),
                isSelected: provider.isFilterSelected('main_category'),
                selectedValue:
                    provider.selectedFilters['main_category']?.toString(),
              ),
              FilterDropdownButton(
                label: 'فرعي',
                onTap: () => _openFilterModal(
                    context, 'sub_category', 'القسم الفرعي', subCategories),
                isSelected: provider.isFilterSelected('sub_category'),
                selectedValue:
                    provider.selectedFilters['sub_category']?.toString(),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
