import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/global_search_result.dart';
import 'package:nas_masr_app/core/data/reposetory/global_search_repository.dart';

class GlobalSearchProvider with ChangeNotifier {
  final GlobalSearchRepository _repo;
  bool _loading = false;
  String? _error;
  GlobalSearchResult? _result;
  String _lastKeyword = '';

  bool get loading => _loading;
  String? get error => _error;
  GlobalSearchResult? get result => _result;
  String get lastKeyword => _lastKeyword;

  GlobalSearchProvider({required GlobalSearchRepository repository})
      : _repo = repository;

  Future<void> search(String keyword) async {
    _setLoading(true);
    _error = null;
    _lastKeyword = keyword;
    try {
      _result = await _repo.search(keyword);
    } catch (e) {
      _error = e.toString();
      _result = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
