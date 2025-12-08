import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nas_masr_app/core/data/reposetory/auth_repository.dart';

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _token = null;
    } finally {
      notifyListeners();
    }
  }
}
