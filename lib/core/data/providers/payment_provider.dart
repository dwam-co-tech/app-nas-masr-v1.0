import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/reposetory/payment_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentRepository _repo;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _receipt;
  String? _type;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get receipt => _receipt;
  String? get type => _type;

  PaymentProvider({required PaymentRepository repository}) : _repo = repository;

  Future<bool> payListing({required int listingId, required String paymentMethod}) async {
    _setLoading(true);
    _error = null;
    _type = 'ad';
    try {
      final res = await _repo.payForListing(listingId: listingId, paymentMethod: paymentMethod);
      _receipt = res;
      return true;
    } catch (e) {
      _receipt = null;
      _error = e is AppError ? e.message : 'فشل الدفع';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> subscribePlan({required String categorySlug, required String planType, required String paymentMethod}) async {
    _setLoading(true);
    _error = null;
    _type = 'subscription';
    try {
      final res = await _repo.subscribePlan(categorySlug: categorySlug, planType: planType, paymentMethod: paymentMethod);
      _receipt = res;
      return true;
    } catch (e) {
      _receipt = null;
      _error = e is AppError ? e.message : 'فشل الاشتراك';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
