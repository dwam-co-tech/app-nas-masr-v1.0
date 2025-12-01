// screens/ad_details_screen.dart (الكود النهائي بعد التعديلات المعمارية)

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/models/ad_details_model.dart';
import 'package:nas_masr_app/core/data/providers/ad_details_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_details_repository.dart';
import 'package:nas_masr_app/widgets/ad_details/car_details_panel.dart';
import 'package:nas_masr_app/widgets/ad_details/real_estate_details_panel.dart';
import 'package:nas_masr_app/widgets/ad_details/unified_details_panel.dart';
import 'package:nas_masr_app/widgets/ad_details/car_rental_details_panel.dart';
import 'package:nas_masr_app/widgets/ad_details/car_spare_parts_details_panel.dart';
import 'package:nas_masr_app/core/constatants/unified_categories.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import 'package:nas_masr_app/core/constatants/string.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/widgets/price_text.dart';
import 'package:nas_masr_app/core/utils/contact_launcher.dart';

class AdDetailsScreen extends StatelessWidget {
  final String categorySlug;
  final String categoryName;
  final String adId;
  //final AdDetailsModel? initialDetails; // لو أردنا تمرير بيانات أولية للصفحة

  const AdDetailsScreen({
    super.key,
    required this.categorySlug,
    required this.categoryName,
    required this.adId,
  });
  String _toArabicDigits(String s) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = s;
    for (var i = 0; i < en.length; i++) {
      out = out.replaceAll(en[i], ar[i]);
    }
    return out;
  }

  String _formatArabicDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString();
    final d = dt.day.toString();
    return _toArabicDigits('$y/$m/$d');
  }

  String _formatPriceWithCommas(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return s;
    final n = int.tryParse(cleaned);
    if (n == null) return s;
    return NumberFormat.decimalPattern().format(n);
  }

  String _toArabicHuman(String s) {
    var t = s.toLowerCase().replaceAll('ago', '').trim();
    t = t.replaceAll(RegExp(r'\ban\b'), '1');
    t = t
        .replaceAll('years', 'سنوات')
        .replaceAll('week', 'اسبوع')
        .replaceAll('year', 'سنة')
        .replaceAll('months', 'شهور')
        .replaceAll('month', 'شهر')
        .replaceAll('days', 'أيام')
        .replaceAll('day', 'يوم')
        .replaceAll('hours', 'ساعات')
        .replaceAll('hour', 'ساعة')
        .replaceAll('minutes', 'دقائق')
        .replaceAll('minute', 'دقيقة')
        .replaceAll('seconds', 'ثوانٍ')
        .replaceAll('second', 'ثانية');
    t = _toArabicDigits(t);
    return 'منذ $t';
  }

  // دالة تُحدد أي لوحة خصائص سيتم بناؤها بناءً على الـ Slug
  Widget _buildDynamicDetailsPanel(
      BuildContext context, String slug, Map<String, dynamic> attributes,
      {String? make, String? model}) {
    if (UnifiedCategories.slugs.contains(slug)) {
      return UnifiedDetailsPanel(attributes: attributes);
    }
    if (slug == 'cars') {
      return CarDetailsPanel(make: make, model: model, attributes: attributes);
    } else if (slug == 'real_estate') {
      return RealEstateDetailsPanel(attributes: attributes);
    } else if (slug == 'cars_rent') {
      return CarRentalDetailsPanel(attributes: attributes);
    } else if (slug == 'spare-parts') {
      return CarSparePartsDetailsPanel(attributes: attributes);
    }
    return const Center(child: Text('لا توجد لوحة تفاصيل لهذا القسم'));
  }

  // شريط الاتصال (ثابت لجميع الأقسام)

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Note: تم إنشاء AdDetailsRepository هنا مؤقتاً لتتمكن من تشغيل الـ Provider
    // يُفضل وضعها في قمة التطبيق (Main.dart) لو كانت shared service
    final detailsRepo = AdDetailsRepository();
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;

    return ChangeNotifierProvider(
        // إنشاء الـ Provider: يقوم بالتحميل بمجرد الـ Create
        create: (context) => AdDetailsProvider(
              repository: detailsRepo,
              adId: adId,
              categorySlug: categorySlug,
            ),
        child: Consumer<AdDetailsProvider>(builder: (context, provider, child) {
          // التعامل مع الـ Loading state
          if (provider.isLoading || provider.details == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          final adDetails = provider.details!;
          final cs = Theme.of(context).colorScheme;

          return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Scaffold(
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
                  title: Text(categoryName,
                      style: TextStyle(color: cs.onSurface))),
              body: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      child: SizedBox(
                        height: 250.h,
                        child: Builder(
                          builder: (context) {
                            final urls = <String>[];
                            if (adDetails.mainImageUrl != null &&
                                adDetails.mainImageUrl!.isNotEmpty) {
                              urls.add(adDetails.mainImageUrl!);
                            }
                            urls.addAll(adDetails.imagesUrls);
                            final pageController = PageController();
                            int current = 0;
                            return StatefulBuilder(
                              builder: (context, setStateSB) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: PageView.builder(
                                      controller: pageController,
                                      itemCount: urls.isEmpty ? 1 : urls.length,
                                      onPageChanged: (i) {
                                        setStateSB(() {
                                          current = i;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final url = urls.isEmpty
                                            ? 'https://via.placeholder.com/800x600/EEE/AAA?text=No+Image'
                                            : urls[index];
                                        return CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 10.h,
                                    left: 10.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.w, vertical: 5.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                        // border: Border.all(color: labelColor.withOpacity(0.4)),
                                      ),
                                      child: Icon(Icons.favorite_border,
                                          color: cs.secondary, size: 20.sp),
                                    ),
                                  ),
                                  Positioned(
                                    top: 52.h,
                                    left: 10.w,
                                    child: Icon(Icons.share,
                                        color: cs.secondary, size: 22.sp),
                                  ),
                                  Positioned(
                                    bottom: 12.h,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                          urls.isEmpty ? 1 : urls.length, (i) {
                                        final active = i == current;
                                        return Container(
                                          width: active ? 24.w : 8.w,
                                          height: 6.h,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4.w),
                                          decoration: BoxDecoration(
                                            color: active
                                                ? Colors.deepOrange
                                                : Colors.teal,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 2. العنوان الرئيسي والوصف (نستخدم بيانات الـ AdDetails)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: PriceText(
                                  price: adDetails.price,
                                  style: TextStyle(
                                      color: cs.secondary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (adDetails.createdAt != null)
                                Text(_formatArabicDate(adDetails.createdAt!),
                                    style: TextStyle(
                                        color: cs.primary,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w400)),
                            ],
                          ),
                          // SizedBox(height: 5.h),
                          _buildDynamicDetailsPanel(
                              context, categorySlug, adDetails.attributes,
                              make: adDetails.make, model: adDetails.model),
                          SizedBox(height: 15.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text('الوصف',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: cs.primary)),
                          ),
                          //  SizedBox(height: 3.h),
                        ],
                      ),
                    ),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool expanded = false;
                        final style = TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: cs.onSurface);
                        final tp = TextPainter(
                          text: TextSpan(
                              text: adDetails.description, style: style),
                          maxLines: 3,
                          textDirection: ui.TextDirection.rtl,
                        );
                        tp.layout(
                            maxWidth:
                                constraints.maxWidth - (16.w * 2) - (12.w * 2));
                        final needMore = tp.didExceedMaxLines;
                        final shouldShowMore = needMore;
                        return StatefulBuilder(
                          builder: (context, setStateSB) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromRGBO(0, 0, 0, 0.25)
                                        .withOpacity(.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      adDetails.description,
                                      style: style,
                                      maxLines: expanded ? null : 3,
                                      overflow: expanded
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                    ),
                                    if (shouldShowMore || expanded) ...[
                                      SizedBox(height: 8.h),
                                      GestureDetector(
                                        onTap: () {
                                          setStateSB(() {
                                            expanded = !expanded;
                                          });
                                        },
                                        child: Text(
                                          expanded
                                              ? 'قراءة أقل'
                                              : 'قراءة المزيد',
                                          style: TextStyle(
                                              color: cs.primary,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // 3. لوحة التفاصيل الديناميكية

                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المعلن',
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 10.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12.h),
                                    Text(
                                        (adDetails.sellerName == null ||
                                                adDetails.sellerName!
                                                    .trim()
                                                    .isEmpty)
                                            ? 'اسم المستخدم'
                                            : adDetails.sellerName!,
                                        style: TextStyle(
                                            color: cs.onSurface,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 6.h),
                                    GestureDetector(
                                      onTap: () {
                                        final uid = adDetails.sellerId;
                                        if (uid != null) {
                                          context.pushNamed('user_listings',
                                              extra: {
                                                'userId': uid,
                                                'initialSlug':
                                                    adDetails.categorySlug,
                                                'sellerName':
                                                    adDetails.sellerName ??
                                                        'المعلن',
                                              });
                                        }
                                      },
                                      child: Text(
                                          'عرض جميع الإعلانات (${_toArabicDigits('${adDetails.sellerListingsCount ?? 0}')} )',
                                          style: TextStyle(
                                              color: cs.secondary,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: cs.secondary,
                                              decorationStyle:
                                                  TextDecorationStyle.solid,
                                              decorationThickness: 2,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                        adDetails.sellerJoinedAtHuman != null &&
                                                adDetails.sellerJoinedAtHuman!
                                                    .isNotEmpty
                                            ? 'عضو ${_toArabicHuman(adDetails.sellerJoinedAtHuman!)}'
                                            : (adDetails.sellerJoinedAt != null
                                                ? 'عضو منذ ${_formatArabicDate(adDetails.sellerJoinedAt!)}'
                                                : 'عضو'),
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(1, 22, 24, 0.45),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 97.w,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF19AC84),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      onPressed: () =>
                                          ContactLauncher.openWhatsApp(
                                        context,
                                        whatsappNumber: adDetails.whatsappPhone,
                                        phoneNumber: adDetails.contactPhone,
                                      ),
                                      child: Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: FaIcon(
                                                  FontAwesomeIcons.whatsapp,
                                                  color: Colors.white,
                                                  size: 16.sp),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text('واتساب',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.sp)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  //  SizedBox(height: 3.h),
                                  SizedBox(
                                    width: 97.w,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF024950),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Icon(Icons.phone,
                                                  color: Colors.white,
                                                  size: 16.sp),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text('اتصال',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.sp)),
                                          ],
                                        ),
                                      ),
                                      onPressed: () =>
                                          ContactLauncher.openPhone(
                                        context,
                                        phoneNumber: adDetails.contactPhone,
                                        whatsappNumber: adDetails.whatsappPhone,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text('الموقع',
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              // Icon(Icons.location_on_outlined,
                              //     color: cs.secondary, size: 18.sp),
                              // SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  (adDetails.address.trim().isEmpty)
                                      ? 'موقع غير متاح'
                                      : adDetails.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: SizedBox(
                              height: 200.h,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    adDetails.lat ?? 30.0444,
                                    adDetails.lng ?? 31.2357,
                                  ),
                                  initialZoom: 13,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.all,
                                  ),
                                  onTap: (tapPosition, point) async {
                                    final lat = adDetails.lat ?? point.latitude;
                                    final lng =
                                        adDetails.lng ?? point.longitude;
                                    final addr = adDetails.address.trim();
                                    final query =
                                        addr.isNotEmpty ? addr : '$lat,$lng';
                                    final url = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
                                    try {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    } catch (_) {
                                      await launchUrl(url,
                                          mode: LaunchMode.platformDefault);
                                    }
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                    userAgentPackageName:
                                        'com.example.nas_masr_app',
                                    maxZoom: 19,
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          adDetails.lat ?? 30.0444,
                                          adDetails.lng ?? 31.2357,
                                        ),
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.location_on,
                                            color: Colors.red, size: 28.sp),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'الإبلاغ عن هذا الإعلان',
                                style: TextStyle(
                                  color: Color(0xFFEF6C31),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFFEF6C31),
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationThickness: 2,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final raw = adDetails.banner;
                        String? bannerUrl;
                        if (raw != null && raw.isNotEmpty) {
                          bannerUrl = raw.startsWith('http')
                              ? raw
                              : '$baseUrl${raw.startsWith('/') ? '' : '/'}$raw';
                        }
                        return ClipRRect(
                          child: SizedBox(
                            width: double.infinity,
                            height: 250.h,
                            child: bannerUrl == null
                                ? Transform.scale(
                                    scale: 2,
                                    child: Image.asset(
                                      'assets/images/paner_real_estare.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Transform.scale(
                                    scale: 1.08,
                                    child: CachedNetworkImage(
                                      imageUrl: bannerUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                          color: const Color(0xFFF0F2F5)),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: const Color(0xFFF0F2F5),
                                        child: Center(
                                          child: Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.grey.shade400,
                                              size: 32.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 50.h),
                  ])),
            ),
          );
        }));
  }
}
