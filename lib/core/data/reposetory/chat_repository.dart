import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nas_masr_app/core/data/models/chat_inbox_item.dart';
import 'package:nas_masr_app/core/data/models/chat_message.dart';

class ChatRepository {
  final ApiService _api;
  ChatRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.post('/api/chat/send',
        data: {
          'receiver_id': receiverId,
          'message': message,
        },
        token: token);
    return Map<String, dynamic>.from(res as Map);
  }

  Future<Map<String, dynamic>> sendSupportMessage({
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.post('/api/chat/support',
        data: {
          'message': message,
        },
        token: token);
    return Map<String, dynamic>.from(res as Map);
  }

  Future<int> fetchUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/chat/unread-count', token: token);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res as Map);
      final raw = map['unread_count'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }
    if (res is int) return res;
    return 0;
  }

  Future<(List<ChatInboxItem>, int)> fetchInbox({String? type}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/chat/inbox', token: token);
    final map = Map<String, dynamic>.from(res as Map);
    final dataList = (map['data'] as List?) ?? const [];
    final items = dataList
        .whereType<Map>()
        .map((e) => ChatInboxItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final unreadTotalRaw = map['unread_total'];
    final unreadTotal = unreadTotalRaw is int
        ? unreadTotalRaw
        : int.tryParse(unreadTotalRaw?.toString() ?? '') ?? 0;
    List<ChatInboxItem> filtered = items;
    if (type != null && type.isNotEmpty) {
      filtered = items.where((i) => (i.type ?? '') == type).toList();
    }
    return (filtered, unreadTotal);
  }

  Future<(List<ChatMessage>, int, int)> fetchChat({
    required int peerId,
    int page = 1,
    int perPage = 50,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/chat/$peerId', token: token, query: {
      'page': page,
      'per_page': perPage,
    });
    final map = Map<String, dynamic>.from(res as Map);
    final meta = Map<String, dynamic>.from((map['meta'] as Map?) ?? {});
    final dataList = (map['data'] as List?) ?? const [];
    final items = dataList
        .whereType<Map>()
        .map((e) => ChatMessage.fromApiChat(Map<String, dynamic>.from(e)))
        .toList();
    final pageRaw = meta['page'];
    final lastRaw = meta['last_page'];
    final currentPage = pageRaw is int
        ? pageRaw
        : int.tryParse(pageRaw?.toString() ?? '') ?? page;
    final lastPage = lastRaw is int
        ? lastRaw
        : int.tryParse(lastRaw?.toString() ?? '') ?? currentPage;
    return (items, currentPage, lastPage);
  }

  Future<(List<ChatMessage>, int, int)> fetchSupport({
    int page = 1,
    int perPage = 50,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/chat/support', token: token, query: {
      'page': page,
      'per_page': perPage,
    });
    final map = Map<String, dynamic>.from(res as Map);
    final meta = Map<String, dynamic>.from((map['meta'] as Map?) ?? {});
    final dataList = (map['data'] as List?) ?? const [];
    final items = dataList
        .whereType<Map>()
        .map((e) => ChatMessage.fromApiSupport(Map<String, dynamic>.from(e)))
        .toList();
    final pageRaw = meta['page'];
    final lastRaw = meta['last_page'];
    final currentPage = pageRaw is int
        ? pageRaw
        : int.tryParse(pageRaw?.toString() ?? '') ?? page;
    final lastPage = lastRaw is int
        ? lastRaw
        : int.tryParse(lastRaw?.toString() ?? '') ?? currentPage;
    return (items, currentPage, lastPage);
  }

  Future<List<ChatMessage>> fetchReadMarks(
      {required String conversationId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/chat/$conversationId/read', token: token);
    final map = Map<String, dynamic>.from(res as Map);
    final dataList = (map['data'] as List?) ?? const [];
    final items = dataList
        .whereType<Map>()
        .map((e) => ChatMessage.fromApiChat(Map<String, dynamic>.from(e)))
        .toList();
    return items;
  }
}
