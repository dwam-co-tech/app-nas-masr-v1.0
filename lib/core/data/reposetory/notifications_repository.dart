import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String category; // admin, customers
  final DateTime? createdAt;
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.createdAt,
  });
}

class NotificationsRepository {
  final ApiService _api;
  NotificationsRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<NotificationItem>> getNotifications({String? category}) async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } catch (_) {}
    try {
      final res = await _api.get('/api/notifications',
          query: category != null && category.isNotEmpty
              ? {'category': category}
              : null,
          token: token);
      final List list = (res is Map && res['data'] is List)
          ? (res['data'] as List)
          : (res is List ? res : const []);
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return NotificationItem(
          id: (m['id'] as num?)?.toInt() ?? 0,
          title: m['title']?.toString() ?? '',
          body: m['body']?.toString() ?? '',
          category: m['category']?.toString() ?? 'admin',
          createdAt: m['created_at'] != null
              ? DateTime.tryParse(m['created_at'].toString())
              : null,
        );
      }).toList();
    } catch (_) {
      return _stub();
    }
  }

  List<NotificationItem> _stub() {
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 1,
        title: 'إشعار هام',
        body: 'تحديث هام بالنظام، يرجى مراجعة التفاصيل.',
        category: 'admin',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: 2,
        title: 'طلب جديد',
        body: 'وصل طلب جديد من عميل، راجع الطلب في لوحة التحكم.',
        category: 'customers',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

