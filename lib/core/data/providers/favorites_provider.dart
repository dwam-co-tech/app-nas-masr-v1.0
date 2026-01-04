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

  bool isFavorite(int id) {
    return _items.any((ad) => ad.id == id);
  }

  Future<void> toggle(int id) async {
    // Optimistic update
    final isFav = isFavorite(id);
    if (isFav) {
      _items.removeWhere((ad) => ad.id == id);
    } else {
      // We don't have the full AdCardModel here to add it back immediately if we are just toggling by ID.
      // But usually we toggle from a screen where we have the details.
      // For now, let's just rely on the API call and reload, or handle removal optimistically.
      // Adding optimistically is harder without the object.
      // Let's just notify listeners for now, assuming the UI handles the "optimistic" state locally or we reload.
      // Actually, if we remove, it's gone. If we add, we need to fetch.
    }
    notifyListeners();

    try {
      await _repo.toggleFavorite(id: id);
      // Reload to get the updated list and correct data
      await load(_selectedSlug);
    } catch (e) {
      // Revert if failed (complex without the object, but reloading handles it)
      _setError('فشل تحديث المفضلة');
      await load(_selectedSlug);
    }
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

  /// Clear all favorites data (useful for logout)
  void clearData() {
    _items = const [];
    _categories = const {};
    _allCategories = const {};
    _selectedSlug = null;
    _error = null;
    _loading = false;
    notifyListeners();
    print('✅ FavoritesProvider: All data cleared');
  }
}
