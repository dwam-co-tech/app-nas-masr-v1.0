import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  final ApiService _api;
  FavoritesRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<AdCardModel>> getFavorites({String? categorySlug}) async {
    final endpoint = '/api/favorites';
    final query = (categorySlug != null && categorySlug.isNotEmpty)
        ? {'category_slug': categorySlug}
        : null;
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } catch (_) {}
    final response = await _api.get(endpoint, query: query, token: token);
    List<dynamic> items = const [];
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) items = data;
    } else if (response is List) {
      items = response;
    }
    return items.map((e) {
      final m = e as Map<String, dynamic>;
      String? mainImage = m['main_image']?.toString();
      if (mainImage != null) {
        mainImage = mainImage.replaceAll('`', '').trim();
      }
      final map = <String, dynamic>{
        'id': m['id'],
        'category_name': m['categry_name'],
        'category': m['categry'],
        'governorate': m['gov'] ?? '',
        'city': m['cite'] ?? '',
        'price': m['price']?.toString(),
        'main_image_url': mainImage,
        'plan_type': m['plan_type'],
        'created_at': m['puplished'],
        'attributes': {
          'description': m['description'],
          'view': m['view'],
          'rank': m['rank'],
        }
      };
      return AdCardModel.fromMap(map);
    }).toList();
  }

  Future<bool> toggleFavorite({required int id}) async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } catch (_) {}
    dynamic res;
    try {
      res = await _api.post('/api/favorite',
          data: {'id': id, 'ad_id': id, 'listing_id': id}, token: token);
    } catch (_) {
      try {
        res = await _api.postFormData('/api/favorite',
            data: {'id': id, 'ad_id': id, 'listing_id': id}, token: token);
      } catch (e) {
        return false;
      }
    }
    if (res is Map<String, dynamic>) {
      final status = res['status']?.toString().toLowerCase();
      final favorited = res['favorited'];
      final message = res['message']?.toString().toLowerCase();
      if (favorited is bool)
        return !favorited; // if now favorited=false => removed
      if (status == 'removed' ||
          message?.contains('remove') == true ||
          message?.contains('تم') == true) return true;
    }
    return false;
  }
}
