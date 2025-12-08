import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/my_packages_model.dart';
import 'package:nas_masr_app/core/data/reposetory/my_packages_repository.dart';

class MyPackagesProvider with ChangeNotifier {
  final MyPackagesRepository _repo;

  bool _loading = false;
  String? _error;
  List<MyPackage> _packages = const [];
  List<MySubscription> _subscriptions = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<MyPackage> get packages => _packages;
  List<MySubscription> get subscriptions => _subscriptions;

  MyPackagesProvider({required MyPackagesRepository repository})
      : _repo = repository {
    load();
  }

  Future<void> load() async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _repo.getMyPlans();
      _packages = res.packages;
      _subscriptions = res.subscriptions;
    } catch (e) {
      _error = e.toString();
      _packages = const [];
      _subscriptions = const [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
