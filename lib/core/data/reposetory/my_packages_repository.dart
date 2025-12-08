import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/my_packages_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MyPlansResult {
  final List<MyPackage> packages;
  final List<MySubscription> subscriptions;
  MyPlansResult({required this.packages, required this.subscriptions});
}

class MyPackagesRepository {
  final ApiService _api;
  MyPackagesRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<MyPlansResult> getMyPlans() async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    } catch (_) {}
    final res = await _api.get('/api/my-plans', token: token);
    final List<MyPackage> pkgs = [];
    final List<MySubscription> subs = [];
    if (res is Map<String, dynamic>) {
      final packagesList = res['packages'];
      final subsList = res['subscriptions'];
      if (packagesList is List) {
        for (final e in packagesList.whereType<Map<String, dynamic>>()) {
          final active = (e['active'] as bool?) ?? false;
          final expires = e['expires_at']?.toString();
          String? expiresHuman;
          if (expires != null) {
            final dt = DateTime.tryParse(expires);
            if (dt != null) {
              expiresHuman = DateFormat('dd/MM/yyyy').format(dt);
            }
          }
          final map = {
            'title': e['title']?.toString() ?? '',
            'badge_text': active ? 'نشطة' : 'غير نشطة',
            'expires_at_human': expiresHuman,
          };
          pkgs.add(MyPackage.fromMap(map));
        }
      }
      if (subsList is List) {
        for (final m in subsList.whereType<Map<String, dynamic>>()) {
          subs.add(MySubscription.fromMap(m));
        }
      }
    }
    return MyPlansResult(packages: pkgs, subscriptions: subs);
  }
}
