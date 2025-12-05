import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/screens/ads_nanagement_screen.dart';
import 'package:nas_masr_app/screens/chose_category_create_ads.dart';
import 'package:nas_masr_app/screens/public/favorites_screen.dart';
import 'package:nas_masr_app/screens/public/notifications_screen.dart';
import 'package:nas_masr_app/screens/splash_screen.dart';
import 'package:nas_masr_app/screens/on_boarding_screen.dart';
import 'package:nas_masr_app/screens/login_screen.dart';
import 'package:nas_masr_app/screens/home.dart';
import 'package:nas_masr_app/screens/setting.dart';
import 'package:nas_masr_app/screens/profile_screen.dart';
import 'package:nas_masr_app/screens/edit_profile_screen.dart';
import 'package:nas_masr_app/screens/subscribe_packages_screen.dart';
import 'package:nas_masr_app/screens/payment_methods_screen.dart';
import 'package:nas_masr_app/screens/payment_success_screen.dart';
import 'package:nas_masr_app/screens/terms_screen.dart';
import 'package:nas_masr_app/screens/privacy_policy_screen.dart';
import 'package:nas_masr_app/screens/map_picker_screen.dart';
import 'package:nas_masr_app/screens/public/ad_creation_screen.dart';
import 'package:nas_masr_app/screens/public/ad_edit_screen.dart';
import 'package:nas_masr_app/screens/public/ad_details_screen.dart';
import 'package:nas_masr_app/screens/public/hom&best_ad_screen.dart';
import 'package:nas_masr_app/screens/public/filtered_ads_screen.dart';
import 'package:nas_masr_app/screens/public/seller_listings_screen.dart';
import 'package:nas_masr_app/screens/public/notifications_screen.dart';

