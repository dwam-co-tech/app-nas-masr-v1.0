// ===========================================
// core/data/models/category_fields_response.dart
// ===========================================
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'governorate.dart';
import 'make.dart'; 

class CategoryFieldsResponse {
  final List<CategoryFieldConfig> categoryFields; 
  final List<Governorate> governorates;          
  final List<Make> makes;                        
  final bool supportsMakeModel;                 

  const CategoryFieldsResponse({
    required this.categoryFields,
    required this.governorates,
    required this.makes,                       
    required this.supportsMakeModel,
  });

  factory CategoryFieldsResponse.fromMap(Map<String, dynamic> json) {
    final makesData = json['makes'] as List<dynamic>? ?? [];
    
    return CategoryFieldsResponse(
      categoryFields: List<CategoryFieldConfig>.from(
        (json['data'] as List<dynamic>? ?? []).map((x) => CategoryFieldConfig.fromMap(x as Map<String, dynamic>)),
      ),
      governorates: List<Governorate>.from(
        (json['governorates'] as List<dynamic>? ?? []).map((x) => Governorate.fromMap(x as Map<String, dynamic>)),
      ),
      // تحويل لقائمة الـ Makes
      makes: makesData.map((x) => Make.fromMap(x as Map<String, dynamic>)).toList(),
      supportsMakeModel: json['supports_make_model'] as bool,
    );
  }
}