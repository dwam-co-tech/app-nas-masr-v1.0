import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/my_ads_model.dart';
import 'package:nas_masr_app/core/data/reposetory/my_ads_repository.dart';

class MyAdsProvider extends ChangeNotifier {
  final MyAdsRepository repository;
  MyAdsProvider({required this.repository}) {
    loadMyAds();
  }

  List<MyAdItem> _ads = const [];
  bool _loading = false;
  String? _error;

  List<MyAdItem> get ads => _ads;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadMyAds() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await repository.getMyAds();
      _ads = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAd(MyAdItem ad) async {
    try {
      await repository.deleteMyAd(categorySlug: ad.category ?? '', id: ad.id);
      _ads = _ads.where((x) => x.id != ad.id).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> renewAd(MyAdItem ad) async {
    try {
      await repository.setRankOne(categorySlug: ad.category ?? '', id: ad.id);
      await loadMyAds();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
