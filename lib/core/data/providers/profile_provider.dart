import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/profile.dart';
import 'package:nas_masr_app/core/data/reposetory/profile_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repo;
  ProfileProvider({required ProfileRepository repository}) : _repo = repository;

  bool _loading = false;
  String? _error;
  Profile? _profile;

  bool get loading => _loading;
  String? get error => _error;
  Profile? get profile => _profile;

  Future<void> loadProfile() async {
    _setLoading(true);
    _setError(null);
    try {
      _profile = await _repo.getProfile();
    } catch (e) {
      _setError('حدث خطأ أثناء تحميل الملف الشخصي');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _repo.updateProfile(payload);
      _profile = updated;
      notifyListeners();
      return true;
    } catch (e) {
      String msg = 'حدث خطأ أثناء حفظ التغييرات';
      if (e is AppError) {
        final lower = e.message.toLowerCase();
        if (lower.contains('referral code not found')) {
          msg = 'لا يوجد رقم مندوب بهذا الرقم';
        } else {
          msg = e.message;
        }
      }
      _setError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _repo.verifyOtp(otp);
      if (ok) {
        try {
          await loadProfile();
        } catch (_) {}
        print('VERIFY_OTP_PROVIDER_OK');
      } else {
        print('VERIFY_OTP_PROVIDER_FALSE otp=$otp');
      }
      return ok;
    } catch (e) {
      String msg = 'فشل التحقق من الكود';
      if (e is AppError) msg = e.message;
      print('VERIFY_OTP_PROVIDER_ERROR: $msg');
      _setError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
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
