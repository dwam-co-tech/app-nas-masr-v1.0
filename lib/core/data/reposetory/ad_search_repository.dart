// core/data/reposetory/ad_search_repository.dart

import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';

class AdSearchRepository {
  final ApiService _api;
  AdSearchRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<AdCardModel>> searchAds({
    required String categorySlug, 
    required Map<String, dynamic> queryParameters, // هذا الـ Map الذي يحمل كل الفلاتر
  }) async {
    final endpoint = '/api/v1/$categorySlug/listings'; 
    
    // 1. هنا يحدث سحر تحويل الـ Map الـ بسيط إلى الـ Query String المعقد:
    // مثلا: 'property_type' -> 'attr[property_type]'
    final Map<String, dynamic> finalQuery = {};
    queryParameters.forEach((key, value) {
      if (key == 'city' || key == 'governorate' || key == 'make' || key == 'model') {
        finalQuery[key] = value; // المفاتيح الثابتة تذهب كما هي
      } else {
        // باقي الـ Dynamic Attributes تذهب كـ attr[]
        finalQuery['attr[$key]'] = value;
      }
    });

    // 2. عمل الـ API Call
    final response = await _api.get(endpoint, query: finalQuery); 
    
    if (response is List) {
      // تحويل الـ List الراجع من API إلى Models
      return response.map((e) => AdCardModel.fromMap(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}