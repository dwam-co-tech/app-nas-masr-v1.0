import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nas_masr_app/core/data/reposetory/auth_repository.dart';
import 'package:nas_masr_app/core/services/fcm_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  bool _loading = false;
  String? _token;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool get loading => _loading;
  String? get token => _token;

  Future<String?> register(
      {required String phone,
      required String password,
      String? referralCode}) async {
    _setLoading(true);
    try {
      final res = await _repository.register(
        phone: phone,
        password: password,
        referralCode: referralCode,
      );
      final t = res['token'];
      if (t is String && t.isNotEmpty) {
        _token = t;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', t);
        await FCMService().syncTokenWithBackend();
        return t;
      }
      throw Exception('لم يتم استلام التوكن من الخادم');
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // Delete FCM token from Firebase (but keep pending token locally for next login)
      await FCMService().deleteToken();

      // Clear ALL user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Get the pending FCM token before clearing (we want to keep it)
      final pendingFcmToken = prefs.getString('pending_fcm_token');
      final onboardingDone = prefs.getBool('onboarding_done');

      // Clear ALL keys
      await prefs.clear();

      // Restore only the values we want to keep
      if (pendingFcmToken != null) {
        await prefs.setString('pending_fcm_token', pendingFcmToken);
      }
      if (onboardingDone == true) {
        await prefs.setBool('onboarding_done', true);
      }

      _token = null;

      print('✅ Logout: All user data cleared from SharedPreferences');
      print(
          '   - Kept: pending_fcm_token${onboardingDone == true ? ', onboarding_done' : ''}');
    } finally {
      notifyListeners();
    }
  }
}
