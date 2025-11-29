// core/data/models/ad_details_model.dart

class AdDetailsModel {
  final int id;
  final String title;
  final String price;
  final String description;
  final String categorySlug;
  final String governorate;
  final String city;
  final String planType; // free, premium
  final String? mainImageUrl;
  final List<String> imagesUrls;
  final Map<String, dynamic>
      attributes; // الخصائص المُتغيرة مثل (contract_type: إيجار)
  final String contactPhone;
  final String? whatsappPhone;
  final DateTime? createdAt;
  final double? lat;
  final double? lng;
  final String address;
  final int? sellerId;
  final String? sellerName;
  final DateTime? sellerJoinedAt;
  final String? sellerJoinedAtHuman;
  final int? sellerListingsCount;
  final String? banner;

  const AdDetailsModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.categorySlug,
    required this.governorate,
    required this.city,
    required this.planType,
    required this.attributes,
    required this.contactPhone,
    this.whatsappPhone,
    this.mainImageUrl,
    this.imagesUrls = const [],
    this.createdAt,
    this.lat,
    this.lng,
    required this.address,
    this.sellerId,
    this.sellerName,
    this.sellerJoinedAt,
    this.sellerJoinedAtHuman,
    this.sellerListingsCount,
    this.banner
  });

  factory AdDetailsModel.fromMap(Map<String, dynamic> json) {
    // التأكد من استخراج البيانات بطريقة آمنة
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final createdAtStr = data['created_at'] as String?;
    final user = json['user'] as Map<String, dynamic>?;
    final joinedAtStr = user != null ? user['joined_at'] as String? : null;

    return AdDetailsModel(
      address: data['address'] as String? ?? 'ismailia',
      id: data['id'] as int,
      title: data['title'] as String? ?? 'إعلان غير معنون',
      price: '${data['price']}', // دمج السعر مع العملة
      description: data['description'] as String? ?? 'لا يوجد وصف متاح.',
      categorySlug: data['category'] as String,
      governorate: data['governorate'] as String? ?? '',
      city: data['city'] as String? ?? '',
      planType: data['plan_type'] as String? ?? 'free',
      attributes: data['attributes'] as Map<String, dynamic>? ?? {},
      contactPhone: data['contact_phone'] as String? ?? 'غير متاح',
      whatsappPhone: data['whatsapp_phone'] as String?,
      mainImageUrl: data['main_image_url'] as String?,
      imagesUrls: List<String>.from(data['images_urls'] as List? ?? []),
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
      lat: _parseDoubleSafe(data['lat']),
      lng: _parseDoubleSafe(data['lng']),
      sellerId: user != null
          ? (user['id'] is int
              ? user['id'] as int
              : int.tryParse('${user['id']}'))
          : null,
      sellerName: user != null ? (user['name']?.toString()) : null,
       banner: user != null ? (user['banner']?.toString()) : null,
     
      sellerJoinedAt:
          joinedAtStr != null ? DateTime.tryParse(joinedAtStr) : null,
      sellerJoinedAtHuman:
          user != null ? (user['joined_at_human']?.toString()) : null,
      sellerListingsCount: user != null
          ? (user['listings_count'] is int
              ? user['listings_count'] as int
              : int.tryParse('${user['listings_count']}'))
          : null,
    );
  }

  static double? _parseDoubleSafe(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s);
  }
}
