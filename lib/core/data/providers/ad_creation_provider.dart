import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nas_masr_app/core/data/models/create_listing_payload.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_creation_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class AdCreationProvider with ChangeNotifier {
  final AdCreationRepository _repo;
  bool _submitting = false;
  String? _error;
  int? _lastCreatedId;
  dynamic _lastResponse;

  AdCreationProvider({required AdCreationRepository repository})
      : _repo = repository;

  bool get submitting => _submitting;
  String? get error => _error;
  int? get lastCreatedId => _lastCreatedId;
  dynamic get lastResponse => _lastResponse;

  Future<bool> submitListing({
    required String categorySlug,
    required CreateListingPayload payload,
    required File mainImage,
    List<File> images = const [],
  }) async {
    _setSubmitting(true);
    _setError(null);
    try {
      final res = await _repo.createListing(
        categorySlug: categorySlug,
        payload: payload,
        mainImage: mainImage,
        images: images,
      );
      _lastResponse = res;
      if (res is Map<String, dynamic> && res['id'] is int) {
        _lastCreatedId = res['id'] as int;
      } else if (res is Map<String, dynamic> && res['id'] != null) {
        final v = res['id'];
        _lastCreatedId = int.tryParse(v.toString());
      }
      _setSubmitting(false);
      return true;
    } on AppError catch (e) {
      _setError(e.message);
      _setSubmitting(false);
      return false;
    } catch (e) {
      _setError('حدث خطأ أثناء إضافة الإعلان');
      _setSubmitting(false);
      return false;
    }
  }

  Future<bool> updateListing({
    required String categorySlug,
    required String id,
    required CreateListingPayload payload,
    File? mainImage,
    List<File> images = const [],
    String? remoteMainImageUrl,
    List<String> remoteImageUrls = const [],
  }) async {
    _setSubmitting(true);
    _setError(null);
    try {
      final res = await _repo.updateListing(
        categorySlug: categorySlug,
        id: id,
        payload: payload,
        mainImage: mainImage,
        images: images,
        remoteMainImageUrl: remoteMainImageUrl,
        remoteImageUrls: remoteImageUrls,
      );
      _lastResponse = res;
      if (res is Map<String, dynamic> && res['id'] is int) {
        _lastCreatedId = res['id'] as int;
      } else if (res is Map<String, dynamic> && res['id'] != null) {
        final v = res['id'];
        _lastCreatedId = int.tryParse(v.toString());
      }
      _setSubmitting(false);
      return true;
    } on AppError catch (e) {
      _setError(e.message);
      _setSubmitting(false);
      return false;
    } catch (e) {
      _setError('حدث خطأ أثناء تعديل الإعلان');
      _setSubmitting(false);
      return false;
    }
  }

  void _setSubmitting(bool v) {
    _submitting = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }
}
