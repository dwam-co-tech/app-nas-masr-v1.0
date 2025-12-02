// ===========================================
// core/data/models/category_fields_response.dart
// ===========================================
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'governorate.dart';
import 'make.dart';
import 'main_section.dart';

class CategoryFieldsResponse {
  final List<CategoryFieldConfig> categoryFields;
  final List<Governorate> governorates;
  final List<Make> makes;
  final bool supportsMakeModel;
  final List<MainSection> mainSections;
  final bool supportsSections;

  const CategoryFieldsResponse({
    required this.categoryFields,
    required this.governorates,
    required this.makes,
    required this.supportsMakeModel,
    required this.mainSections,
    required this.supportsSections,
  });

  factory CategoryFieldsResponse.fromMap(Map<String, dynamic> json) {
    final makesData = json['makes'] as List<dynamic>? ?? [];
    final mainSectionsData = json['main_sections'] as List<dynamic>? ?? [];

    return CategoryFieldsResponse(
      categoryFields: List<CategoryFieldConfig>.from(
        (json['data'] as List<dynamic>? ?? []).where((x) => x is Map).map((x) =>
            CategoryFieldConfig.fromMap(Map<String, dynamic>.from(x as Map))),
      ),
      governorates: List<Governorate>.from(
        (json['governorates'] as List<dynamic>? ?? [])
            .where((x) => x is Map)
            .map((x) =>
                Governorate.fromMap(Map<String, dynamic>.from(x as Map))),
      ),
      // تحويل لقائمة الـ Makes
      makes: makesData
          .where((x) => x is Map)
          .map((x) => Make.fromMap(Map<String, dynamic>.from(x as Map)))
          .toList(),
      supportsMakeModel: json['supports_make_model'] as bool? ?? false,
      mainSections: mainSectionsData
          .where((x) => x is Map)
          .map((x) => MainSection.fromMap(Map<String, dynamic>.from(x as Map)))
          .toList(),
      supportsSections: json['supports_sections'] as bool? ?? false,
    );
  }
}
