import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/widgets/map_action_button.dart';
import 'package:nas_masr_app/widgets/map_round_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/profile_provider.dart';
import 'package:go_router/go_router.dart';

class MapPickerScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool persistToProfile;
  const MapPickerScreen(
      {super.key, this.initialData, this.persistToProfile = true});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  double? latitude;
  double? longitude;
  String? _address;
  String _mapStyle = 'standard';
  final TextEditingController _searchCtrl = TextEditingController();
  List<_Suggestion> _suggestions = const [];
  bool _searching = false;
  bool _fromCurrentLocation = false;
  Timer? _debounce;
  String? _locality;
  static const List<int> _pngTransparent = <int>[
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    10,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    0,
    1,
    0,
    0,
    5,
    0,
    1,
    13,
    10,
    45,
    180,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? const {};
    final lat = d['lat']?.toString();
    final lng = d['lng']?.toString();
    latitude = (lat == null || lat.isEmpty) ? null : double.tryParse(lat);
    longitude = (lng == null || lng.isEmpty) ? null : double.tryParse(lng);
    _address = d['address']?.toString();

    if (latitude == null ||
        longitude == null ||
        (_address == null || _address!.isEmpty)) {
      Future.microtask(() => _getCurrentLocation());
    }
  }

  latlng.LatLng _center() {
    final defaultCairo = latlng.LatLng(30.0444, 31.2357);
    if (latitude == null || longitude == null) return defaultCairo;
    return latlng.LatLng(latitude!, longitude!);
  }

  Future<void> _updateAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng,
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
        setState(() {
          _address = parts.join('، ');
          _locality = (p.locality?.trim().isNotEmpty == true)
              ? p.locality
              : (p.administrativeArea?.trim().isNotEmpty == true
                  ? p.administrativeArea
                  : null);
        });
      }
    } catch (_) {}
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
        _fromCurrentLocation = true;
      });
      if (latitude != null && longitude != null) {
        final p = latlng.LatLng(latitude!, longitude!);
        try {
          _mapController.move(p, 16);
        } catch (_) {}
        await _updateAddressFromLatLng(latitude!, longitude!);
      }
    } catch (_) {}
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = const [];
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final regionQuery = _locality == null ? query : '$query ${_locality!}';
      final locs = await geocoding.locationFromAddress(regionQuery,
          localeIdentifier: 'ar');
      final List<_Suggestion> items = [];
      final center = _center();
      final distCalc = latlng.Distance();
      const maxDistanceKm = 50.0;
      for (final l in locs) {
        final here = latlng.LatLng(l.latitude, l.longitude);
        final km = distCalc.as(latlng.LengthUnit.Kilometer, center, here);
        // إذا لا يوجد موقع حالي فعليًا (_fromCurrentLocation=false) لا نطبّق حد المسافة بشدة
        if (_fromCurrentLocation && km > maxDistanceKm) {
          continue;
        }
        try {
          final ps = await geocoding.placemarkFromCoordinates(
              l.latitude, l.longitude,
              localeIdentifier: 'ar');
          String title =
              '${l.latitude.toStringAsFixed(5)}, ${l.longitude.toStringAsFixed(5)}';
          if (ps.isNotEmpty) {
            final p = ps.first;
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
            title = parts.join('، ');
          }
          items.add(_Suggestion(
              title: title, lat: l.latitude, lng: l.longitude, km: km));
        } catch (_) {}
      }
      items.sort((a, b) => a.km.compareTo(b.km));
      setState(() {
        _suggestions = items.take(8).toList();
      });
    } catch (_) {
      setState(() {
        _suggestions = const [];
      });
    } finally {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final size = MediaQuery.of(context).size;
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final double mapH = isLand ? size.height : size.height;
    return Scaffold(
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
        title: Text('اختيار الموقع', style: tt.titleLarge),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            SizedBox(
              height: mapH,
              width: double.infinity,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center(),
                  initialZoom: 14,
                  onMapEvent: (evt) async {
                    final c = _mapController.camera.center;
                    setState(() {
                      latitude = c.latitude;
                      longitude = c.longitude;
                    });
                    if (evt is MapEventMoveEnd ||
                        evt is MapEventRotateEnd ||
                        evt is MapEventFlingAnimationEnd) {
                      await _updateAddressFromLatLng(c.latitude, c.longitude);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: _mapStyle == 'hot'
                        ? 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
                        : _mapStyle == 'standard'
                            ? 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
                            : _mapStyle == 'posi'
                                ? 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'
                                : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    fallbackUrl:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.nas_masr_app',
                    maxZoom: 19,
                    evictErrorTileStrategy: EvictErrorTileStrategy.notVisible,
                    errorImage:
                        MemoryImage(Uint8List.fromList(_pngTransparent)),
                    errorTileCallback: (tile, error, stackTrace) {
                      if (!mounted) return;
                      setState(() {
                        if (_mapStyle == 'posi') {
                          _mapStyle = 'standard';
                        } else if (_mapStyle == 'standard') {
                          _mapStyle = 'hot';
                        }
                      });
                    },
                  ),
                  DragMarkers(
                    markers: [
                      DragMarker(
                        point: _center(),
                        offset: const Offset(0, -8),
                        size: const Size(44, 44),
                        builder: (ctx, pos, isDragging) => Icon(
                          Icons.location_on,
                          color: ColorManager.secondaryColor,
                          size: 44.sp,
                        ),
                        onDragUpdate: (details, p) {
                          setState(() {
                            latitude = p.latitude;
                            longitude = p.longitude;
                          });
                        },
                        onDragEnd: (details, p) async {
                          await _updateAddressFromLatLng(
                              p.latitude, p.longitude);
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
                  SizedBox(width: 6.w),
                  ChoiceChip(
                    label: const Text('واضح+'),
                    selected: _mapStyle == 'posi',
                    onSelected: (_) => setState(() => _mapStyle = 'posi'),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 8,
              start: 8,
              end: 8,
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'ابحث هنا',
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: tt.bodyMedium?.copyWith(
                                fontSize: 12.sp, color: Colors.black54),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          style: tt.bodyMedium?.copyWith(fontSize: 13.sp),
                          onChanged: (v) {
                            _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 200),
                                () => _search(v));
                          },
                          onSubmitted: (v) => _search(v),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _search(_searchCtrl.text),
                        icon: _searching
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.search, size: 18),
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (_suggestions.isNotEmpty)
              PositionedDirectional(
                top: 52.h,
                start: 8,
                end: 8,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final s = _suggestions[i];
                        return ListTile(
                          title: Text(s.title, textAlign: TextAlign.right),
                          onTap: () async {
                            setState(() {
                              latitude = s.lat;
                              longitude = s.lng;
                              _suggestions = const [];
                            });
                            final p = latlng.LatLng(s.lat, s.lng);
                            try {
                              _mapController.move(p, 16);
                            } catch (_) {}
                            await _updateAddressFromLatLng(s.lat, s.lng);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            PositionedDirectional(
              bottom: 50.h,
              start: 0,
              end: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, -2))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _address == null || _address!.isEmpty
                          ? (_fromCurrentLocation &&
                                  latitude != null &&
                                  longitude != null
                              ? 'الموقع الحالي'
                              : 'اختر موقعًا على الخريطة')
                          : _address!,
                      textAlign: TextAlign.right,
                      style: tt.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: cs.onSurface.withOpacity(0.75)),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: MapActionButton(
                            label: 'تم',
                            onTap: () async {
                              if (latitude == null ||
                                  longitude == null ||
                                  (_address ?? '').isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: const Text('من فضلك اختر موقعًا',
                                          textAlign: TextAlign.right),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final payload = <String, dynamic>{
                                'lat': latitude,
                                'lng': longitude,
                                'address': _address,
                              };
                              if (widget.persistToProfile) {
                                final ok = await context
                                    .read<ProfileProvider>()
                                    .updateProfile(payload);
                                if (!mounted) return;
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: const Text('تم حفظ الموقع',
                                            textAlign: TextAlign.right),
                                      ),
                                    ),
                                  );
                                  context.pop();
                                } else {
                                  final err =
                                      context.read<ProfileProvider>().error ??
                                          'فشل الحفظ';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(err,
                                            textAlign: TextAlign.right),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                context.pop(payload);
                              }
                            },
                            color: ColorManager.primaryColor,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // PositionedDirectional(
            //   bottom: 70.h,
            //   start: 8,
            //   child: MapActionButton(
            //     label: 'تحديد موقعي',
            //     onTap: _getCurrentLocation,
            //     color: ColorManager.secondaryColor,
            //     textColor: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _Suggestion {
  final String title;
  final double lat;
  final double lng;
  final double km;
  const _Suggestion(
      {required this.title,
      required this.lat,
      required this.lng,
      required this.km});
}
