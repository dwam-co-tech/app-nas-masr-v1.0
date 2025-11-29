// core/data/models/ad_card_model.dart

class AdCardModel {
  final Map<String, dynamic>
      attributes; // attributes اللي بين الـ attr[] في الـ API
  final int id;
  final String categoryName;
  final String categorySlug;
  final String governorate;
  final String city;
  final String price;
  final String? mainImageUrl;
  final String planType; // free, standard, premium (مهم لتصميم الـ Badge)
  final String? make;
  final String? model;

  final DateTime? createdAt;
  const AdCardModel({
    required this.attributes,
    required this.id,
    required this.categoryName,
    required this.categorySlug,
    required this.governorate,
    required this.city,
    required this.price,
    this.mainImageUrl,
    required this.planType,
    this.make,
    this.model,
    this.createdAt,
  });

  factory AdCardModel.fromMap(Map<String, dynamic> json) {
    final createdAtStr = json['created_at'] as String?;
    return AdCardModel(
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryName: json['category_name'] as String? ?? 'غير محدد',
      categorySlug: json['category'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      city: json['city'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      mainImageUrl: json['main_image_url'] as String?,
      planType: json['plan_type'] as String? ?? 'free',
      make: json['make'] as String?,
      model: json['model'] as String?,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
    );
  }
}
