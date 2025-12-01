import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/reposetory/notifications_repository.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsRepository _repo;
  NotificationsProvider({required NotificationsRepository repository})
      : _repo = repository {
    load(null);
  }

  bool _loading = false;
  String? _error;
  List<NotificationItem> _items = const [];
  String? _selected;
  final Map<String, String> _categories = const {
    '': 'الكل',
    'customers': 'العملاء',
    'admin': 'الإدارة',
  };

  bool get loading => _loading;
  String? get error => _error;
  List<NotificationItem> get items => _items;
  Map<String, String> get categories => _categories;
  String? get selected => _selected;

  Future<void> load(String? category) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _repo.getNotifications(category: category);
      _items = res;
      _selected = category;
    } catch (e) {
      _setError('فشل تحميل الإشعارات');
    } finally {
      _setLoading(false);
    }
  }

  void select(String? category) {
    load(category);
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

