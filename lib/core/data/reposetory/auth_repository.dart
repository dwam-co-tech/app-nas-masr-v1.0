import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  /// يستدعي واجهة التسجيل ويُرجع البيانات كما هي من الخادم
  /// Endpoint: /api/register
  /// Body: { "phone": phone, "password": password }
  Future<Map<String, dynamic>> register({required String phone, required String password}) async {
    final payload = {
      'phone': phone,
      'password': password,
    };

    final res = await _api.post('/api/register', data: payload);
    if (res is Map<String, dynamic>) {
      return res;
    }
    throw AppError('استجابة غير متوقعة من الخادم',);
  }
}