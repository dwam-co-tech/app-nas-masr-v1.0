import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/chat_message.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _repo;
  ChatProvider({required ChatRepository repository}) : _repo = repository;

  int? _peerId;
  int? _myId;
  bool _supportMode = false;
  bool _sending = false;
  bool _loading = false;
  String? _error;
  final List<ChatMessage> _messages = [];
  int _page = 1;
  int _lastPage = 1;

  int? get peerId => _peerId;
  int? get myId => _myId;
  bool get supportMode => _supportMode;
  bool get sending => _sending;
  bool get loading => _loading;
  String? get error => _error;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void init({required int peerId, required int myId}) {
    _peerId = peerId;
    _myId = myId;
    _supportMode = false;
    notifyListeners();
  }

  void initSupport({required int myId}) {
    _peerId = null;
    _myId = myId;
    _supportMode = true;
    notifyListeners();
  }

  Future<bool> send(String text) async {
    if (!_supportMode && (_peerId ?? 0) <= 0) {
      _setError('المستلم غير محدد');
      return false;
    }
    if (text.trim().isEmpty) {
      _setError('نص الرسالة فارغ');
      return false;
    }
    _setSending(true);
    _setError(null);
    try {
      final res = _supportMode
          ? await _repo.sendSupportMessage(message: text)
          : await _repo.sendMessage(receiverId: _peerId!, message: text);
      int? id;
      try {
        final raw = res['id'] ?? res['message_id'];
        if (raw != null) id = int.tryParse(raw.toString());
      } catch (_) {}
      final msg = ChatMessage(
        id: id,
        senderId: _myId ?? -1,
        receiverId: _supportMode ? 0 : (_peerId ?? 0),
        message: text,
        createdAt: DateTime.now(),
      );
      _messages.add(msg);
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e is AppError ? e.message : 'فشل إرسال الرسالة';
      _setError(msg);
      return false;
    } finally {
      _setSending(false);
    }
  }

  Future<void> load({bool reset = false, bool silent = false}) async {
    if (!_supportMode && (_peerId ?? 0) <= 0) return;
    if (!silent) _setLoading(true);
    _setError(null);
    try {
      final pageToLoad = reset ? 1 : _page;
      final (items, current, last) = _supportMode
          ? await _repo.fetchSupport(page: pageToLoad)
          : await _repo.fetchChat(peerId: _peerId!, page: pageToLoad);
      if (reset) {
        _messages
          ..clear()
          ..addAll(items);
      } else {
        final existingIds = _messages.map((m) => m.id).toSet();
        for (final m in items) {
          if (!existingIds.contains(m.id)) {
            _messages.add(m);
          }
        }
      }
      _page = current;
      _lastPage = last;
      notifyListeners();
    } catch (e) {
      final msg = e is AppError ? e.message : 'فشل تحميل الرسائل';
      _setError(msg);
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_page >= _lastPage) return;
    _page += 1;
    await load();
  }

  void _setSending(bool v) {
    _sending = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void setMyId(int id) {
    _myId = id;
    notifyListeners();
  }
}
