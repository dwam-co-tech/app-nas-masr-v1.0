import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/core/data/reposetory/user_listings_repository.dart';

class UserListingsProvider with ChangeNotifier {
  final UserListingsRepository _repo;
  final int userId;

  bool _loading = false;
  String? _error;
  List<AdCardModel> _listings = const [];
  Map<String, String> _categories = const {};
  Map<String, String> _allCategories = const {};
  String? _selectedSlug;

  UserListingsProvider({
    required UserListingsRepository repository,
    required this.userId,
    String? initialSlug,
  })  : _repo = repository,
        _selectedSlug = initialSlug {
    load(initialSlug);
  }

  bool get loading => _loading;
  String? get error => _error;
  List<AdCardModel> get listings => _listings;
  Map<String, String> get categories => _categories;
  String? get selectedSlug => _selectedSlug;
  String? get selectedCategoryName =>
      _selectedSlug != null ? _categories[_selectedSlug!] : null;
  String? get bannerUrl =>
      _listings.isNotEmpty ? _listings.first.mainImageUrl : null;

  Future<void> load(String? slug) async {
    _setLoading(true);
    _setError(null);
    try {
      if (_allCategories.isEmpty) {
        final allRes = await _repo.getUserListings(userId: userId);
        final allMap = <String, String>{};
        for (final ad in allRes) {
          if (ad.categorySlug.isNotEmpty) {
            allMap[ad.categorySlug] = ad.categoryName;
          }
        }
        _allCategories = allMap;
      }
      final res = await _repo.getUserListings(
        userId: userId,
        categorySlug: slug,
      );
      _listings = res;
      _selectedSlug = slug;
      _categories = _allCategories;
    } catch (e) {
      _setError('فشل تحميل إعلانات المعلن');
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(String? slug) {
    load(slug);
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
