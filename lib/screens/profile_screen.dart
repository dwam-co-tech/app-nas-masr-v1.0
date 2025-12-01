import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:nas_masr_app/widgets/map_action_button.dart';
import 'package:nas_masr_app/widgets/map_round_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();

  String agentCode = '';
  String username = '';
  String phone = '';
  String password = '';
  String? delegateNumber;
  double? latitude;
  double? longitude;
  String _mapStyle = 'hot';
  String? _address;
  bool _phoneVerified = false;
  Map<String, dynamic> get _profileMap => {
        'id': agentCode,
        'name': username,
        'phone': phone,
        'referral_code': delegateNumber,
        'lat': latitude,
        'lng': longitude,
        'address': _address,
      };

  String _display(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return 'enter $fieldName';
    return v;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileProvider>().loadProfile());
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: const Text(
                    'خدمة الموقع غير مفعلة. قم بتفعيلها من الإعدادات.',
                    textAlign: TextAlign.right),
              ),
            ),
          );
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted == PermissionStatus.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Directionality(
                textDirection: TextDirection.rtl,
                child:
                    const Text('تم رفض إذن الموقع', textAlign: TextAlign.right),
              ),
            ),
          );
          return;
        }
      }
      if (permissionGranted == PermissionStatus.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: const Text('إذن الموقع مرفوض نهائياً، فعّله من الإعدادات.',
                  textAlign: TextAlign.right),
            ),
          ),
        );
        return;
      }

      final data = await location.getLocation();
      setState(() {
        latitude = data.latitude;
        longitude = data.longitude;
      });
      try {
        if (latitude != null && longitude != null) {
          final placemarks = await geocoding.placemarkFromCoordinates(
            latitude!,
            longitude!,
            localeIdentifier: 'ar',
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = <String?>[
              p.street,
              p.subLocality,
              p.locality,
              p.administrativeArea,
              p.country,
            ]
                .where((s) => s != null && s!.trim().isNotEmpty)
                .cast<String>()
                .toList();
            setState(() {
              _address = parts.join('، ');
            });
          }
        }
      } catch (_) {}
      try {
        if (mounted && latitude != null && longitude != null) {
          _mapController.move(latlng.LatLng(latitude!, longitude!), 16);
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child:
                const Text('تم تحديد الموقع بنجاح', textAlign: TextAlign.right),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text('تعذر تحديد الموقع: $e', textAlign: TextAlign.right),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profileState = context.watch<ProfileProvider>();
    final prof = profileState.profile;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (prof != null) {
      agentCode = prof.code ?? '';
      username = prof.name ?? '';
      phone = prof.phone ?? '';
      delegateNumber = prof.referralCode;
      latitude = latitude ?? prof.lat;
      longitude = longitude ?? prof.lng;
      _address = _address ?? prof.address;
      _phoneVerified = prof.otpVerified == true;
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: isRTL
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  color: cs.onSurface,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                )
              : null,
          actions: isRTL
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    color: cs.onSurface,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ],
          centerTitle: true,
          title: Text(
            'الملف الشخصي',
            style: tt.titleLarge,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (profileState.loading) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(
                          child: CircularProgressIndicator(color: cs.primary)),
                    ),
                  ],
                  // GestureDetector(
                  //   onTap: _showEditDialog,
                  //   child: AbsorbPointer(
                  //     child: CustomTextField(
                  //       key: ValueKey('code-$agentCode'),
                  //       labelText: 'كود المندوب',
                  //       initialValue: agentCode.isEmpty ? 'قم بانشاء كود من صفحة الاعدادات' : agentCode,
                  //       readOnly: true,
                  //     ),
                  //   ),
                  // ),
                  //   SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _showEditDialog,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        key: ValueKey('name-$username'),
                        labelText: '*اسم المستخدم',
                        initialValue: _display(username, 'name'),
                        readOnly: true,
                      ),
                    ),
                  ),
                  //     SizedBox(height: 8.h),
                  CustomTextField(
                    key: ValueKey('phone-$phone'),
                    labelText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    initialValue: _display(phone, 'phone'),
                    readOnly: true,
                    textDirection: TextDirection.rtl,
                    suffix: _phoneVerified
                        ? Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 8.0),
                            child: Icon(Icons.verified_rounded,
                                color: Colors.green))
                        : GestureDetector(
                            onTap: _showOtpDialog,
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 8.0),
                              child: Text(
                                'تأكيد',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ),
                  ),
                  //   SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _showEditDialog,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        key: const ValueKey('password-******'),
                        labelText: 'كلمة المرور',
                        isPassword: true,
                        initialValue: '********',
                        readOnly: true,
                      ),
                    ),
                  ),
                  //   SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _showEditDialog,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        key: ValueKey('ref-$delegateNumber'),
                        labelText: 'رقم المندوب',
                        isOptional: true,
                        hintText: 'XXXX',
                        initialValue: _display(delegateNumber, 'referral_code'),
                        readOnly: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '*الموقع',
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                        // fontFamily: 'Tajawal'
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      (prof?.address?.trim().isNotEmpty == true)
                          ? prof!.address!
                          : (_address ?? 'لم يتم التحديد بعد'),
                      textAlign: TextAlign.right,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _mapWidget(context),
                  SizedBox(height: 10.h),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push('/profile/edit', extra: _profileMap),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: const Text('تعديل الملف الشخصي '),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  latlng.LatLng _center() {
    final defaultCairo = latlng.LatLng(30.0444, 31.2357);
    if (latitude == null || longitude == null) return defaultCairo;
    return latlng.LatLng(latitude!, longitude!);
  }

  Widget _mapWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final double mapH =
        isLand ? (size.height * 0.35).clamp(160.0, 260.0) : 220.h;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: mapH,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F6),
          border: Border.all(color: const Color(0xFFE0E3E5)),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center(),
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: _mapStyle == 'hot'
                      ? 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
                      : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.nas_masr_app',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center(),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.location_on,
                        color: ColorManager.secondaryColor,
                        size: 40.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(
                children: [
                  MapRoundIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      _mapController.move(_center(),
                          (_mapController.camera.zoom + 1).clamp(3, 19));
                    },
                  ),
                  SizedBox(height: 6.h),
                  MapRoundIconButton(
                    icon: Icons.remove,
                    onPressed: () {
                      _mapController.move(_center(),
                          (_mapController.camera.zoom - 1).clamp(3, 19));
                    },
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: 8,
              start: 8,
              child: MapActionButton(
                label: 'تحديد موقعي',
                onTap: () => context.push('/map-picker', extra: _profileMap),
                color: ColorManager.secondaryColor,
                textColor: Colors.white,
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('عادي'),
                    selected: _mapStyle == 'hot',
                    onSelected: (_) => setState(() => _mapStyle = 'hot'),
                  ),
                  SizedBox(width: 6.w),
                  ChoiceChip(
                      label: const Text('ملون'),
                      selected: _mapStyle == 'standard',
                      onSelected: (_) => setState(() => _mapStyle = 'standard'),
                      selectedColor:
                          ColorManager.secondaryColor.withOpacity(.85),
                      labelStyle: const TextStyle(color: Colors.black),
                      disabledColor: const Color.fromARGB(255, 92, 89, 89)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cs.surface,
            title: const Text('تنبيه', textAlign: TextAlign.right),
            content: const Text('هل ترغب في تعديل هذا الحقل؟',
                textAlign: TextAlign.right),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/profile/edit', extra: _profileMap);
                },
                child: const Text('تعديل'),
              )
            ],
          ),
        );
      },
    );
  }

  void _showOtpDialog() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final d1 = TextEditingController();
    final d2 = TextEditingController();
    final d3 = TextEditingController();
    final d4 = TextEditingController();
    final f1 = FocusNode();
    final f2 = FocusNode();
    final f3 = FocusNode();
    final f4 = FocusNode();
    bool submitting = false;
    String otpText = '';
    int activeIndex = 0;
    final ctrls = [d1, d2, d3, d4];
    final nodes = [f1, f2, f3, f4];
    bool initializedFocus = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) {
              if (!initializedFocus) {
                initializedFocus = true;
                Future.microtask(() => nodes[activeIndex].requestFocus());
              }
              return AlertDialog(
                backgroundColor: cs.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                titlePadding: const EdgeInsetsDirectional.only(
                    start: 16, end: 16, top: 12, bottom: 4),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text('تأكيد رقم الهاتف',
                    textAlign: TextAlign.center,
                    style: tt.titleMedium
                        ?.copyWith(color: cs.onSurface, fontSize: 22.sp)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('اكتب الكود المكون من 4 أرقام المرسل إلى هاتفك',
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _otpBox(
                            d1,
                            f1,
                            enabled: activeIndex == 0,
                            next: f2,
                            setState: setState,
                            prev: null,
                            onChanged: () {
                              otpText =
                                  [d1.text, d2.text, d3.text, d4.text].join();
                              int idx = ctrls.indexWhere((c) => c.text.isEmpty);
                              if (idx == -1) idx = 3;
                              activeIndex = idx;
                              setState(() {});
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                nodes[activeIndex].requestFocus();
                              });
                            },
                            onTapInactive: () {
                              nodes[activeIndex].requestFocus();
                            },
                          ),
                          const SizedBox(width: 8),
                          _otpBox(
                            d2,
                            f2,
                            enabled: activeIndex == 1,
                            next: f3,
                            setState: setState,
                            prev: f1,
                            onChanged: () {
                              otpText =
                                  [d1.text, d2.text, d3.text, d4.text].join();
                              int idx = ctrls.indexWhere((c) => c.text.isEmpty);
                              if (idx == -1) idx = 3;
                              activeIndex = idx;
                              setState(() {});
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                nodes[activeIndex].requestFocus();
                              });
                            },
                            onTapInactive: () {
                              nodes[activeIndex].requestFocus();
                            },
                          ),
                          const SizedBox(width: 8),
                          _otpBox(
                            d3,
                            f3,
                            enabled: activeIndex == 2,
                            next: f4,
                            setState: setState,
                            prev: f2,
                            onChanged: () {
                              otpText =
                                  [d1.text, d2.text, d3.text, d4.text].join();
                              int idx = ctrls.indexWhere((c) => c.text.isEmpty);
                              if (idx == -1) idx = 3;
                              activeIndex = idx;
                              setState(() {});
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                nodes[activeIndex].requestFocus();
                              });
                            },
                            onTapInactive: () {
                              nodes[activeIndex].requestFocus();
                            },
                          ),
                          const SizedBox(width: 8),
                          _otpBox(
                            d4,
                            f4,
                            enabled: activeIndex == 3,
                            setState: setState,
                            prev: f3,
                            onChanged: () {
                              otpText =
                                  [d1.text, d2.text, d3.text, d4.text].join();
                              int idx = ctrls.indexWhere((c) => c.text.isEmpty);
                              if (idx == -1) idx = 3;
                              activeIndex = idx;
                              setState(() {});
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                nodes[activeIndex].requestFocus();
                              });
                            },
                            onTapInactive: () {
                              nodes[activeIndex].requestFocus();
                            },
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     otpText.isEmpty ? '' : 'الكود: $otpText',
                    //     style: tt.bodySmall?.copyWith(color: cs.onSurface),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () async {
                                final otp =
                                    [d1.text, d2.text, d3.text, d4.text].join();
                                if (otp.length != 4 ||
                                    !RegExp(r'^\d{4}$').hasMatch(otp)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: const Text('أدخل 4 أرقام صحيحة',
                                            textAlign: TextAlign.right),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => submitting = true);
                                final ok = await context
                                    .read<ProfileProvider>()
                                    .verifyOtp(otp);
                                if (!mounted) return;
                                setState(() => submitting = false);
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: const Text('تم تأكيد رقم الهاتف',
                                            textAlign: TextAlign.right),
                                      ),
                                    ),
                                  );
                                  Navigator.of(ctx).pop();
                                } else {
                                  final msg =
                                      context.read<ProfileProvider>().error ??
                                          'فشل التحقق من الكود';
                                  print('VERIFY_OTP_UI_ERROR: $msg');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(msg,
                                            textAlign: TextAlign.right),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: submitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('ارسال'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _otpBox(TextEditingController c, FocusNode f,
      {required bool enabled,
      FocusNode? next,
      FocusNode? prev,
      required void Function(void Function()) setState,
      required VoidCallback onChanged,
      required VoidCallback onTapInactive}) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        controller: c,
        focusNode: f,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        maxLength: 1,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: cs.secondary),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.secondary)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2)),
        ),
        enabled: enabled,
        onTap: enabled ? null : onTapInactive,
        onChanged: (v) {
          if (v.isNotEmpty) {
            if (next != null) {
              next.requestFocus();
            } else {
              FocusScope.of(context).unfocus(); // إغلاق الكيبورد مع آخر رقم فقط
            }
          }
          if (v.isEmpty) {
            prev?.requestFocus();
          }
          onChanged();
        },
      ),
    );
  }
}
