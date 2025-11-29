import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nas_masr_app/core/data/models/my_ads_model.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';

class MyAdsRepository {
  final ApiService _api = ApiService();

  Future<List<MyAdItem>> getMyAds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/my-ads', token: token);
    final data = res is Map<String, dynamic>
        ? res
        : (res is String
            ? json.decode(res) as Map<String, dynamic>
            : <String, dynamic>{});
    final parsed = MyAdsResponse.fromMap(data);
    return parsed.data;
  }

  Future<void> deleteMyAd(
      {required String categorySlug, required int id}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final endpoint = '/api/v1/$categorySlug/listings/$id';
    await _api.delete(endpoint, token: token);
  }

  Future<void> setRankOne({required String categorySlug, required int id}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final body = {
      'category': categorySlug,
      'ad_id': id.toString(),
    };
    await _api.post('/api/set-rank-one', data: body, token: token);
  }
}
