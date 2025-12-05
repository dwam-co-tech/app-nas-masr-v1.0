import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/plan_prices_model.dart';
import 'package:nas_masr_app/core/data/reposetory/plan_prices_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class PlanPricesProvider with ChangeNotifier {
  final PlanPricesRepository _repo;
  bool _loading = false;
  String? _error;
  PlanPrices? _prices;

  bool get loading => _loading;
  String? get error => _error;
  PlanPrices? get prices => _prices;

  PlanPricesProvider({required PlanPricesRepository repository})
      : _repo = repository;

  Future<void> load(String categorySlug) async {
    _setLoading(true);
    _error = null;
    try {
      _prices = await _repo.getPlanPrices(categorySlug);
    } catch (e) {
      if (e is AppError) {
        _error = e.message;
      } else {
        _error = 'فشل تحميل أسعار الباقات';
      }
      _prices = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
