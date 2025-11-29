import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/models/create_listing_payload.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class AdCreationRepository {
  final ApiService _api;
  AdCreationRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> createListing({
    required String categorySlug,
    required CreateListingPayload payload,
    required File mainImage,
    List<File> images = const [],
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final endpoint = '/api/v1/$categorySlug/listings';
      final data = payload.toFormMap();
      final res = await _api.postFormData(
        endpoint,
        data: data,
        mainImage: mainImage,
        thumbnailImages: images,
        token: token,
        imagesFieldName: 'images[]',
      );
      final out = <String, dynamic>{'raw': res};
      int? id;
      if (res is Map) {
        final map = Map<String, dynamic>.from(res as Map);
        final dataNode = map['data'] ?? map;
        if (dataNode is Map) {
          final rawId = (dataNode as Map)['id'] ??
              (dataNode as Map)['listing_id'] ??
              null;
          if (rawId != null) {
            id = int.tryParse(rawId.toString());
          }
        }
      }
      if (id != null) out['id'] = id;
      return out;
    } on AppError catch (e) {
      throw e;
    } catch (e) {
      throw AppError('فشل إضافة الإعلان');
    }
  }

  Future<Map<String, dynamic>> updateListing({
    required String categorySlug,
    required String id,
    required CreateListingPayload payload,
    File? mainImage,
    List<File> images = const [],
    String? remoteMainImageUrl,
    List<String> remoteImageUrls = const [],
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final endpoint = '/api/v1/$categorySlug/listings/$id';
      final data = payload.toFormMap();
      data['_method'] = 'PUT';

      final dio = Dio(BaseOptions(responseType: ResponseType.bytes));
      final List<File> mergedImages = List<File>.from(images);
      File? mainImageToSend = mainImage;

      // Include remote main image if a new main image is not selected
      if (mainImageToSend == null && (remoteMainImageUrl ?? '').isNotEmpty) {
        try {
          final resp = await dio.get(remoteMainImageUrl!);
          final bytes = resp.data as List<int>;
          final tmp = File(
              '${Directory.systemTemp.path}/main_${DateTime.now().microsecondsSinceEpoch}.jpg');
          await tmp.writeAsBytes(bytes);
          mainImageToSend = tmp;
        } catch (_) {}
      }

      // Include remote thumbs by downloading them
      for (final url in remoteImageUrls) {
        try {
          final r = await dio.get(url);
          final bytes = r.data as List<int>;
          final tmp = File(
              '${Directory.systemTemp.path}/img_${DateTime.now().microsecondsSinceEpoch}.jpg');
          await tmp.writeAsBytes(bytes);
          mergedImages.add(tmp);
        } catch (_) {}
      }

      final res = await _api.postFormData(
        endpoint,
        data: data,
        mainImage: mainImageToSend,
        thumbnailImages: mergedImages,
        token: token,
        imagesFieldName: 'images[]',
      );
      final out = <String, dynamic>{'raw': res};
      int? listingId;
      if (res is Map) {
        final map = Map<String, dynamic>.from(res as Map);
        final dataNode = map['data'] ?? map;
        if (dataNode is Map) {
          final rawId = (dataNode as Map)['id'] ??
              (dataNode as Map)['listing_id'] ??
              null;
          if (rawId != null) {
            listingId = int.tryParse(rawId.toString());
          }
        }
      }
      if (listingId != null) out['id'] = listingId;
      return out;
    } on AppError catch (e) {
      throw e;
    } catch (e) {
      throw AppError('فشل تعديل الإعلان');
    }
  }
}
