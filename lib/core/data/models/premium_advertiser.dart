// core/data/models/premium_advertiser.dart

import 'premium_listing_item.dart';

class PremiumAdvertiser {
  final int id;
  final String name; // إسم المعلن (مثل "tasneem")
  final List<PremiumListingItem> listings;

  const PremiumAdvertiser({
    required this.id,
    required this.name,
    required this.listings,
  });

  factory PremiumAdvertiser.fromMap(Map<String, dynamic> json) {
    final listingsData = json['listings'] as List<dynamic>? ?? [];

    return PremiumAdvertiser(
      id: json['id'] as int,
      name: json['user']['name'] as String? ?? 'مُعلن مميز', // استخراج الإسم من User Nested Field
      listings: listingsData.map((e) => PremiumListingItem.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }
}