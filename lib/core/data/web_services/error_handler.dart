import 'package:dio/dio.dart';

class AppError implements Exception {
  final String message;
  final int? statusCode;
  AppError(this.message, {this.statusCode});
  @override
  String toString() => message; // منع بادئة "Exception:" في العرض
}

// يمكن تحويل هذه لفئة لمعالجة أخطاء أكثر تعقيدًا في المستقبل
class ErrorHandler {
  static const Map<String, String> _arabicFieldNames = {
    'password': 'كلمة المرور',
    'phone': 'رقم الهاتف',
    'code': 'كود المندوب',
    'email': 'البريد الإلكتروني',
    'username': 'اسم المستخدم',
  };
  
  // دالة ثابتة يمكن استدعاؤها مباشرة من الكلاس
  static Exception handleDioError(DioException e) {
    // لو السيرفر رد علينا بخطأ (زي 404, 500, 401)
    if (e.response != null) {
      print('Error Response Data: ${e.response?.data}');
      print('Error Response Status Code: ${e.response?.statusCode}');
      
      // هنا ممكن تفصل الأخطاء بناءً على status code
      switch (e.response?.statusCode) {
        case 400: // Bad Request
          return AppError("طلب غير صالح، تحقق من البيانات المدخلة.", statusCode: 400);
        case 401: // Unauthorized
        case 403: // Forbidden
          // افترض أن الباك اند بيرجع رسالة الخطأ في 'message'
          final raw = e.response?.data['message']?.toString();
          final msg = _translateGeneralMessage(raw ?? "بيانات الدخول غير صحيحة.");
          return AppError(msg, statusCode: e.response?.statusCode);
        case 404: // Not Found
          // For search/browse endpoints, return a more specific error
          // This will help identify if the API endpoints are actually missing
          final endpoint = e.requestOptions.path;
          return AppError("API endpoint not found: $endpoint - البيانات المطلوبة غير موجودة.", statusCode: 404);
        case 422: // Validation Error
          // للأخطاء التحقق من صحة البيانات، نحتفظ بالرسالة الأصلية
          final responseData = e.response?.data;
          if (responseData != null && responseData is Map) {
            // إذا كان هناك أخطاء في حقول معينة
            if (responseData['errors'] != null) {
              final msg = _extractValidationMessageAr(responseData['errors']);
              return AppError(msg, statusCode: 422);
            }
            // إذا كان هناك رسالة عامة
            if (responseData['message'] != null) {
              return AppError(_translateGeneralMessage(responseData['message'].toString()), statusCode: 422);
            }
            // بعض الـ APIs ترجع الحقل 'error' بدلاً من 'message'
            if (responseData['error'] != null) {
              return AppError(_translateGeneralMessage(responseData['error'].toString()), statusCode: 422);
            }
          }
          return AppError("خطأ في التحقق من صحة البيانات.", statusCode: 422);
        case 500: // Internal Server Error
        default:
          return AppError("حدث خطأ من الخادم، حاول مرة أخرى لاحقًا.", statusCode: e.response?.statusCode);
      }
    } else {
      // لو مفيش رد من السيرفر أساسًا (مشكلة في الاتصال أو مهلة)
      print('Error sending request: $e');
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          return AppError("انتهت مهلة الاتصال بالخادم.");
      }
      return AppError("لا يمكن الاتصال بالخادم، تحقق من اتصالك بالإنترنت.");
    }
  }

  // يمكن إضافة دوال أخرى لمعالجة أنواع أخرى من الأخطاء هنا
  static String _extractValidationMessageAr(dynamic errors) {
    // errors قد تكون Map<String, List<String>> أو Map<String, dynamic>
    if (errors is Map) {
      final msgs = <String>[];
      errors.forEach((key, value) {
        final fieldAr = _arabicFieldNames[key] ?? key;
        if (value is List) {
          for (final m in value) {
            msgs.add(_translateValidationMessageForField(fieldAr, m.toString()));
          }
        } else if (value != null) {
          msgs.add(_translateValidationMessageForField(fieldAr, value.toString()));
        }
      });
      if (msgs.isNotEmpty) {
        return msgs.join('\n');
      }
    }
    return 'خطأ في التحقق من صحة البيانات.';
  }

  static String _translateValidationMessageForField(String fieldAr, String message) {
    final lower = message.toLowerCase();
    final reAtLeast = RegExp(r'must be at least\s*(\d+)\s*characters');
    final mAtLeast = reAtLeast.firstMatch(lower);
    if (mAtLeast != null) {
      final n = mAtLeast.group(1) ?? '';
      return '$fieldAr يجب أن تكون $n أحرف على الأقل';
    }
    if (lower.contains('has already been taken')) {
      return '$fieldAr مستخدم بالفعل';
    }
    if (RegExp(r'the selected .* is invalid').hasMatch(lower) || lower.contains('is invalid')) {
      return '$fieldAr غير صحيح';
    }
    final reRequired = RegExp(r'the .* field is required|is required');
    if (reRequired.hasMatch(lower)) {
      return 'حقل $fieldAr مطلوب';
    }
    if (lower.contains('invalid credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (lower.contains('unauthenticated')) {
      return 'غير مصرح بالدخول';
    }
    // fallback: استبدال كلمات الحقول الشائعة إن وجدت
    return message
        .replaceAll(RegExp(r'\bpassword\b', caseSensitive: false), fieldAr)
        .replaceAll(RegExp(r'\bphone\b', caseSensitive: false), fieldAr);
  }

  static String _translateGeneralMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('referral code not found')) {
      return 'لا يوجد رقم مندوب بهذا الرقم';
    }
    if (lower.contains('invalid credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (lower.contains('unauthenticated')) {
      return 'غير مصرح بالدخول';
    }
    if (lower.contains('server error')) {
      return 'حدث خطأ من الخادم، حاول مرة أخرى لاحقًا';
    }
    if (lower.contains('not found')) {
      return 'المورد المطلوب غير موجود';
    }
    // حاول ترجمة رسائل التحقق العامة بدون حقل
    final reAtLeast = RegExp(r'must be at least\s*(\d+)\s*characters');
    final mAtLeast = reAtLeast.firstMatch(lower);
    if (mAtLeast != null) {
      final n = mAtLeast.group(1) ?? '';
      return 'يجب أن تكون $n أحرف على الأقل';
    }
    return message; // إن لم تُعرف، نحتفظ بالنص كما هو
  }
}