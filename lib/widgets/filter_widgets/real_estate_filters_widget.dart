import 'package:flutter/material.dart';
import 'package:nas_masr_app/screens/public/filtered_ads_screen.dart';
import 'package:provider/provider.dart';
import '../../core/data/models/All_filter_response.dart';
import '../../core/data/models/filter_options.dart';
import '../../../core/data/models/governorate.dart';
import '../../../core/data/models/city.dart';
import '../../../core/data/providers/category_listing_provider.dart';
// Note: filtered_ads_screen.dart لا يتم عمل Import له هنا لتجنب التكرار في Imports (يتم في CategoryListingScreen)
import 'filter_dropdown_button.dart';
import 'filter_options_modal.dart';

class RealEstateFiltersWidget extends StatelessWidget {
  final CategoryFieldsResponse config;
  final Function(String key, dynamic value)
      onNavigate; // الدالة اللي بـ perform الـ Navigation

  const RealEstateFiltersWidget({
    super.key,
    required this.config,
    required this.onNavigate, // نستخدمها هنا
  });

  // دالة تُجهز بيانات العرض لـ Modal و تتلقى الـ Action (المختصر)
  void _openFilterModal(BuildContext context, String filterKey, String label,
      List<dynamic> optionsToDisplay) {
    // الطباعة قبل فتح الـ Modal (كالعادة)
    print('--- Filter Action ---');
    print('Opening modal for $label (Key: $filterKey)');
    print('Options Count: ${optionsToDisplay.length}');
    print('---------------------');

    // B. الكود الفعلي لفتح الـ Modal (مفصول عن الدالة الأساسية لتجنب التعقيد)
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
              options: optionsToDisplay,
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

  CategoryFieldConfig? _getCustomField(String fieldName) {
    try {
      return config.categoryFields
          .firstWhere((field) => field.fieldName == fieldName);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CategoryListingProvider>(context, listen: true);
    final propertyType = _getCustomField('property_type');
    final contractType = _getCustomField('contract_type');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // الصف الأول (المحافظة / المدينة)
          Row(
            children: [
              FilterDropdownButton(
                label: config.governorates.isNotEmpty
                    ? 'المحافظة'
                    : 'الموقع غير متوفر',
                onTap: () => _openFilterModal(
                    context, 'governorate_id', 'المحافظة', config.governorates),
                isSelected: provider.isFilterSelected('governorate_id'),
                selectedValue:
                    provider.selectedFilters['governorate_id']?.toString(),
              ),
              FilterDropdownButton(
                label: 'المدينة',
                onTap: () {
                  // الـ Logic هنا لا يزال بسيط (نجمع كل المدن من كل المحافظات لقائمة واحدة مؤقتة)
                  final allCities =
                      config.governorates.expand((g) => g.cities).toList();
                  _openFilterModal(context, 'city_id', 'المدينة', allCities);
                },
                isSelected: provider.isFilterSelected('city_id'),
                selectedValue: provider.selectedFilters['city_id']?.toString(),
              ),
            ],
          ),

          // الصف الثاني (نوع العقد / نوع العقار)
          Row(
            children: [
              if (contractType != null)
                FilterDropdownButton(
                  label: contractType.displayName,
                  // هذا الفلتر لم يكن يُمرر قائمة الـ Options، لكن الآن أصبح صحيحاً
                  onTap: () => _openFilterModal(context, contractType.fieldName,
                      contractType.displayName, contractType.options),
                  isSelected: provider.isFilterSelected(contractType.fieldName),
                  selectedValue: provider
                      .selectedFilters[contractType.fieldName]
                      ?.toString(),
                ),
              if (propertyType != null)
                FilterDropdownButton(
                  label: propertyType.displayName,
                  onTap: () => _openFilterModal(context, propertyType.fieldName,
                      propertyType.displayName, propertyType.options),
                  isSelected: provider.isFilterSelected(propertyType.fieldName),
                  selectedValue: provider
                      .selectedFilters[propertyType.fieldName]
                      ?.toString(),
                ),
              if (contractType == null || propertyType == null)
                const Spacer(flex: 1),
            ],
          ),

          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
