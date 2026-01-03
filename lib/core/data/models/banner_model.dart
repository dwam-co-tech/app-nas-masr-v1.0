class BannerModel {
  final String slug;
  final String bannerUrl;

  const BannerModel({
    required this.slug,
    required this.bannerUrl,
  });

  /// تنظيف الـ URL من الـ escaped slashes
  static String _cleanUrl(String url) {
    // إزالة الـ backslashes من الـ forward slashes (\/ → /)
    return url.replaceAll(r'\/', '/');
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    final rawUrl = map['banner_url']?.toString() ?? '';
    final cleanedUrl = _cleanUrl(rawUrl);

    return BannerModel(
      slug: map['slug']?.toString() ?? '',
      bannerUrl: cleanedUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'banner_url': bannerUrl,
    };
  }
}

class BannersResponse {
  final bool success;
  final List<BannerModel> banners;

  const BannersResponse({
    required this.success,
    required this.banners,
  });

  factory BannersResponse.fromMap(Map<String, dynamic> map) {
    final data = map['data'];
    List<BannerModel> bannersList = [];

    if (data is List) {
      bannersList = data
          .where((item) => item is Map<String, dynamic>)
          .map((item) => BannerModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return BannersResponse(
      success: map['success'] == true,
      banners: bannersList,
    );
  }

  /// الحصول على banner بواسطة slug
  String? getBannerUrl(String slug) {
    try {
      return banners.firstWhere((b) => b.slug == slug).bannerUrl;
    } catch (_) {
      return null;
    }
  }
}
