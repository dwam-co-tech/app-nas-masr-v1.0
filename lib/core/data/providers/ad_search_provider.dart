// core/data/providers/ad_search_provider.dart

// ... imports

import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_search_repository.dart';

class AdSearchProvider with ChangeNotifier {
   late final AdSearchRepository _repo; // <<< هنا يجب استخدام late final

  // التعديل على الـ Constructor لإنشاء _repo:
  AdSearchProvider({AdSearchRepository? repository}) 
      : _repo = repository ?? AdSearchRepository(); 
  //...
  List<AdCardModel> _ads = [];
  bool _loading = false;
  
  // ... Getters
  
  // الدالة الرئيسية اللي بتشغل كل حاجة في صفحة البحث
  Future<void> performSearch({
    required String categorySlug,
    required Map<String, dynamic> filters,
  }) async {
    _setLoading(true);
    // ... (Error Handling Code) ...

    try {
      final results = await _repo.searchAds(categorySlug: categorySlug, queryParameters: filters);
      _ads = results;
    } catch (e) {
      //... (Error Logging) ...
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
  // ...
}