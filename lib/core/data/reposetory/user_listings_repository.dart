import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';

class UserListingsRepository {
  final ApiService _api;
  UserListingsRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<AdCardModel>> getUserListings({
    required int userId,
    String? categorySlug,
  }) async {
    final endpoint = '/api/users/$userId';
    final query = (categorySlug != null && categorySlug.isNotEmpty)
        ? {'category_slugs': categorySlug}
        : null;

    print('DEBUG: UserListingsRepository fetching: $endpoint, query: $query');
    final response = await _api.get(endpoint, query: query);
    print(
        'DEBUG: UserListingsRepository response type: ${response.runtimeType}');
    if (response is Map) {
      print('DEBUG: Response keys: ${response.keys}');
      if (response.containsKey('listings')) {
        print(
            'DEBUG: Listings count in response: ${(response['listings'] as List).length}');
      }
    }

    if (response is Map<String, dynamic>) {
      final list = response['listings'] as List<dynamic>? ?? const [];
      return list
          .map((e) => AdCardModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    if (response is List) {
      return response
          .map((e) => AdCardModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }
}
