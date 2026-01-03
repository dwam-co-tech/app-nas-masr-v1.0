import 'package:nas_masr_app/core/constatants/string.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/category_home.dart';
import 'package:nas_masr_app/core/data/models/home_banar_model.dart';
import 'package:nas_masr_app/core/data/models/banner_model.dart';

class HomeRepository {
  final ApiService _api;
  HomeRepository({ApiService? api}) : _api = api ?? ApiService();

  /// جلب البانرات من الـ API الجديد
  Future<BannersResponse> getBanners() async {
    final res = await _api.get('/api/banners');
    if (res is Map<String, dynamic>) {
      return BannersResponse.fromMap(res);
    }
    return const BannersResponse(success: false, banners: []);
  }

  /// جلب banner معين بواسطة slug
  Future<String?> getBannerBySlug(String slug) async {
    try {
      final bannersResponse = await getBanners();
      return bannersResponse.getBannerUrl(slug);
    } catch (_) {
      return null;
    }
  }

  /// جلب إعدادات النظام Typed
  Future<HomeModel> getSystemSettings() async {
    final res = await _api.get('/api/system-settings');
    if (res is Map<String, dynamic>) {
      return HomeModel.fromMap(res, baseUrl: baseUrl);
    } else if (res is List) {
      return HomeModel.fromApiList(res, baseUrl: baseUrl);
    }
    return const HomeModel();
  }

  /// جلب إعدادات النظام لاستخراج صورة البنر (DEPRECATED - use getBannerBySlug instead)
  @Deprecated('Use getBannerBySlug("home") instead')
  Future<String?> getBannerImageUrl() async {
    final settings = await getSystemSettings();
    return settings.bannerUrl;
  }

  /// جلب رقم الدعم من إعدادات النظام
  Future<String?> getSupportNumber() async {
    final settings = await getSystemSettings();
    final raw = settings.supportNumber;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  /// جلب رقم الطوارئ من إعدادات النظام
  Future<String?> getEmergencyNumber() async {
    final settings = await getSystemSettings();
    final raw = settings.emergencyNumber;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  /// جلب رقم تغيير كلمة المرور من إعدادات النظام
  Future<String?> getPasswordChangeNumber() async {
    final settings = await getSystemSettings();
    final raw = settings.passwordChangeNumber;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  /// جلب الأقسام مع الحفاظ على نفس الترتيب
  Future<List<Category>> getCategories() async {
    final res = await _api.get('/api/categories');
    final data = (res is Map) ? res['data'] : null;
    if (data is List) {
      return data
          .where((e) => e is Map)
          .map((e) => Category.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return <Category>[];
  }
}
