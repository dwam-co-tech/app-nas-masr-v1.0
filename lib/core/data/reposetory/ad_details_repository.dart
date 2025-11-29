// core/data/reposetory/ad_details_repository.dart

import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/ad_details_model.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart'; // للـ Error Handling

class AdDetailsRepository {
  final ApiService _api;
  AdDetailsRepository({ApiService? api}) : _api = api ?? ApiService();

  // الدالة التي تجلب التفاصيل باستخدام الـ Slug والـ ID (التركيبة الصحيحة)
  Future<AdDetailsModel> fetchAdDetails({required String categorySlug, required String adId}) async {
    // بناء الـ Endpoint بالصيغة اللي أرسلتيها (باستخدام الـ ID مباشرة)
    final endpoint = '/api/v1/$categorySlug/listings/$adId';
    
    try {
      final response = await _api.get(endpoint);

      if (response is Map<String, dynamic> && response['data'] is Map<String, dynamic>) {
        // نُرسل الـ Map اللي فيه مفتاح 'data' للـ Model (للتطابق مع الـ Response)
        return AdDetailsModel.fromMap(response); 
      }
      
      throw Exception('Received unexpected data format for ad details.');

    } on AppError catch (e) {
      throw e; // إعادة رمي الـ Business Error للـ Provider
    } catch (e) {
      // For any unexpected Dio or other exception
      throw AppError('فشل في الاتصال لجلب تفاصيل الإعلان.',); 
    }
  }
}