import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/reposetory/home_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';
import 'package:nas_masr_app/core/data/models/category_home.dart' as Models;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HomeProvider with ChangeNotifier {
  final HomeRepository _repo;

  HomeProvider({required HomeRepository repository}) : _repo = repository;

  bool _loading = false;
  String? _error;
  String? _bannerUrl;
  List<Models.Category> _categories = const [];
  String? _supportNumber;

  bool get loading => _loading;
  String? get error => _error;
  String? get bannerUrl => _bannerUrl;
  List<Models.Category> get categories => _categories;
  String? get supportNumber => _supportNumber;

  Future<void> loadHome() async {
    _setLoading(true);
    _setError(null);
    try {
      final results = await Future.wait([
        _repo.getBannerImageUrl(),
        _repo.getCategories(),
      ]);
      _bannerUrl = results[0] as String?;
      _categories = (results[1] as List<Models.Category>);
      if (_bannerUrl != null && _bannerUrl!.isNotEmpty) {
        DefaultCacheManager().getSingleFile(_bannerUrl!);
      }
      for (final c in _categories) {
        if (c.iconUrl.isNotEmpty) {
          DefaultCacheManager().getSingleFile(c.iconUrl);
        }
      }
    } catch (e) {
      if (e is AppError) {
        _setError(e.message);
      } else {
        _setError('حدث خطأ غير متوقع، يرجى المحاولة لاحقًا.');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل رقم الدعم عند الحاجة وإرجاعه
  Future<String?> ensureSupportNumber() async {
    if (_supportNumber != null && _supportNumber!.isNotEmpty) {
      return _supportNumber;
    }
    try {
      final num = await _repo.getSupportNumber();
      _supportNumber = num;
      notifyListeners();
      return num;
    } catch (e) {
      if (e is AppError) {
        _setError(e.message);
      } else {
        _setError('حدث خطأ أثناء تحميل رقم الدعم.');
      }
      return null;
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