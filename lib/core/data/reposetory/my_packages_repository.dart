import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/my_packages_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPackagesRepository {
  final ApiService _api;
  MyPackagesRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<MyPackage>> getMyPackages() async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } catch (_) {}
    final res = await _api.get('/api/my-packages', token: token);
    List<dynamic> items = const [];
    if (res is Map<String, dynamic>) {
      final data = res['packages'];
      if (data is List) items = data;
    } else if (res is List) {
      items = res;
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map((e) => MyPackage.fromMap(e))
        .toList();
  }
}
