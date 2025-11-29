import 'package:nas_masr_app/core/constatants/string.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/category_home.dart';
import 'package:nas_masr_app/core/data/models/home_banar_model.dart';

class HomeRepository {
  final ApiService _api;
  HomeRepository({ApiService? api}) : _api = api ?? ApiService();

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

  /// جلب إعدادات النظام لاستخراج صورة البنر
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

  /// جلب الأقسام مع الحفاظ على نفس الترتيب
  Future<List<Category>> getCategories() async {
    final res = await _api.get('/api/categories');
    final data = (res is Map) ? res['data'] : null;
    if (data is List) {
      return data.map((e) => Category.fromMap(e as Map<String, dynamic>)).toList();
    }
    return <Category>[];
  }
}
