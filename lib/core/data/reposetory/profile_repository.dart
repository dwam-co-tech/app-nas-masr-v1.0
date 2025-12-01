import 'package:nas_masr_app/core/data/models/profile.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';
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
    final res =
        await _api.put('/api/edit-profile', data: payload, token: token);
    final data = (res is Map) ? res['data'] : null;
    if (data is Map<String, dynamic>) {
      return Profile.fromApi(data);
    }
    // لو الخادم لا يرجع نسخة جديدة، أعد التحميل
    return getProfile();
  }

  Future<bool> verifyOtp(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw AppError('غير مسجل الدخول');
    }
    print('VERIFY_OTP_REQUEST otp=$otp token_present=${token.isNotEmpty}');
    final res =
        await _api.post('/api/verify-otp', data: {'otp': otp}, token: token);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res as Map);
      final status = map['status']?.toString().toLowerCase();
      String? message = map['message']?.toString();
      final msgLower = (message ?? '').toLowerCase();
      final success = map['success'] == true ||
          status == 'success' ||
          status == 'ok' ||
          msgLower.contains('otp verified successfully') ||
          msgLower.contains('verified') ||
          msgLower.contains('success');
      if (!success) {
        print(
            'VERIFY_OTP_FAILED status=$status message=${message ?? 'null'} response=$map');
      } else {
        print('VERIFY_OTP_SUCCESS');
      }
      return success;
    }
    print(
        'VERIFY_OTP_UNEXPECTED response_type=${res.runtimeType} response=$res');
    return true;
  }
}
