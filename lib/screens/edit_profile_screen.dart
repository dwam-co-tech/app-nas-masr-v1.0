import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:nas_masr_app/widgets/map_action_button.dart';
import 'package:nas_masr_app/widgets/map_round_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/profile_provider.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditProfileScreen({super.key, this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late String agentCode;
  late String username;
  late String phone;
  String password = '';
  String? delegateNumber;
  String? _address;
  double? _lat;
  double? _lng;

  // snapshot of original values to detect changes
  String? _initialAgentCode;
  String? _initialUsername;
  String? _initialPhone;
  String? _initialDelegate;
  String? _initialAddress;
  double? _initialLat;
  double? _initialLng;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? const {};
    agentCode = (d['referral_code'] ?? '').toString();
    username = (d['name'] ?? '').toString();
    phone = (d['phone'] ?? '').toString();
    delegateNumber = d['referral_code']?.toString();
    _address = d['address']?.toString();
    _lat = (d['lat'] is num)
        ? (d['lat'] as num).toDouble()
        : double.tryParse((d['lat'] ?? '').toString());
    _lng = (d['lng'] is num)
        ? (d['lng'] as num).toDouble()
        : double.tryParse((d['lng'] ?? '').toString());

    // في حال لم تُمرَّر بيانات عبر extra، نقرأ الحالة الحالية من ProfileProvider
    if (agentCode.isEmpty && username.isEmpty && phone.isEmpty) {
      try {
        final prof = context.read<ProfileProvider>().profile;
        if (prof != null) {
          agentCode = prof.code ?? '';
          username = prof.name ?? '';
          phone = prof.phone ?? '';
          delegateNumber = prof.referralCode;
          _lat = _lat ?? prof.lat;
          _lng = _lng ?? prof.lng;
          _address = _address ?? prof.address;
        }
      } catch (_) {}

      // set initial snapshot
      _initialAgentCode = agentCode;
      _initialUsername = username;
      _initialPhone = phone;
      _initialDelegate = delegateNumber;
      _initialAddress = _address;
      _initialLat = _lat;
      _initialLng = _lng;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final prof = context.watch<ProfileProvider>().profile;
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
          title: Text('تعديل الملف الشخصي', style: tt.titleLarge),
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
                  // CustomTextField(
                  //   labelText: 'كود المندوب',
                  //   initialValue: agentCode.isEmpty ? '' : agentCode,
                  //   readOnly: true,
                  // ),
                  //  SizedBox(height: 2.h),
                  CustomTextField(
                    labelText: '*اسم المستخدم',
                    initialValue: username,
                    onChanged: (v) => username = v,
                  ),
                  // SizedBox(height: 8.h),
                  CustomTextField(
                    labelText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    initialValue: phone,
                    onChanged: (v) => phone = v,
                    textDirection: TextDirection.rtl,
                  ),
                  // SizedBox(height: 8.h),
                  CustomTextField(
                    labelText: 'كلمة المرور',
                    isPassword: true,
                    hintText: null,
                    onChanged: (v) => password = v,
                  ),
                  //  SizedBox(height: 8.h),
                  CustomTextField(
                    labelText: 'رقم المندوب',
                    isOptional: true,
                    hintText: 'XXXX',
                    initialValue: delegateNumber,
                    onChanged: (v) => delegateNumber = v,
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('*الموقع',
                        style: tt.bodyMedium?.copyWith(
                            fontSize: 14.sp,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500)),
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
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _EditMap(
                    onLocationChanged: (lat, lng, address) {
                      setState(() {
                        _lat = lat;
                        _lng = lng;
                        _address = address;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final valid =
                                _formKey.currentState?.validate() ?? true;
                            if (!valid) return;
                            final payload = <String, dynamic>{};
                            if (username.trim() != (_initialUsername ?? ''))
                              payload['name'] = username.trim();
                            if (phone.trim() != (_initialPhone ?? ''))
                              payload['phone'] = phone.trim();
                            final newRef = (delegateNumber ?? '').trim();
                            if (newRef != (_initialDelegate ?? ''))
                              payload['referral_code'] = newRef;
                            if ((_address ?? '').trim() !=
                                (_initialAddress ?? '').trim())
                              payload['address'] = (_address ?? '').trim();
                            if (_lat != null && _lat != _initialLat)
                              payload['lat'] = _lat;
                            if (_lng != null && _lng != _initialLng)
                              payload['lng'] = _lng;
                            if (password.trim().isNotEmpty)
                              payload['password'] = password.trim();
                            if (payload.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: const Text('لا توجد تغييرات للحفظ',
                                        textAlign: TextAlign.right),
                                  ),
                                ),
                              );
                              return;
                            }
                            final ok = await context
                                .read<ProfileProvider>()
                                .updateProfile(payload);
                            if (!mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: const Text('تم حفظ التغييرات',
                                        textAlign: TextAlign.right),
                                  ),
                                ),
                              );
                              context.pop();
                            } else {
                              final rawErr =
                                  context.read<ProfileProvider>().error;
                              String msg = rawErr ?? 'تعذر حفظ التغييرات';
                              final lower = (rawErr ?? '').toLowerCase();
                              if (lower.contains('referral code not found')) {
                                msg = 'لا يوجد رقم مندوب بهذا الرقم';
                              } else if (lower
                                  .contains('api endpoint not found')) {
                                msg = 'لا يوجد رقم مندوب بهذا الرقم';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child:
                                        Text(msg, textAlign: TextAlign.right),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: const Text('حفظ'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.onSurface,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: const Text('إلغاء'),
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
}

class _EditMap extends StatefulWidget {
  final void Function(double? lat, double? lng, String? address)?
      onLocationChanged;
  const _EditMap({this.onLocationChanged});
  @override
  State<_EditMap> createState() => _EditMapState();
}

class _EditMapState extends State<_EditMap> {
  final MapController _mapController = MapController();
  double? latitude;
  double? longitude;
  String _mapStyle = 'hot';
  String? _address;

  latlng.LatLng _center() {
    final defaultCairo = latlng.LatLng(30.0444, 31.2357);
    if (latitude == null || longitude == null) return defaultCairo;
    return latlng.LatLng(latitude!, longitude!);
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted == PermissionStatus.denied) return;
      }
      if (permissionGranted == PermissionStatus.deniedForever) return;

      final data = await location.getLocation();
      setState(() {
        latitude = data.latitude;
        longitude = data.longitude;
      });
      if (latitude != null && longitude != null) {
        _mapController.move(latlng.LatLng(latitude!, longitude!), 16);
      }
      try {
        if (latitude != null && longitude != null) {
          final placemarks = await geocoding.placemarkFromCoordinates(
              latitude!, longitude!,
              localeIdentifier: 'ar');
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = <String?>[
              p.street,
              p.subLocality,
              p.locality,
              p.administrativeArea,
              p.country
            ]
                .where((s) => s != null && s!.trim().isNotEmpty)
                .cast<String>()
                .toList();
            _address = parts.join('، ');
            widget.onLocationChanged?.call(latitude, longitude, _address);
            setState(() {});
          }
        }
      } catch (_) {}
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
                MarkerLayer(markers: [
                  Marker(
                    point: _center(),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(Icons.location_on,
                        color: ColorManager.secondaryColor, size: 40.sp),
                  )
                ]),
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
                onTap: () => context.push('/map-picker'),
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
                    selectedColor: ColorManager.secondaryColor.withOpacity(.85),
                    labelStyle: const TextStyle(color: Colors.black),
                    disabledColor: const Color.fromARGB(255, 92, 89, 89),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
