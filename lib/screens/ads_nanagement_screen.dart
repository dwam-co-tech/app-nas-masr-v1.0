import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/widgets/ad_management_card.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/my_ads_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/my_ads_repository.dart';
import 'package:nas_masr_app/core/data/models/my_ads_model.dart';
import 'package:intl/intl.dart';
import 'package:nas_masr_app/screens/public/ad_edit_screen.dart';
import 'package:nas_masr_app/widgets/price_text.dart';
import 'package:go_router/go_router.dart';
// import 'path_to/ad_management_card.dart'; // لا تنس استدعاء الملف السابق

class AdsManagementScreen extends StatefulWidget {
  const AdsManagementScreen({super.key});

  @override
  State<AdsManagementScreen> createState() => _AdsManagementScreenState();
}

class _AdsManagementScreenState extends State<AdsManagementScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;

    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: ChangeNotifierProvider(
          create: (_) => MyAdsProvider(repository: MyAdsRepository()),
          child: Scaffold(
            bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                notificationPredicate: (notification) =>
                    notification is! ScrollNotification,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: InkWell(
                      onTap: () => context.pushNamed('notifications'),
                      child: Icon(Icons.notifications_rounded,
                          color: cs.onSurface, size: isLand ? 15.sp : 30.sp),
                    ),
                  ),
                ],
                title: Text("إدارة الاعلانات",
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700))),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("إعلاناتي",
                            style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface)),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                    child: Consumer<MyAdsProvider>(
                      builder: (context, prov, _) {
                        final ads = prov.ads;
                        int valid = 0;
                        int pending = 0;
                        int expired = 0;
                        int rejected = 0;
                        for (final a in ads) {
                          final s = (a.status ?? '').trim().toLowerCase();
                          if (s == 'valid') {
                            valid++;
                          } else if (s == 'pending') {
                            pending++;
                          } else if (s == 'expired') {
                            expired++;
                          } else if (s == 'rejected') {
                            rejected++;
                          }
                        }
                        return Row(
                          children: [
                            _buildFilterChip("فعال ($valid)", true),
                            _buildFilterChip("معلق ($pending)", false),
                            _buildFilterChip("منتهي ($expired)", false),
                            _buildFilterChip("مرفوض ($rejected)", false),
                          ],
                        );
                      },
                    ),
                  ),
                  Consumer<MyAdsProvider>(
                    builder: (context, prov, _) {
                      String fmtPrice(String? s) {
                        final cleaned =
                            (s ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                        if (cleaned.isEmpty) return '—';
                        final n = int.tryParse(cleaned);
                        if (n == null) return s ?? '—';
                        return NumberFormat.decimalPattern().format(n);
                      }

                      String fmtDate(DateTime? d) {
                        if (d == null) return '—';
                        return DateFormat('dd/MM/yyyy').format(d);
                      }

                      String planLabel(String? p) {
                        switch ((p ?? '').toLowerCase()) {
                          case 'featured':
                            return 'متميز';
                          case 'standard':
                            return 'ستاندرد';
                          case 'free':
                            return 'مجاني';
                          default:
                            return 'مجاني';
                        }
                      }

                      String mapTitle(MyAdItem ad) {
                        final cat = (ad.category ?? '').toLowerCase();
                        if (cat == 'real_estate') {
                          return ad.attributes['property_type']?.toString() ??
                              '—';
                        }
                        if (cat == 'cars') {
                          final mk = ad.make ??
                              ad.attributes['make']?.toString() ??
                              '';
                          final md = ad.model ??
                              ad.attributes['model']?.toString() ??
                              '';
                          final t = '$mk $md'.trim();
                          return t.isEmpty ? '—' : t;
                        }
                        return ad.title ?? ad.categoryName ?? 'إعلان';
                      }

                      String mapSubtitle(MyAdItem ad) {
                        final cat = (ad.category ?? '').toLowerCase();
                        if (cat == 'real_estate') {
                          return ad.attributes['contract_type']?.toString() ??
                              '';
                        }
                        if (cat == 'cars') {
                          return ad.attributes['year']?.toString() ?? '';
                        }
                        final gov = ad.governorate ?? '';
                        final city = ad.city ?? '';
                        final out =
                            [gov, city].where((e) => e.isNotEmpty).join('، ');
                        return out;
                      }

                      if (prov.loading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (prov.error != null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          child: Text('خطأ: ${prov.error!}',
                              style: const TextStyle(color: Colors.red)),
                        );
                      }
                      final ads = prov.ads;
                      if (ads.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          child: const Text('لا توجد إعلانات حتى الآن'),
                        );
                      }
                      return Column(
                        children: List.generate(ads.length, (i) {
                          final ad = ads[i];
                          final img = (ad.mainImageUrl ?? '').isEmpty
                              ? 'assets/images/logo.png'
                              : ad.mainImageUrl!;
                          final priceText = PriceText.formatPrice(ad.price);
                          return AdManagementCard(
                            title: mapTitle(ad),
                            subtitle: mapSubtitle(ad),
                            imageUrl: img,
                            price: priceText.trim(),
                            statusLabel: planLabel(ad.planType),
                            publishDate: fmtDate(ad.publishedAt),
                            expiryDate: fmtDate(ad.expire_at),
                            viewsCount: (ad.views ?? 0).toString(),
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content:
                                      const Text('هل تريد حذف هذا الإعلان؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('إلغاء')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('حذف')),
                                  ],
                                ),
                              );
                              if (confirmed != true) return;
                              try {
                                await context
                                    .read<MyAdsProvider>()
                                    .deleteAd(ad);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم حذف الإعلان بنجاح')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('فشل حذف الإعلان: $e')),
                                );
                              }
                            },
                            onRenew: () {},
                            onEdit: () async {
                              await context.push('/ad/edit', extra: {
                                'categorySlug': ad.category ?? '',
                                'adId': ad.id.toString(),
                                'categoryName': ad.categoryName,
                              });
                              if (context.mounted) {
                                context.read<MyAdsProvider>().loadMyAds();
                              }
                            },
                            onUpdate: () async {
                              try {
                                await context.read<MyAdsProvider>().renewAd(ad);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم تحديث ترتيب الإعلان')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$e')),
                                );
                              }
                            },
                            onImageTap: () {
                              context.push('/ad/details', extra: {
                                'categorySlug': ad.category ?? '',
                                'adId': ad.id.toString(),
                                'categoryName': ad.categoryName ?? '',
                              });
                            },
                          );
                        }),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildPackageCard(
    final ColorScheme cs, {
    required String title,
    required String expiry,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(right: BorderSide(color: color, width: 4.w)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text("نشط",
                    style: TextStyle(fontSize: 12.sp, color: color)),
              )
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text("تنتهي صلاحية الاعلانات والباقة بتاريخ ",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
              Text(expiry,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? ColorManager.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Color.fromRGBO(3, 110, 120, 1),
          fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
