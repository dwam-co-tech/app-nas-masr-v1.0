class Category {
  final int id;
  final String slug;
  final String name;
  final String iconUrl;

  Category({
    required this.id,
    required this.slug,
    required this.name,
    required this.iconUrl,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}') ?? 0,
      slug: map['slug']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      iconUrl: map['icon_url']?.toString() ?? '',
    );
  }
}