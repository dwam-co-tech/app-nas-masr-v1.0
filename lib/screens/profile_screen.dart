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
                  GestureDetector(
                    onTap: _showEditDialog,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        key: ValueKey('phone-$phone'),
                        labelText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        initialValue: _display(phone, 'phone'),
                        readOnly: true,
                        textDirection: TextDirection.rtl,
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
                  SizedBox(height: 8.h),

                  SizedBox(height: 12.h),
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
}
