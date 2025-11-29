// core/data/providers/category_listing_provider.dart

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/reposetory/filter_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class CategoryListingProvider with ChangeNotifier {
  final CategoryRepository _repo;
  final String categorySlug;
  final String _categoryName;

  // الحالة اللي هيرقبها الـ UI:
  bool _isLoading = true;
  String? _error;
  CategoryFieldsResponse? _fieldsConfig; // <<< البيانات كلها ستُخزّن هنا!
  final Map<String, dynamic> _selectedFilters = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  CategoryFieldsResponse? get fieldsConfig => _fieldsConfig;
  Map<String, dynamic> get selectedFilters => _selectedFilters;

  // نحتاج الـ Constructor عشان نحصل على الـ Repository والـ Slug
  CategoryListingProvider({
    required CategoryRepository repository,
    required this.categorySlug,
    required String categoryName,
  })  : _repo = repository,
        _categoryName = categoryName {
    // <<< تخزين الإسم
    loadFieldsAndAds();
  }

  String get categoryName => _categoryName; // <<< الآن Getter مُعرّف!

  Future<void> loadFieldsAndAds() async {
    _setIsLoading(true);
    try {
      // 1. جلب التهيئة الكاملة للقسم
      final config = await _repo.getCategoryFields(categorySlug);

      _fieldsConfig = config; // يتم تخزينها هنا للاستخدام

      // 2. [هنضيف هنا بعدين] جلب إعلانات القسم (List of Ads)

      // 3. ننهي حالة الـ Loading
      _setError(null);
    } catch (e) {
      if (e is AppError) {
        _setError(e.message);
      } else {
        _setError('فشل تحميل تهيئة القسم.');
      }
    } finally {
      _setIsLoading(false);
    }
  }

  void _setIsLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void setFilter(String key, dynamic value) {
    _selectedFilters[key] = value;
    notifyListeners();
  }

  void clearFilter(String key) {
    _selectedFilters.remove(key);
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedFilters.clear();
    notifyListeners();
  }

  bool isFilterSelected(String key) => _selectedFilters.containsKey(key);
}
