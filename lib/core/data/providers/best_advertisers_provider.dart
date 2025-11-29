// core/data/providers/best_advertisers_provider.dart

import 'package:flutter/material.dart';
import '../models/premium_advertiser.dart'; 
import '../reposetory/best_advertisers_repository.dart'; 

class BestAdvertisersProvider with ChangeNotifier {
  final BestAdvertisersRepository _bestRepo;
  final String categorySlug;

  List<PremiumAdvertiser> _advertisers = [];
  bool _isLoading = false;

  List<PremiumAdvertiser> get advertisers => _advertisers;
  bool get isLoading => _isLoading;

 BestAdvertisersProvider({
    required BestAdvertisersRepository bestRepo, // <<< تم التغيير
    required this.categorySlug,
  }) : _bestRepo = bestRepo // تخزينها في المتغير الـ Private الداخلي
  {
    fetchAdvertisers();
  }

  Future<void> fetchAdvertisers() async {
    _setIsLoading(true);
    try {
      final results = await _bestRepo.getPremiumAdvertisers(categorySlug);
      _advertisers = results;
    } catch (e) {
      // Log Errors
      _advertisers = [];
    } finally {
      _setIsLoading(false);
    }
  }
  
  void _setIsLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}