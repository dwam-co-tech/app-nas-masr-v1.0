// widgets/filters/car_spare_parts_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/car_model.dart';
import 'package:nas_masr_app/core/data/models/main_section.dart';

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

    final List<CarModel> modelsForSelectedMake = selectedMakeName == null
        ? []
        : (config.makes
            .firstWhere((m) => m.name == selectedMakeName,
                orElse: () => config.makes.first)
            .models);

    // Main & Sub Category Logic
    // Main & Sub Category Logic
    final selectedMainCat =
        provider.selectedFilters['main_category']?.toString();

    final List<dynamic> mainCategories =
        config.mainSections.map((e) => e.name).toList();

    final List<dynamic> subCategories = () {
      if (selectedMainCat == null) return [];
      try {
        final main = config.mainSections.firstWhere(
            (e) => e.name == selectedMainCat,
            orElse: () => const MainSection(id: 0, name: '', subSections: []));
        return main.subSections.map((e) => e.name).toList();
      } catch (_) {
        return [];
      }
    }();

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
                onTap: () {
                  if (selectedMakeName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى اختيار الماركة أولاً'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  _openFilterModal(
                      context, 'model', 'الموديل', modelsForSelectedMake);
                },
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
                onTap: () {
                  if (selectedMainCat == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى اختيار القسم الرئيسي أولاً'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  _openFilterModal(
                      context, 'sub_category', 'القسم الفرعي', subCategories);
                },
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
