// ===========================================
// core/data/models/category_field_config.dart
// ===========================================
class CategoryFieldConfig {
  final int id;
  final String fieldName;       // field_name: year, property_type
  final String displayName;     // display_name: السنة، نوع العقار
  final String type;            // نوع القيمة: string، integer، إلخ.
  final bool isRequired;
  final bool isFilterable;
  final List<dynamic> options;   // <-- dynamic: للتعامل مع النصوص والأرقام (1990 أو "فيلا")

  const CategoryFieldConfig({
    required this.id,
    required this.fieldName,
    required this.displayName,
    required this.type,
    required this.isRequired,
    required this.isFilterable,
    required this.options,
  });

  factory CategoryFieldConfig.fromMap(Map<String, dynamic> json) {
    return CategoryFieldConfig(
      id: json['id'] as int,
      fieldName: json['field_name'] as String,
      displayName: json['display_name'] as String,
      type: json['type'] as String,
      isRequired: json['required'] as bool,
      isFilterable: json['filterable'] as bool,
      // تأكيد أن تكون List<dynamic> لاستيعاب الأرقام والنصوص في قائمة الـ Options
      options: List<dynamic>.from(json['options'] as List<dynamic>? ?? []),
    );
  }
}