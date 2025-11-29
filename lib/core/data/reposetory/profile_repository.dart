import 'package:nas_masr_app/core/data/models/profile.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final ApiService _api;
  ProfileRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.get('/api/get-profile', token: token);
    final data = (res is Map) ? res['data'] : null;
    if (data is Map<String, dynamic>) {
      return Profile.fromApi(data);
    }
    // fallback empty
    return const Profile(id: '');
  }

  Future<Profile> updateProfile(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final res = await _api.put('/api/edit-profile', data: payload, token: token);
    final data = (res is Map) ? res['data'] : null;
    if (data is Map<String, dynamic>) {
      return Profile.fromApi(data);
    }
    // لو الخادم لا يرجع نسخة جديدة، أعد التحميل
    return getProfile();
  }
}