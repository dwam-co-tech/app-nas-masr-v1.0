import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/ad_card_model.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_search_repository.dart';
import 'package:nas_masr_app/core/services/location_service.dart';

class AdSearchProvider with ChangeNotifier {
  late final AdSearchRepository _repo;
  final LocationService _locationService = LocationService();

  AdSearchProvider({AdSearchRepository? repository})
      : _repo = repository ?? AdSearchRepository();

  List<AdCardModel> _ads = [];
  bool _loading = false;
  String? _error;
  bool _sortByNearest = false;
  bool _sortByPrice = false;

  List<AdCardModel> get ads => _ads;
  bool get loading => _loading;
  String? get error => _error;
  bool get sortByNearest => _sortByNearest;
  bool get sortByPrice => _sortByPrice;

  Future<void> performSearch({
    required String categorySlug,
    required Map<String, dynamic> filters,
    String? token,
  }) async {
    _setLoading(true);
    _error = null;
    _sortByNearest = false; // Reset sort on new search
    _sortByPrice = false;
    try {
      final results = await _repo.searchAds(
          categorySlug: categorySlug, queryParameters: filters, token: token);
      _ads = results;
    } catch (e) {
      _error = e.toString();
      _ads = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleSortByNearest() async {
    if (_ads.isEmpty) return;

    _sortByNearest = !_sortByNearest;
    if (_sortByNearest) {
      _sortByPrice = false;
    }

    if (!_sortByNearest) {
      // Revert to default sort (Premium -> Standard -> Free)
      // Assuming the API returns them in this order, we might need to re-fetch or just sort by planType
      _sortByDefault();
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        print('SORT_DEBUG: Failed to get user location');
        _sortByNearest = false; // Failed to get location
        // Optionally set an error message here
        return;
      }

      print(
          'SORT_DEBUG: User Location: ${location.latitude}, ${location.longitude}');

      _ads.sort((a, b) {
        // 1. Handle nulls: Ads without location go to the bottom
        if ((a.lat == null || a.lng == null) &&
            (b.lat == null || b.lng == null)) return 0;
        if (a.lat == null || a.lng == null) return 1;
        if (b.lat == null || b.lng == null) return -1;

        // 2. Calculate distances
        final distA = _locationService.calculateDistance(
            location.latitude!, location.longitude!, a.lat!, a.lng!);
        final distB = _locationService.calculateDistance(
            location.latitude!, location.longitude!, b.lat!, b.lng!);

        // print('SORT_DEBUG: Ad ${a.id} (${a.lat},${a.lng}) dist: $distA | Ad ${b.id} (${b.lat},${b.lng}) dist: $distB');

        // 3. Compare strictly by distance
        return distA.compareTo(distB);
      });

      // print('SORT_DEBUG: Sorted ${_ads.length} ads');
    } catch (e) {
      print('Error sorting by nearest: $e');
      _sortByNearest = false;
    } finally {
      _setLoading(false);
    }
  }

  void toggleSortByPrice() {
    if (_ads.isEmpty) return;

    _sortByPrice = !_sortByPrice;
    if (_sortByPrice) {
      _sortByNearest = false;
    }

    if (!_sortByPrice) {
      _sortByDefault();
    } else {
      _ads.sort((a, b) {
        final priceA = _parsePrice(a.price);
        final priceB = _parsePrice(b.price);
        return priceA.compareTo(priceB);
      });
    }
    notifyListeners();
  }

  double _parsePrice(String price) {
    // Remove non-numeric characters except dot
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _sortByDefault() {
    // Basic default sort logic based on plan type importance
    // Premium > Standard > Free
    _ads.sort((a, b) {
      final scoreA = _getPlanScore(a.planType);
      final scoreB = _getPlanScore(b.planType);
      return scoreB.compareTo(scoreA); // Descending score
    });
  }

  int _getPlanScore(String planType) {
    switch (planType.toLowerCase()) {
      case 'premium':
      case 'مميزة':
      case 'متميز':
        return 3;
      case 'standard':
      case 'ستاندرد':
        return 2;
      case 'free':
      case 'مجانية':
      default:
        return 1;
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
