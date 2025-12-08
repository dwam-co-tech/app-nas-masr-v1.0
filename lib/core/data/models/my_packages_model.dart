class MyPackage {
  final String title;
  final String badgeText;
  final String? expiresAtHuman;
  final String? note;

  MyPackage({
    required this.title,
    required this.badgeText,
    this.expiresAtHuman,
    this.note,
  });

  factory MyPackage.fromMap(Map<String, dynamic> map) {
    return MyPackage(
      title: map['title']?.toString() ?? '',
      badgeText: map['badge_text']?.toString() ?? '',
      expiresAtHuman: map['expires_at_human']?.toString(),
      note: map['note']?.toString(),
    );
  }
}

class MySubscription {
  final int id;
  final int? categoryId;
  final String categorySlug;
  final String categoryName;
  final String planType;
  final int days;
  final DateTime? subscribedAt;
  final DateTime? expiresAt;
  final int? price;
  final int? adPrice;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final bool active;

  MySubscription({
    required this.id,
    this.categoryId,
    required this.categorySlug,
    required this.categoryName,
    required this.planType,
    required this.days,
    this.subscribedAt,
    this.expiresAt,
    this.price,
    this.adPrice,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    required this.active,
  });

  factory MySubscription.fromMap(Map<String, dynamic> map) {
    DateTime? _parse(String? s) => s == null ? null : DateTime.tryParse(s);
    return MySubscription(
      id: (map['id'] as num?)?.toInt() ?? 0,
      categoryId: (map['category_id'] as num?)?.toInt(),
      categorySlug: map['category_slug']?.toString() ?? '',
      categoryName: map['category_name']?.toString() ?? '',
      planType: map['plan_type']?.toString() ?? '',
      days: (map['days'] as num?)?.toInt() ?? 0,
      subscribedAt: _parse(map['subscribed_at']?.toString()),
      expiresAt: _parse(map['expires_at']?.toString()),
      price: (map['price'] as num?)?.toInt(),
      adPrice: (map['ad_price'] as num?)?.toInt(),
      paymentStatus: map['payment_status']?.toString(),
      paymentMethod: map['payment_method']?.toString(),
      paymentReference: map['payment_reference']?.toString(),
      active: (map['active'] as bool?) ?? false,
    );
  }
}
