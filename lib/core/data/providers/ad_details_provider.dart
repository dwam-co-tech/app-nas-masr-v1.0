import 'package:flutter/material.dart';
import 'package:nas_masr_app/core/data/models/ad_details_model.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_details_repository.dart'; 
import 'package:nas_masr_app/core/data/web_services/error_handler.dart'; // لتسجيل وإدارة الأخطاء

class AdDetailsProvider with ChangeNotifier {
  final AdDetailsRepository _repo; // لتنفيذ الـ API Call
  final String _adId; // ID الإعلان
  final String _categorySlug; // الـ Slug (Cars, RealEstate) لجلب البيانات من EndPoint صحيح

  AdDetailsModel? _details; // البيانات النهائية
  bool _isLoading = false;
  String? _error;

  // Getters للـ UI
  AdDetailsModel? get details => _details;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get categorySlug => _categorySlug; // نحتاجه لو الـ UI استخدمه لأسباب معينة
  
  // Constructor لإنشاء الـ Provider و بدء التحميل مباشرةً
  AdDetailsProvider({
    required AdDetailsRepository repository, 
    required String adId, 
    required String categorySlug
  })  : _repo = repository, 
        _adId = adId, 
        _categorySlug = categorySlug {
    // يبدأ التحميل بمجرد إنشاء الـ Provider
    fetchDetails(_adId);
  }
  
  // دالة جلب البيانات الحقيقية من الـ Repository
  Future<void> fetchDetails(String adId) async {
    _setLoading(true);
    _setError(null);

    try {
      // الـ Call الحقيقي لـ API باستخدام الـ Slug والـ ID
      final response = await _repo.fetchAdDetails(
        categorySlug: _categorySlug, 
        adId: adId
      );
      
      _details = response; // يتم حفظ الموديل الكامل هنا

    } on AppError catch (e) {
      _setError(e.message); // إظهار الرسالة لو فيه خطأ من الـ Business Logic
    } catch (e) {
      // إظهار رسالة عامة لأي خطأ آخر غير متوقع
      _setError('فشل في تحميل تفاصيل الإعلان. يرجى المحاولة لاحقاً.');
    } finally {
      // إيقاف حالة التحميل
      _setLoading(false);
    }
  }

  // الدوال المساعِدة لتحديث الحالة
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }
}