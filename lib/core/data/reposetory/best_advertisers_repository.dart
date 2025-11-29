// core/data/reposetory/best_advertisers_repository.dart

import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/premium_advertiser.dart';

class BestAdvertisersRepository {
  final ApiService _api;
  BestAdvertisersRepository({ApiService? api}) : _api = api ?? ApiService();
  
  Future<List<PremiumAdvertiser>> getPremiumAdvertisers(String categorySlug) async {
    final endpoint = '/api/the-best/$categorySlug';
    final response = await _api.get(endpoint);
    
    // الـ API بتاعنا بيرجع list of Advertisers مباشرة تحت المفتاح 'advertisers'
    final data = response['advertisers'] as List<dynamic>? ?? []; 
    
    return data.map((e) => PremiumAdvertiser.fromMap(e as Map<String, dynamic>)).toList();
  }
}