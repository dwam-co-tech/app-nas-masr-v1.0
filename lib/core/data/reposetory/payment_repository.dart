import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentRepository {
  final ApiService _api;
  PaymentRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> payForListing({required int listingId, required String paymentMethod}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.patch('/api/payment/$listingId', data: {
      'payment_method': paymentMethod,
    }, token: token);
    return Map<String, dynamic>.from(res as Map);
  }

  Future<Map<String, dynamic>> subscribePlan({required String categorySlug, required String planType, required String paymentMethod}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.post('/api/plan-subscriptions', data: {
      'category_slug': categorySlug,
      'plan_type': planType,
      'payment_method': paymentMethod,
    }, token: token);
    return Map<String, dynamic>.from(res as Map);
  }
}
