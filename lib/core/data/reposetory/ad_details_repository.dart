// core/data/reposetory/ad_details_repository.dart

import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/ad_details_model.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart'; // للـ Error Handling

class AdDetailsRepository {
  final ApiService _api;
  AdDetailsRepository({ApiService? api}) : _api = api ?? ApiService();

  // الدالة التي تجلب التفاصيل باستخدام الـ Slug والـ ID (التركيبة الصحيحة)
  Future<AdDetailsModel> fetchAdDetails(
      {required String categorySlug,
      required String adId,
      String? token}) async {
    // بناء الـ Endpoint بالصيغة اللي أرسلتيها (باستخدام الـ ID مباشرة)
    final endpoint = '/api/v1/$categorySlug/listings/$adId';

    try {
      final response = await _api.get(endpoint, token: token);

      if (response is Map<String, dynamic> &&
          response['data'] is Map<String, dynamic>) {
        // نُرسل الـ Map اللي فيه مفتاح 'data' للـ Model (للتطابق مع الـ Response)
        return AdDetailsModel.fromMap(response);
      }

      throw Exception('Received unexpected data format for ad details.');
    } on AppError catch (e) {
      throw e; // إعادة رمي الـ Business Error للـ Provider
    } catch (e) {
      // For any unexpected Dio or other exception
      throw AppError(
        'فشل في الاتصال لجلب تفاصيل الإعلان.',
      );
    }
  }

  Future<void> reportListing({required String adId, required String reason, String? token}) async {
    final endpoint = '/api/listings/$adId/report';
    try {
      await _api.post(endpoint, data: {'reason': reason}, token: token);
    } on AppError catch (e) {
      throw e;
    } catch (e) {
      throw AppError('فشل إرسال البلاغ عن الإعلان.');
    }
  }
}
