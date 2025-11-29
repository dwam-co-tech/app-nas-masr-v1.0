// core/data/models/premium_listing_item.dart
// سيشترك في كثير من الحقول مع الـ AdCardModel العادي

class PremiumListingItem {
  final int id;
  final String? mainImageUrl;
  final String? price;
  
  // لكي نسهل استخراج البيانات التي ستظهر أسفل الصورة
  final Map<String, dynamic> attributes; 

  const PremiumListingItem({
    required this.id,
    this.mainImageUrl,
    this.price,
    this.attributes = const {},
  });

  factory PremiumListingItem.fromMap(Map<String, dynamic> json) {
    return PremiumListingItem(
      id: json['id'] as int,
      mainImageUrl: json['main_image_url'] as String?,
      price: json['price'] as String? ?? 'غير محدد',
      // لحقول مثل property_type لعرضها أسفل الكارت إذا لزم الأمر
      attributes: json['attributes'] as Map<String, dynamic>? ?? {}, 
    );
  }
}