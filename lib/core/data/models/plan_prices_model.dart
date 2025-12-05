class PlanPrices {
  final int? categoryId;
  final String categorySlug;
  final int? priceFeatured;
  final int? featuredAdPrice;
  final int? featuredDays;
  final int? priceStandard;
  final int? standardAdPrice;
  final int? standardDays;

  const PlanPrices({
    this.categoryId,
    required this.categorySlug,
    this.priceFeatured,
    this.featuredAdPrice,
    this.featuredDays,
    this.priceStandard,
    this.standardAdPrice,
    this.standardDays,
  });

  factory PlanPrices.fromMap(Map<String, dynamic> map) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    return PlanPrices(
      categoryId: _toInt(map['category_id']),
      categorySlug: map['category_slug']?.toString() ?? '',
      priceFeatured: _toInt(map['price_featured']),
      featuredAdPrice: _toInt(map['featured_ad_price']),
      featuredDays: _toInt(map['featured_days']),
      priceStandard: _toInt(map['price_standard']),
      standardAdPrice: _toInt(map['standard_ad_price']),
      standardDays: _toInt(map['standard_days']),
    );
  }
}
