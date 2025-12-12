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

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CategoryListingProvider>(context, listen: true);

    print(
        'DEBUG: JobsFiltersWidget build. Govs: ${config.governorates.length}, SupportsSections: ${config.supportsSections}');

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

    // 2. Dynamic Category Filters (Main/Sub Sections)
    // For Jobs: Classification (Main Section) & Specialization (Sub Section)
    final mainSections = config.mainSections;

    // Logic for Sub Sections: Dependent on Main Section
    List<dynamic> subSections = [];
    final selectedMainSectionId = provider.selectedFilters['main_section_id'];
    bool isSubSectionEnabled = false;

    if (selectedMainSectionId != null) {
      try {
        final mainIdInt = int.tryParse(selectedMainSectionId.toString());
        if (mainIdInt != null) {
          final selectedMain = mainSections.firstWhere((m) => m.id == mainIdInt,
              orElse: () => mainSections.first);
          if (selectedMain.id == mainIdInt) {
            subSections = selectedMain.subSections;
            isSubSectionEnabled = true;
          }
        }

        if (!isSubSectionEnabled) {
          final selectedMain = mainSections.firstWhere(
              (m) => m.name == selectedMainSectionId.toString(),
              orElse: () => mainSections.first);
          if (selectedMain.name == selectedMainSectionId.toString()) {
            subSections = selectedMain.subSections;
            isSubSectionEnabled = true;
          }
        }
      } catch (e) {
        subSections = [];
      }
    }

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

          // Row 2: Categories (Classification & Specialization)
          if (config.supportsSections)
            Row(
              children: [
                FilterDropdownButton(
                  label: 'التصنيف',
                  onTap: () => _openFilterModal(
                    context,
                    'main_section_id', // Using _id as per requirement
                    'التصنيف',
                    mainSections,
                  ),
                  isSelected: provider.isFilterSelected('main_section_id'),
                  selectedValue:
                      provider.selectedFilters['main_section_id']?.toString(),
                ),
                FilterDropdownButton(
                  label: 'التخصص',
                  onTap: isSubSectionEnabled
                      ? () => _openFilterModal(
                            context,
                            'sub_section_id', // Using _id as per requirement
                            'التخصص',
                            subSections,
                          )
                      : null,
                  isSelected: provider.isFilterSelected('sub_section_id'),
                  selectedValue:
                      provider.selectedFilters['sub_section_id']?.toString(),
                ),
              ],
            ),

          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
