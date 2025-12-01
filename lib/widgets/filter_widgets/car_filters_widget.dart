// widgets/filters/car_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/car_model.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';

class CarFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value) onNavigate;

  const CarFiltersWidget(
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
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // تم التعديل على الكود لـ 3 صفوف بدلاً من 2، وكل صف فيه فلترين فقط (2 * 3 Layout)

    final provider =
        Provider.of<CategoryListingProvider>(context, listen: true);
    final selectedMakeName = provider.selectedFilters['make']?.toString();
    final List<CarModel> allModels =
        config.makes.expand((m) => m.models).toList();
    final List<CarModel> modelsForSelectedMake = selectedMakeName == null
        ? allModels
        : (config.makes
            .firstWhere((m) => m.name == selectedMakeName,
                orElse: () => config.makes.first)
            .models);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // الصف الأول (2 فلتر)
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

          // الصف الثاني (2 فلتر)
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

          // الصف الثالث (2 فلتر) - للتغطية لبقية الـ 6 فلاتر
          Row(
            children: [
              
               FilterDropdownButton(
                label: 'السنة',
                onTap: () {
                  CategoryFieldConfig? yearField;
                  try {
                    yearField = config.categoryFields
                        .firstWhere((f) => f.fieldName == 'year');
                  } catch (_) {
                    yearField = null;
                  }
                  final options = yearField?.options ?? [];
                  _openFilterModal(context, 'year', 'السنة', options);
                },
                isSelected: provider.isFilterSelected('year'),
                selectedValue: provider.selectedFilters['year']?.toString(),
              ),
           
             
             
              FilterDropdownButton(
                label: 'الكيلومتر',
                onTap: () {
                  CategoryFieldConfig? mileageField;
                  try {
                    mileageField = config.categoryFields
                        .firstWhere((f) => f.fieldName == 'kilometers');
                  } catch (_) {
                    mileageField = null;
                  }
                  final options = mileageField?.options ?? [];
                  _openFilterModal(
                      context, 'kilometers', 'الكيلومتر', options);
                },
                isSelected: provider.isFilterSelected('kilometers'),
                selectedValue:
                    provider.selectedFilters['kilometers']?.toString(),
              ),
            ],
          ),

          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
