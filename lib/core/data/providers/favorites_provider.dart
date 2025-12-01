import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/core/data/reposetory/favorites_repository.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesRepository _repo;
  FavoritesProvider(
      {required FavoritesRepository repository, String? initialSlug})
      : _repo = repository,
        _selectedSlug = initialSlug {
    load(initialSlug);
  }

  bool _loading = false;
  String? _error;
  List<AdCardModel> _items = const [];
  Map<String, String> _categories = const {};
  Map<String, String> _allCategories = const {};
  String? _selectedSlug;

  bool get loading => _loading;
  String? get error => _error;
  List<AdCardModel> get items => _items;
  Map<String, String> get categories => _categories;
  String? get selectedSlug => _selectedSlug;

  Future<void> load(String? slug) async {
    _setLoading(true);
    _setError(null);
    try {
      if (_allCategories.isEmpty) {
        final all = await _repo.getFavorites();
        final catMap = <String, String>{};
        for (final ad in all) {
          if (ad.categorySlug.isNotEmpty) {
            catMap[ad.categorySlug] = ad.categoryName;
          }
        }
        _allCategories = catMap;
      }
      final res = await _repo.getFavorites(categorySlug: slug);
      if (slug != null && slug.isNotEmpty) {
        _items = res.where((ad) => ad.categorySlug == slug).toList();
      } else {
        _items = res;
      }
      _selectedSlug = slug;
      _categories = _allCategories;
    } catch (e) {
      _setError('فشل تحميل المفضلة');
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(String? slug) {
    load(slug);
  }

  Future<bool> remove(int id) async {
    final before = List<AdCardModel>.from(_items);
    _items = _items.where((ad) => ad.id != id).toList();
    notifyListeners();
    try {
      final ok = await _repo.toggleFavorite(id: id);
      await load(_selectedSlug);
      return ok;
    } catch (e) {
      _items = before;
      notifyListeners();
      _setError('تعذر تعديل المفضلة');
      return false;
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }
}
