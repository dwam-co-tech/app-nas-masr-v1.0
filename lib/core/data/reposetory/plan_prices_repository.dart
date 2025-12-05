import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/plan_prices_model.dart';

class PlanPricesRepository {
  final ApiService _api;
  PlanPricesRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<PlanPrices> getPlanPrices(String categorySlug) async {
    final res = await _api.get('/api/plan-prices', query: {
      'category_slug': categorySlug,
    });
    if (res is Map<String, dynamic>) {
      return PlanPrices.fromMap(res);
    }
    return PlanPrices(categorySlug: categorySlug);
  }
}
