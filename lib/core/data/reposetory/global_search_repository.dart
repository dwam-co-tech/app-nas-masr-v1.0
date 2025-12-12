import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/global_search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSearchRepository {
  final ApiService _api;
  GlobalSearchRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<GlobalSearchResult> search(String keyword) async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } catch (_) {}
    final res = await _api.get('/api/listings/search', query: {'q': keyword}, token: token);
    if (res is Map<String, dynamic>) {
      return GlobalSearchResult.fromMap(res);
    }
    return GlobalSearchResult(keyword: keyword, total: 0, categories: const []);
  }
}
