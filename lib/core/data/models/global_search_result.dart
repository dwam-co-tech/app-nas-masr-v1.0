class GlobalSearchCategory {
  final int categoryId;
  final String categoryName;
  final String categorySlug;
  final int count;

  GlobalSearchCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
    required this.count,
  });

  factory GlobalSearchCategory.fromMap(Map<String, dynamic> map) {
    return GlobalSearchCategory(
      categoryId: (map['category_id'] as num?)?.toInt() ?? 0,
      categoryName: map['category_name']?.toString() ?? '',
      categorySlug: map['category_slug']?.toString() ?? '',
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class GlobalSearchResult {
  final String keyword;
  final int total;
  final List<GlobalSearchCategory> categories;

  GlobalSearchResult({
    required this.keyword,
    required this.total,
    required this.categories,
  });

  factory GlobalSearchResult.fromMap(Map<String, dynamic> map) {
    final cats = (map['categories'] as List?) ?? const [];
    return GlobalSearchResult(
      keyword: map['keyword']?.toString() ?? '',
      total: (map['total'] as num?)?.toInt() ??
          (map['meta'] is Map
              ? ((map['meta']['total'] as num?)?.toInt() ?? 0)
              : 0),
      categories: cats
          .whereType<Map>()
          .map(
              (e) => GlobalSearchCategory.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
