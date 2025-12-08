import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/reposetory/notifications_repository.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsRepository _repo;
  NotificationsProvider({required NotificationsRepository repository})
      : _repo = repository {
    loadFirst();
  }

  bool _loading = false;
  String? _error;
  List<NotificationItem> _items = const [];
  String? _selected;
  int _page = 1;
  int _lastPage = 1;
  bool _loadingMore = false;
  final Map<String, String> _categories = const {
    '': 'الكل',
    'customers': 'العملاء',
    'admin': 'الإدارة',
  };

  bool get loading => _loading;
  String? get error => _error;
  List<NotificationItem> get items => _items;
  List<NotificationItem> get displayedItems =>
      (_selected == null || _selected!.isEmpty)
          ? _items
          : _items.where((n) => (n.type ?? n.category) == _selected).toList();
  Map<String, String> get categories => _categories;
  String? get selected => _selected;
  bool get hasMore => _page < _lastPage;
  bool get loadingMore => _loadingMore;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Future<void> loadFirst() async {
    _setLoading(true);
    _setError(null);
    try {
      final pageRes = await _repo.getNotificationsPage(page: 1);
      _items = pageRes.items;
      _page = pageRes.page;
      _lastPage = pageRes.lastPage;
    } catch (e) {
      _setError('فشل تحميل الإشعارات');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final next = _page + 1;
      final pageRes = await _repo.getNotificationsPage(page: next);
      _items = [..._items, ...pageRes.items];
      _page = pageRes.page;
      _lastPage = pageRes.lastPage;
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  void select(String? category) {
    _selected = category;
    notifyListeners();
  }

  Future<void> markItemRead(int id) async {
    try {
      await _repo.markAsRead(id);
      _items = _items.map((n) => n.id == id
          ? NotificationItem(
              id: n.id,
              title: n.title,
              body: n.body,
              category: n.category,
              type: n.type,
              data: n.data,
              createdAt: n.createdAt,
              isRead: true,
            )
          : n).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllAsRead();
      _items = _items
          .map((n) => NotificationItem(
                id: n.id,
                title: n.title,
                body: n.body,
                category: n.category,
                type: n.type,
                data: n.data,
                createdAt: n.createdAt,
                isRead: true,
              ))
          .toList();
      notifyListeners();
    } catch (_) {}
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