// Centralized GoRouter configuration kept separate from main.dart
class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/creat_ad',
        name: '/creat_ad',
        builder: (context, state) => const ChoseCategoryCreateAds(),
      ),
      GoRoute(
        path: '/ad/create',
        name: 'ad_create',
        builder: (context, state) {
          final extra = state.extra;
          String slug = '';
          String name = '';
          if (extra is Map<String, dynamic>) {
            slug = (extra['categorySlug'] ?? '').toString();
            name = (extra['categoryName'] ?? '').toString();
          }
          return AdCreationScreen(categorySlug: slug, categoryName: name);
        },
      ),
      GoRoute(
        path: '/ad/edit',
        name: 'ad_edit',
        builder: (context, state) {
          final extra = state.extra;
          String slug = '';
          String adId = '';
          String? name;
          if (extra is Map<String, dynamic>) {
            slug = (extra['categorySlug'] ?? '').toString();
            adId = (extra['adId'] ?? '').toString();
            name = extra['categoryName']?.toString();
          }
          return EditAdScreen(
              categorySlug: slug, adId: adId, categoryName: name);
        },
      ),
      GoRoute(
        path: '/ad/details',
        name: 'ad_details',
        builder: (context, state) {
          final extra = state.extra;
          String slug = '';
          String name = '';
          String adId = '';
          if (extra is Map<String, dynamic>) {
            slug = (extra['categorySlug'] ?? '').toString();
            name = (extra['categoryName'] ?? '').toString();
            adId = (extra['adId'] ?? '').toString();
          }
          return AdDetailsScreen(
              categorySlug: slug, categoryName: name, adId: adId);
        },
      ),
      GoRoute(
        path: '/category',
        name: 'category_listing',
        builder: (context, state) {
          final extra = state.extra;
          String slug = '';
          String name = '';
          if (extra is Map<String, dynamic>) {
            slug = (extra['categorySlug'] ?? extra['slug'] ?? '').toString();
            name = (extra['categoryName'] ?? extra['name'] ?? '').toString();
          }
          return CategoryListingScreen(categorySlug: slug, categoryName: name);
        },
      ),
      GoRoute(
        path: '/ads/filtered',
        name: 'filtered_ads',
        builder: (context, state) {
          final extra = state.extra;
          String slug = '';
          String name = '';
          Map<String, dynamic> filters = const {};
          if (extra is Map<String, dynamic>) {
            slug = (extra['categorySlug'] ?? '').toString();
            name = (extra['categoryName'] ?? '').toString();
            final cf = extra['currentFilters'];
            if (cf is Map<String, dynamic>) filters = cf;
          }
          return FilteredAdsScreen(
            categorySlug: slug,
            categoryName: name,
            currentFilters: filters,
          );
        },
      ),
      GoRoute(
        path: '/manage_ads',
        name: '/manage_ads',
        builder: (context, state) => const AdsManagementScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Setting(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit_profile',
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic>? data;
          if (extra is Map<String, dynamic>) data = extra;
          return EditProfileScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/map-picker',
        name: 'map_picker',
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic>? data;
          if (extra is Map<String, dynamic>) data = extra;
          return MapPickerScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/packages/subscribe',
        name: 'packages_subscribe',
        builder: (context, state) {
          final extra = state.extra;
          String? initialSlug;
          String? initialName;
          int? listingId;
          if (extra is Map<String, dynamic>) {
            initialSlug = extra['initialSlug']?.toString();
            initialName = extra['initialName']?.toString();
            final rawId = extra['listingId'];
            if (rawId is int) {
              listingId = rawId;
            } else if (rawId != null) {
              listingId = int.tryParse(rawId.toString());
            }
          }
          return SubscribePackagesScreen(
            initialSlug: initialSlug,
            initialName: initialName,
            listingId: listingId,
          );
        },
      ),
      GoRoute(
        path: '/payment/checkout',
        name: 'payment_checkout',
        builder: (context, state) {
          final extra = state.extra;
          String? categorySlug;
          String? planType;
          int? listingId;
          int? price;
          if (extra is Map<String, dynamic>) {
            categorySlug = extra['categorySlug']?.toString() ??
                extra['initialSlug']?.toString();
            planType = extra['planType']?.toString();
            final rawListing = extra['listingId'];
            if (rawListing is int) {
              listingId = rawListing;
            } else if (rawListing != null) {
              listingId = int.tryParse(rawListing.toString());
            }
            final rawPrice = extra['price'];
            if (rawPrice is int) {
              price = rawPrice;
            } else if (rawPrice != null) {
              price = int.tryParse(rawPrice.toString());
            }
          }
          return PaymentMethodsScreen(
            categorySlug: categorySlug,
            planType: planType,
            listingId: listingId,
            initialPrice: price,
          );
        },
      ),
      GoRoute(
        path: '/payment/success',
        name: 'payment_success',
        builder: (context, state) {
          final extra = state.extra;
          int? amount;
          String? datetime;
          bool isSubscription = false;
          if (extra is Map<String, dynamic>) {
            final rawAmount = extra['amount'];
            if (rawAmount is int) {
              amount = rawAmount;
            } else if (rawAmount != null) {
              amount = int.tryParse(rawAmount.toString());
            }
            datetime = extra['datetime']?.toString();
            isSubscription = (extra['subscription'] == true);
          }
          return PaymentSuccessScreen(
              amount: amount,
              datetime: datetime,
              isSubscription: isSubscription);
        },
      ),
      GoRoute(
        path: '/user/listings',
        name: 'user_listings',
        builder: (context, state) {
          final extra = state.extra;
          int userId = 0;
          String? initialSlug;
          String? sellerName;
          if (extra is Map<String, dynamic>) {
            final idRaw = extra['userId'];
            if (idRaw is int) {
              userId = idRaw;
            } else if (idRaw != null) {
              userId = int.tryParse(idRaw.toString()) ?? 0;
            }
            initialSlug = extra['initialSlug']?.toString();
            sellerName = extra['sellerName']?.toString();
          }
          return SellerListingsScreen(
              userId: userId, initialSlug: initialSlug, sellerName: sellerName);
        },
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) {
          final extra = state.extra;
          String? initialSlug;
          if (extra is Map<String, dynamic>) {
            initialSlug = extra['initialSlug']?.toString();
          }
          return FavoritesScreen(initialSlug: initialSlug);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('صفحة غير موجودة: ${state.uri.path}'),
      ),
    ),
    // You can add redirect logic here later if needed.
  );
}
