// جزء من core/data/reposetory/category_repository.dart
// (هنكمل عليه الـ Model اللي صممناه)
// ...

import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';

class CategoryRepository {
  final ApiService _api;

  CategoryRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<CategoryFieldsResponse> getCategoryFields(String categorySlug) async {
    final response = await _api
        .get('/api/category-fields', query: {'category_slug': categorySlug});

    if (response is Map<String, dynamic>) {
      return CategoryFieldsResponse.fromMap(response);
    }
    throw Exception('Failed to load category configuration for $categorySlug');
  }
}
