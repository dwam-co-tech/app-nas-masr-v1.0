// core/data/reposetory/ad_search_repository.dart

import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';

class AdSearchRepository {
  final ApiService _api;
  AdSearchRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<AdCardModel>> searchAds({
    required String categorySlug,
    required Map<String, dynamic>
        queryParameters, // هذا الـ Map الذي يحمل كل الفلاتر
    String? token,
  }) async {
    try {
      final endpoint = '/api/v1/$categorySlug/listings';

      // 1. Prepare Query
      final Map<String, dynamic> finalQuery = {};
      queryParameters.forEach((key, value) {
        if (key == 'city' ||
            key == 'governorate' ||
            key == 'make' ||
            key == 'model' ||
            key == 'main_section' ||
            key == 'sub_section') {
          finalQuery[key] = value;
        } else {
          finalQuery['attr[$key]'] = value;
        }
      });

      // 2. API Call
      final response =
          await _api.get(endpoint, query: finalQuery, token: token);

      if (response is List) {
        final List<AdCardModel> ads = [];
        for (var item in response) {
          if (item is Map) {
            try {
              ads.add(AdCardModel.fromMap(Map<String, dynamic>.from(item)));
            } catch (e) {
              print('Error parsing ad item: $e');
            }
          }
        }
        return ads;
      } else if (response is Map) {
        // Handle case where response is a Map (e.g. pagination) but contains data list
        final data = response['data'];
        if (data is List) {
          final List<AdCardModel> ads = [];
          for (var item in data) {
            if (item is Map) {
              try {
                ads.add(AdCardModel.fromMap(Map<String, dynamic>.from(item)));
              } catch (e) {
                print('Error parsing ad item from pagination: $e');
              }
            }
          }
          return ads;
        }
      }

      return [];
    } catch (e, stack) {
      print('Error in searchAds: $e');
      print(stack);
      rethrow;
    }
  }
}
