import 'dart:convert';

class MyAdsResponse {
  final List<MyAdItem> data;
  final String? categorySlug;

  MyAdsResponse({required this.data, this.categorySlug});

  factory MyAdsResponse.fromMap(Map<String, dynamic> map) {
    final list = (map['data'] as List? ?? [])
        .map((e) => MyAdItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return MyAdsResponse(
      data: list,
      categorySlug: map['category_slug']?.toString(),
    );
  }
}

class MyAdItem {
  final int id;
  final int? categoryId;
  final String? category;
  final String? categoryName;
  final String? title;
  final String? price;
  final String? currency;
  final String? description;
  final String? governorate;
  final String? city;
  final String? lat;
  final String? lng;
  final String? address;
  final String? status;
  final String? planType;
  final String? mainImageUrl;
  final List<String> imagesUrls;
  final Map<String, dynamic> attributes;
  final int? views;
  final int? rank;
  final String? countryCode;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? expire_at;
  final String? make;
  final String? model;

  MyAdItem({
    required this.id,
    this.categoryId,
    this.category,
    this.categoryName,
    this.title,
    this.price,
    this.currency,
    this.description,
    this.governorate,
    this.city,
    this.lat,
    this.lng,
    this.address,
    this.status,
    this.planType,
    this.mainImageUrl,
    this.imagesUrls = const [],
    this.attributes = const {},
    this.views,
    this.rank,
    this.countryCode,
    this.publishedAt,
    this.createdAt,
    this.expire_at,
    this.make,
    this.model,
  });

  factory MyAdItem.fromMap(Map<String, dynamic> map) {
    String sanitizeUrl(dynamic v) {
      final s = (v ?? '').toString();
      return s.replaceAll('`', '').trim();
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return MyAdItem(
      id: (map['id'] ?? 0) is int ? map['id'] as int : int.tryParse('${map['id']}') ?? 0,
      categoryId: map['category_id'] is int ? map['category_id'] as int : int.tryParse('${map['category_id']}'),
      category: map['category']?.toString(),
      categoryName: map['category_name']?.toString(),
      title: map['title']?.toString(),
      price: map['price']?.toString(),
      //currency: map['currency']?.toString(),
      description: map['description']?.toString(),
      governorate: map['governorate']?.toString(),
      city: map['city']?.toString(),
      lat: map['lat']?.toString(),
      lng: map['lng']?.toString(),
      address: map['address']?.toString(),
      status: map['status']?.toString(),
      planType: map['plan_type']?.toString(),
      mainImageUrl: sanitizeUrl(map['main_image_url']),
      // imagesUrls: (map['images_urls'] as List?
      //         ?.map((e) => sanitizeUrl(e))
      //         .where((e) => e.isNotEmpty)
      //         .toList()) ??
      //     const [],
      attributes: (map['attributes'] as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? const {},
      views: map['views'] is int ? map['views'] as int : int.tryParse('${map['views']}'),
      rank: map['rank'] is int ? map['rank'] as int : int.tryParse('${map['rank']}'),
      countryCode: map['country_code']?.toString(),
      publishedAt: parseDate(map['published_at']),
      createdAt: parseDate(map['created_at']),
      expire_at: parseDate(map['expire_at']),
      make: map['make']?.toString(),
      model: map['model']?.toString(),
    );
  }
}

