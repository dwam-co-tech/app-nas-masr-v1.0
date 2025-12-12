import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/chat_inbox_item.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class ChatInboxProvider with ChangeNotifier {
  final ChatRepository _repo;
  ChatInboxProvider({required ChatRepository repository}) : _repo = repository;

  bool _loading = false;
  String? _error;
  String _selected = 'peer';
  String _query = '';
  int _unreadTotal = 0;
  final List<ChatInboxItem> _items = [];

  bool get loading => _loading;
  String? get error => _error;
  String get selected => _selected;
  String get query => _query;
  int get unreadTotal => _unreadTotal;
  List<ChatInboxItem> get items => List.unmodifiable(_items);

  List<ChatInboxItem> get displayedItems {
    Iterable<ChatInboxItem> base =
        _items.where((e) => (e.type ?? '') == _selected);
    if (_query.trim().isNotEmpty) {
      final q = _query.trim();
      base = base.where((e) =>
          e.otherPartyId.toString().contains(q) ||
          (e.lastMessage ?? '').contains(q));
    }
    return base.toList();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) _setLoading(true);
    _setError(null);
    try {
      final (list, unread) = await _repo.fetchInbox(type: _selected);
      _items
        ..clear()
        ..addAll(list);
      _unreadTotal = unread;
      notifyListeners();
    } catch (e) {
      final msg = e is AppError ? e.message : 'فشل تحميل الرسائل';
      _setError(msg);
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  void setTab(String tab) {
    _selected = tab;
    notifyListeners();
    load();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
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
