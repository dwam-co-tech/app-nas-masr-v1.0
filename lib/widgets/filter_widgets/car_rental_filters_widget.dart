import 'package:flutter/material.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_dropdown_button.dart';
import 'package:nas_masr_app/widgets/filter_widgets/filter_options_modal.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/car_model.dart';
import 'package:nas_masr_app/core/data/models/make.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/providers/category_listing_provider.dart';

class CarRentalFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value) onNavigate;

  const CarRentalFiltersWidget(
      {super.key, required this.config, required this.onNavigate});

  void _openFilterModal(BuildContext context, String filterKey, String label,
      List<dynamic> options) {
    final listingProvider =
        Provider.of<CategoryListingProvider>(context, listen: false);
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
                  listingProvider.clearFilter('model');
                }
                if (filterKey == 'governorate_id') {
                  listingProvider.clearFilter('city_id');
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
    final makeVal = provider.selectedFilters['make'];
    final selectedMakeName =
        makeVal is Make ? makeVal.name : makeVal?.toString();

    final List<CarModel> modelsForSelectedMake = selectedMakeName == null
        ? []
        : (config.makes
            .firstWhere((m) => m.name == selectedMakeName,
                orElse: () => config.makes.first)
            .models);

    final governorates = config.governorates;
    List<dynamic> cities = [];
    final selectedGovId = provider.selectedFilters['governorate_id'];
    bool isCityEnabled = false;

    if (selectedGovId != null) {
      try {
        final govIdInt = int.tryParse(selectedGovId.toString());
        if (govIdInt != null) {
          final selectedGov = governorates.firstWhere((g) => g.id == govIdInt,
              orElse: () => governorates.first);
          if (selectedGov.id == govIdInt) {
            cities = selectedGov.cities;
            isCityEnabled = true;
          }
        }
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // Row 1: Governorate, City
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
                onTap: isCityEnabled
                    ? () => _openFilterModal(
                        context, 'city_id', 'المدينة', cities)
                    : null,
                isSelected: provider.isFilterSelected('city_id'),
                selectedValue: provider.selectedFilters['city_id']?.toString(),
              ),
            ],
          ),

          // Row 2: Make, Model
          Row(
            children: [
              FilterDropdownButton(
                label: 'الماركة',
                onTap: () =>
                    _openFilterModal(context, 'make', 'الماركة', config.makes),
                isSelected: provider.isFilterSelected('make'),
                selectedValue: selectedMakeName,
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
                selectedValue: (() {
                  final mv = provider.selectedFilters['model'];
                  return mv is CarModel ? mv.name : mv?.toString();
                })(),
              ),
            ],
          ),

          // Row 3: Year, Driver
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
                label: 'السائق',
                onTap: () {
                  final options = ['بسائق', 'بدون سائق'];
                  _openFilterModal(context, 'driver', 'السائق', options);
                },
                isSelected: provider.isFilterSelected('driver'),
                selectedValue: provider.selectedFilters['driver']?.toString(),
              ),
            ],
          ),

          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
