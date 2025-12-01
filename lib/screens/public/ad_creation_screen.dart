// screens/ad_creation_screen.dart (الكود النهائي للديناميكية مع المكونات الناقصة)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/models/filter_options.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/core/data/models/governorate.dart';
import 'package:nas_masr_app/core/data/reposetory/filter_repository.dart';
import 'package:nas_masr_app/widgets/create_Ads/car_creation_form.dart';
import 'package:nas_masr_app/widgets/create_Ads/real_estate_creation_form.dart';
import 'package:nas_masr_app/widgets/create_Ads/car_creation_form.dart';
import 'package:nas_masr_app/widgets/create_Ads/real_estate_creation_form.dart';
import 'package:nas_masr_app/widgets/create_Ads/unified_creation_form.dart';
import 'package:nas_masr_app/widgets/create_Ads/car_rental_creation_form.dart';
import 'package:nas_masr_app/widgets/create_Ads/car_spare_parts_creation_form.dart';
import 'package:nas_masr_app/core/constatants/unified_categories.dart';
import 'package:nas_masr_app/widgets/create_Ads/custom_dropdown_field.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
import 'package:nas_masr_app/widgets/custome_phone_filed.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:nas_masr_app/widgets/map_round_icon_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/providers/profile_provider.dart';
import 'package:nas_masr_app/screens/map_picker_screen.dart';
import 'package:nas_masr_app/core/data/models/create_listing_payload.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_creation_repository.dart';
import 'package:nas_masr_app/core/data/providers/ad_creation_provider.dart';
import 'package:flutter/services.dart';
// Note: يرجى التحقق من وجود FilterOptions و FilterRepository
// (تم استبدالهما بـ Models النهائية لتجنب أخطاء البناء)
// import '../core/data/models/filter_options.dart';
// import '../core/data/reposetory/filter_repository.dart';

// نحتاج لتثبيت الكلاسات المساعدة لعمل الـ Dynamic Form

// دالة لـ Text Area (الوصف) - تُدمج الـ CustomTextField بطريقة الـ Description
class CustomDescriptionField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Function(String)? onChanged;
  final TextStyle? labelStyle;
  final String? initialValue;

  const CustomDescriptionField(
      {super.key,
      required this.label,
      this.isRequired = false,
      this.onChanged,
      this.labelStyle,
      this.initialValue});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: label,
      isOptional: !isRequired,
      showTopLabel: true,
      labelStyle: labelStyle,
      initialValue: initialValue,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: 200,
      filled: true,
      onChanged: onChanged,
      // fillColor: const Color.fromRGBO(255, 255, 255, 1), // يفضل استمداد الـ Fill Color من الثيم
    );
  }
}

// Widgets افتراضية (لابد من إنشائها)
class ImageUploadSection extends StatefulWidget {
  final String slug;
  final String? initialMainImageUrl;
  final List<String> initialImageUrls;
  const ImageUploadSection({
    super.key,
    required this.slug,
    this.initialMainImageUrl,
    this.initialImageUrls = const [],
  });
  @override
  State<ImageUploadSection> createState() => _ImageUploadSectionState();
}

class _ImageUploadSectionState extends State<ImageUploadSection> {
  final ImagePicker _picker = ImagePicker();
  XFile? _mainImage;
  List<XFile> _thumbImages = [];
  String? _remoteMainUrl;
  List<String> _remoteThumbUrls = [];
  int _maxThumbsForSlug(String slug) {
    switch (slug) {
      case 'real_estate':
      case '3aqarat':
        return 9;
      case 'cars':
        return 14;
      case 'cars_rent':
        return 9;
      default:
        return 9;
    }
  }

  @override
  void initState() {
    super.initState();
    _remoteMainUrl = widget.initialMainImageUrl;
    _remoteThumbUrls = List<String>.from(widget.initialImageUrls);
  }

  Widget _uploadTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 4.0,
      shadowColor: Color.fromRGBO(0, 0, 0, 0.25).withOpacity(.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(1, 22, 24, 0.54),
                ),
              ),
              SizedBox(width: 10.w),
              ShaderMask(
                shaderCallback: (Rect bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF14876F), Color(0xFF03464A)],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Icon(icon, size: 22.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMainImage() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _mainImage = file);
    }
  }

  Future<void> _pickThumbImages(int maxThumbs) async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) {
      final int remaining = maxThumbs - _thumbImages.length;
      final List<XFile> toAdd = files.take(remaining).toList();
      if (toAdd.isEmpty) return;
      setState(() => _thumbImages = [..._thumbImages, ...toAdd]);
    }
  }

  String? get remoteMainUrl => _remoteMainUrl;
  List<String> get remoteThumbUrls =>
      List<String>.unmodifiable(_remoteThumbUrls);
  XFile? get mainImage => _mainImage;
  List<XFile> get thumbImages => List<XFile>.unmodifiable(_thumbImages);

  @override
  Widget build(BuildContext context) {
    final int maxThumbs = _maxThumbsForSlug(widget.slug);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _uploadTile(
          icon: Icons.image_rounded,
          label: 'إضافة الصورة الرئيسية',
          onTap: _pickMainImage,
        ),
        if (_mainImage != null) ...[
          SizedBox(height: 8.h),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  File(_mainImage!.path),
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: IconButton(
                      iconSize: 16.sp,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.black87),
                      onPressed: () => setState(() => _mainImage = null),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else if (_remoteMainUrl != null && _remoteMainUrl!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  _remoteMainUrl!,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 160.h,
                    width: double.infinity,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: IconButton(
                      iconSize: 16.sp,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.black87),
                      onPressed: () => setState(() => _remoteMainUrl = null),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 10.h),
        _uploadTile(
          icon: Icons.grid_view_rounded,
          label:
              'إضافة الصور الأخرى (${_remoteThumbUrls.length + _thumbImages.length}/$maxThumbs) اختياري',
          onTap: () => _pickThumbImages(maxThumbs),
        ),
        if (_remoteThumbUrls.isNotEmpty || _thumbImages.isNotEmpty) ...[
          SizedBox(height: 8.h),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _remoteThumbUrls.length + _thumbImages.length,
            itemBuilder: (context, index) {
              final isRemote = index < _remoteThumbUrls.length;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: isRemote
                        ? Image.network(
                            _remoteThumbUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.broken_image),
                          )
                        : Image.file(
                            File(_thumbImages[index - _remoteThumbUrls.length]
                                .path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: IconButton(
                          iconSize: 14.sp,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.black87),
                          onPressed: () => setState(() {
                            if (isRemote) {
                              _remoteThumbUrls.removeAt(index);
                            } else {
                              _thumbImages
                                  .removeAt(index - _remoteThumbUrls.length);
                            }
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class MapSelectionWidget extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;
  const MapSelectionWidget(
      {super.key, this.initialLat, this.initialLng, this.initialAddress});
  @override
  State<MapSelectionWidget> createState() => _MapSelectionWidgetState();
}

class _MapSelectionWidgetState extends State<MapSelectionWidget> {
  final MapController _mapController = MapController();
  double? latitude;
  double? longitude;
  String? _address;
  Map<String, dynamic>? _payload;
  String _mapStyle = 'standard';

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      latitude = widget.initialLat;
      longitude = widget.initialLng;
      _address = widget.initialAddress;
      _payload = {
        'lat': latitude,
        'lng': longitude,
        'address': _address,
      };
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
          _payload = {
            'lat': lat,
            'lng': lng,
            'address': _address,
          };
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

  Future<void> _useProfileLocation() async {
    try {
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null) {
        await provider.loadProfile();
      }
      final prof = provider.profile;
      if (prof != null) {
        setState(() {
          _address = prof.address ?? _address;
          latitude = prof.lat ?? latitude;
          longitude = prof.lng ?? longitude;
          if (latitude != null && longitude != null) {
            _payload = {
              'lat': latitude,
              'lng': longitude,
              'address': _address,
            };
          }
        });
        if (latitude != null && longitude != null) {
          final p = latlng.LatLng(latitude!, longitude!);
          try {
            _mapController.move(p, 16);
          } catch (_) {}
          if (_address == null || _address!.isEmpty) {
            await _updateAddressFromLatLng(latitude!, longitude!);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: const Text('لا يوجد موقع محفوظ بالملف الشخصي',
                  textAlign: TextAlign.right),
            ),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final size = MediaQuery.of(context).size;
    final double mapH =
        isLand ? (size.height * 0.35).clamp(160.0, 260.0) : 220.h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('إضافة الموقع: ',
                style: tt.bodyMedium
                    ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w500)),
            Expanded(
              child: Text(
                (_address == null || _address!.isEmpty)
                    ? 'لم يتم التحديد بعد'
                    : _address!,
                textAlign: TextAlign.right,
                style: tt.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(1, 22, 24, 0.45)),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
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
                          : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.nas_masr_app',
                      maxZoom: 19,
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
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _useProfileLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primaryColor,
                  foregroundColor: Colors.white,
                  fixedSize: Size.fromHeight(46.h),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'الموقع من الملف الشخصي',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primaryColor,
                  foregroundColor: Colors.white,
                  fixedSize: Size.fromHeight(46.h),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'إضافة الموقع الحالي',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final init = {
                    'lat': latitude,
                    'lng': longitude,
                    'address': _address,
                  };
                  final result = await context.push<Map<String, dynamic>>(
                    '/map-picker',
                    extra: init,
                  );
                  if (result != null) {
                    setState(() {
                      _address = result['address']?.toString();
                      latitude = (result['lat'] is double)
                          ? result['lat'] as double?
                          : (result['lat'] == null
                              ? null
                              : double.tryParse(result['lat'].toString()));
                      longitude = (result['lng'] is double)
                          ? result['lng'] as double?
                          : (result['lng'] == null
                              ? null
                              : double.tryParse(result['lng'].toString()));
                      _payload = {
                        'lat': latitude,
                        'lng': longitude,
                        'address': _address,
                      };
                    });
                    if (latitude != null && longitude != null) {
                      try {
                        _mapController.move(
                            latlng.LatLng(latitude!, longitude!), 16);
                      } catch (_) {}
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primaryColor,
                  foregroundColor: Colors.white,
                  fixedSize: Size.fromHeight(46.h),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'إضافة موقع جديد',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic>? get payload => _payload;
}

class PackageSelectionWidget extends StatefulWidget {
  final ValueChanged<String?>? onChanged;
  final String? initialValue;
  const PackageSelectionWidget({super.key, this.onChanged, this.initialValue});
  @override
  State<PackageSelectionWidget> createState() => _PackageSelectionWidgetState();
}

class _PackageSelectionWidgetState extends State<PackageSelectionWidget> {
  String? _selectedId = 'premium';

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialValue ?? _selectedId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged?.call(_selectedId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = const [
      _PackageItem(
          id: 'featured',
          title: 'إعلان متميز يظهر في مجموعة أعلي قائمة الاعلانات',
          price: 100,
          validityDays: 365),
      _PackageItem(
          id: 'standard',
          title: 'إعلان ستاندرد يظهر في مجموعة بعد الاعلانات المميزة',
          price: 80,
          validityDays: 365),
      _PackageItem(
          id: 'free',
          title: 'إعلان مجاني يظهر في نهاية قائمة الاعلانات',
          price: 0,
          validityDays: 365),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('اختيار نوع الاعلان',
              style: tt.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          SizedBox(height: 8.h),
          Column(
            children: items.map((item) {
              final selected = _selectedId == item.id;
              return InkWell(
                onTap: () {
                  setState(() => _selectedId = item.id);
                  widget.onChanged?.call(_selectedId);
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _CircleCheck(
                                    selected: selected, color: cs.secondary),
                                SizedBox(width: 6.w),
                                Text(item.title,
                                    textAlign: TextAlign.right,
                                    style: tt.bodyMedium?.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: ColorManager.primaryColor)),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                                'القيمة بالجنيه (${item.price})  الصلاحية باليوم ${item.validityDays}',
                                textAlign: TextAlign.right,
                                style: tt.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
          Text('صلاحية جميع اعلانات الباقات تنتهي بانتهاء صلاحية الباقة',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: cs.secondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String? get selectedPackageId => _selectedId;
}

class _PackageItem {
  final String id;
  final String title;
  final int price;
  final int validityDays;
  const _PackageItem(
      {required this.id,
      required this.title,
      required this.price,
      required this.validityDays});
}

class _CircleCheck extends StatelessWidget {
  final bool selected;
  final Color color;
  const _CircleCheck({required this.selected, required this.color});
  @override
  Widget build(BuildContext context) {
    final s = 24.w;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: selected ? color : Colors.transparent,
      ),
      child:
          selected ? Icon(Icons.check, color: Colors.white, size: 16.sp) : null,
    );
  }
}

class LocationFieldsSection extends StatefulWidget {
  final List<Governorate> governorates;
  final String? initialGovernorate;
  final String? initialCity;
  const LocationFieldsSection(
      {super.key,
      this.governorates = const [],
      this.initialGovernorate,
      this.initialCity});
  @override
  State<LocationFieldsSection> createState() => _LocationFieldsSectionState();
}

class _LocationFieldsSectionState extends State<LocationFieldsSection> {
  String? _selectedGov;
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    _selectedGov = _selectedGov ?? widget.initialGovernorate;
    _selectedCity = _selectedCity ?? widget.initialCity;
    final List<String> governorates =
        widget.governorates.map((g) => g.name).toList();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final labelStyle = tt.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: cs.primary,
    );
    final List<String> cities = () {
      if (_selectedGov == null) return const <String>[];
      try {
        final name = _selectedGov!.trim().toLowerCase();
        final gov = widget.governorates.firstWhere(
          (g) => (g.name.trim().toLowerCase()) == name,
        );
        return gov.cities.map((c) => c.name).toList();
      } catch (_) {
        return const <String>[];
      }
    }();

    final govField = CustomDropdownField(
      label: 'المحافظة',
      options: governorates,
      initialValue: _selectedGov,
      isRequired: true,
      labelStyle: labelStyle,
      onChanged: (val) {
        setState(() {
          _selectedGov = val?.trim();
          _selectedCity = null;
        });
      },
    );

    final cityField = CustomDropdownField(
      key: ValueKey('city-${_selectedGov ?? 'none'}'),
      label: 'المدينة',
      options: cities,
      initialValue: _selectedCity,
      isRequired: true,
      labelStyle: labelStyle,
      emptyOptionsHint: _selectedGov == null
          ? 'اختر المحافظة أولاً'
          : 'لا توجد مدن لهذه المحافظة',
      onChanged: (val) {
        setState(() {
          _selectedCity = val;
        });
      },
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: govField),
          SizedBox(width: 8.w),
          Expanded(child: cityField),
        ],
      ),
    );
  }

  String? get selectedGov => _selectedGov;
  String? get selectedCity => _selectedCity;
}

// Provider (مؤقت لفك الـ Build Error):

class AdCreationScreen extends StatefulWidget {
  final String categorySlug;
  final String categoryName;

  const AdCreationScreen(
      {super.key, required this.categorySlug, required this.categoryName});

  @override
  State<AdCreationScreen> createState() => _AdCreationScreenState();
}

class _AdCreationScreenState extends State<AdCreationScreen> {
  final _imagesKey = GlobalKey<_ImageUploadSectionState>();
  final _locationKey = GlobalKey<_LocationFieldsSectionState>();
  final _mapKey = GlobalKey<_MapSelectionWidgetState>();
  final _carFormKey = GlobalKey<CarCreationFormState>();
  final _carRentalFormKey = GlobalKey<CarRentalCreationFormState>();
  final _carSparePartsFormKey = GlobalKey<CarSparePartsCreationFormState>();

  bool _submitting = false;
  CategoryFieldsResponse? _config;
  bool _loading = true;
  String? _error;

  String? _propertyType;
  String? _contractType;

  String? _mainCategory;
  String? _subCategory;
  String? _selectedPlanType;
  String? _price;
  String? _description;
  String? _autoTitle;
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  String? _contactPhone;
  String? _whatsappPhone;
  bool _usernameChecked = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Future.microtask(_loadConfig);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUsernameOnOpen());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _checkUsernameOnOpen() async {
    if (_usernameChecked) return;
    try {
      final profProv = context.read<ProfileProvider>();
      if (profProv.profile == null ||
          (profProv.profile?.name?.trim().isEmpty ?? true)) {
        await profProv.loadProfile();
      }
      final currentName = profProv.profile?.name?.trim() ?? '';
      if (currentName.isEmpty) {
        await _promptForUsername();
      }
    } catch (_) {}
    _usernameChecked = true;
  }

  Future<void> _loadConfig() async {
    try {
      final repo = CategoryRepository(api: ApiService());
      final cfg = await repo.getCategoryFields(widget.categorySlug);
      if (!mounted) return;
      setState(() {
        _config = cfg;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'فشل تحميل بيانات القسم';
      });
    }
  }

  // هذه الدالة السحرية ستقوم ببناء جميع الـ Form Fields بشكل آلي
  // Note: قمنا هنا بـ FIX أخطاء الـ Return Values (يجب أن يتم تمرير قيم للحقول)
  Widget _buildDynamicForm(BuildContext context, String slug,
      List<CategoryFieldConfig> fields, TextStyle? labelStyle) {
    if (UnifiedCategories.slugs.contains(slug)) {
      return UnifiedCreationForm(
        fieldsConfig: fields,
        labelStyle: labelStyle,
        onMainCategoryChanged: (v) => _mainCategory = v,
        onSubCategoryChanged: (v) => _subCategory = v,
      );
    }
    switch (slug) {
      case 'cars':
        return CarCreationForm(
          key: _carFormKey,
          fieldsConfig: fields,
          makes: _config?.makes ?? const [],
          labelStyle: labelStyle,
        );

      case 'cars_rent':
        return CarRentalCreationForm(
          key: _carRentalFormKey,
          fieldsConfig: fields,
          makes: _config?.makes ?? const [],
          labelStyle: labelStyle,
          onTitleChanged: (val) => setState(() => _autoTitle = val),
        );

      case 'spare-parts':
        return CarSparePartsCreationForm(
          key: _carSparePartsFormKey,
          fieldsConfig: fields,
          makes: _config?.makes ?? const [],
          labelStyle: labelStyle,
          onTitleChanged: (val) => setState(() => _autoTitle = val),
        );

      case 'real_estate':
        return RealEstateCreationForm(
          fieldsConfig: fields,
          labelStyle: labelStyle,
          onPropertyTypeChanged: (v) => _propertyType = v,
          onContractTypeChanged: (v) => _contractType = v,
        );

      default:
        return const Center(child: Text('تحت الانشاء'));
    }
  }

  Future<void> _submitWithProvider(AdCreationProvider provider) async {
    final profProv = context.read<ProfileProvider>();
    final currentName = profProv.profile?.name?.trim() ?? '';
    if (currentName.isEmpty) {
      final ok = await _promptForUsername();
      if (!ok) return;
    }
    if (_submitting) return;
    final mainX = _imagesKey.currentState?.mainImage;
    final thumbsX = _imagesKey.currentState?.thumbImages ?? const <XFile>[];
    final loc = _mapKey.currentState?.payload;
    final gov = _locationKey.currentState?.selectedGov;
    final city = _locationKey.currentState?.selectedCity;
    final errors = <String>[];
    if (gov == null || gov!.isEmpty) errors.add('اختر المحافظة');
    if (city == null || city!.isEmpty) errors.add('اختر المدينة');
    if (_price == null || _price!.trim().isEmpty) errors.add('ادخل السعر');
    if (_description == null || _description!.trim().isEmpty)
      errors.add('ادخل الوصف');
    if (_selectedPlanType == null || _selectedPlanType!.isEmpty)
      errors.add('اختر نوع الإعلان');
    if (_contactPhone == null || _contactPhone!.trim().isEmpty)
      errors.add('ادخل رقم الهاتف');
    if (_whatsappPhone == null || _whatsappPhone!.trim().isEmpty)
      errors.add('ادخل رقم الواتساب');
    if (mainX == null) errors.add('اختر الصورة الرئيسية');
    if (loc == null ||
        loc['lat'] == null ||
        loc['lng'] == null ||
        (loc['address']?.toString().trim().isEmpty ?? true)) {
      errors.add('حدّد الموقع (خط العرض/الطول والعنوان)');
    }
    if (widget.categorySlug == 'real_estate' ||
        widget.categorySlug == '3aqarat') {
      if (_propertyType == null || _propertyType!.isEmpty)
        errors.add('اختر نوع العقار');
      if (_contractType == null || _contractType!.isEmpty)
        errors.add('اختر نوع العقد');
    }
    if (UnifiedCategories.slugs.contains(widget.categorySlug)) {
      if (_mainCategory == null || _mainCategory!.isEmpty)
        errors.add('اختر القسم الرئيسي');
      if (_subCategory == null || _subCategory!.isEmpty)
        errors.add('اختر القسم الفرعي');
    }
    // تحقق من الحقول الديناميكية للقسم الحالي
    // تحقق من الحقول الديناميكية للقسم الحالي
    if (widget.categorySlug == 'cars') {
      final carAttrs = _carFormKey.currentState?.getSelectedAttributes() ??
          const <String, String?>{};
      final fields = _config?.categoryFields ?? const <CategoryFieldConfig>[];
      for (final f in fields) {
        if (!f.isRequired) continue;
        final name = f.fieldName;
        bool present = false;
        if (name == 'year')
          present = (carAttrs['year'] ?? '').toString().trim().isNotEmpty;
        else if (name == 'fuel_type')
          present = (carAttrs['fuel_type'] ?? '').toString().trim().isNotEmpty;
        else if (name == 'transmission')
          present =
              (carAttrs['transmission'] ?? '').toString().trim().isNotEmpty;
        else if (name == 'exterior_color' || name == 'color')
          present =
              (carAttrs[name == 'color' ? 'color' : 'exterior_color'] ?? '')
                  .toString()
                  .trim()
                  .isNotEmpty;
        else if (name == 'body_type' || name == 'type' || name == 'car_type') {
          final key = carAttrs['body_type'] != null
              ? 'body_type'
              : (carAttrs['type'] != null
                  ? 'type'
                  : (carAttrs['car_type'] != null ? 'car_type' : ''));
          present = key.isNotEmpty &&
              (carAttrs[key] ?? '').toString().trim().isNotEmpty;
        } else if (name == 'mileage_range' ||
            name == 'kilometer' ||
            name == 'kilometers' ||
            name == 'mileage') {
          final k = ['mileage_range', 'kilometer', 'kilometers', 'mileage']
              .firstWhere((x) => carAttrs[x] != null, orElse: () => '');
          present =
              k.isNotEmpty && (carAttrs[k] ?? '').toString().trim().isNotEmpty;
        }
        if (!present) {
          errors.add('حقل ${f.displayName} مطلوب.');
        }
      }
      // تأكيد وجود ماركة وموديل
      if ((_carFormKey.currentState?.selectedMake ?? '')
          .toString()
          .trim()
          .isEmpty) {
        errors.add('اختر الماركة');
      }
      if ((_carFormKey.currentState?.selectedModel ?? '')
          .toString()
          .trim()
          .isEmpty) {
        errors.add('اختر الموديل');
      }
    } else if (widget.categorySlug == 'cars_rent') {
      final rentalAttrs =
          _carRentalFormKey.currentState?.getSelectedAttributes() ??
              const <String, String?>{};

      if ((_carRentalFormKey.currentState?.selectedMake ?? '').trim().isEmpty) {
        errors.add('اختر الماركة');
      }
      if ((_carRentalFormKey.currentState?.selectedModel ?? '')
          .trim()
          .isEmpty) {
        errors.add('اختر الموديل');
      }
      if ((rentalAttrs['year'] ?? '').trim().isEmpty) {
        errors.add('اختر السنة');
      }
      if ((rentalAttrs['driver_option'] ?? '').trim().isEmpty) {
        errors.add('اختر حالة السائق');
      }
    } else if (widget.categorySlug == 'spare-parts') {
      final spareAttrs =
          _carSparePartsFormKey.currentState?.getSelectedAttributes() ??
              const <String, String?>{};

      if ((_carSparePartsFormKey.currentState?.selectedMake ?? '')
          .trim()
          .isEmpty) {
        errors.add('اختر الماركة');
      }
      if ((_carSparePartsFormKey.currentState?.selectedModel ?? '')
          .trim()
          .isEmpty) {
        errors.add('اختر الموديل');
      }
      if ((spareAttrs['main_category'] ?? '').trim().isEmpty) {
        errors.add('اختر القسم الرئيسي');
      }
      if ((spareAttrs['sub_category'] ?? '').trim().isEmpty) {
        errors.add('اختر القسم الفرعي');
      }
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(errors.join('\n')))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final mainFile = File(mainX!.path);
      final thumbFiles = thumbsX.map((e) => File(e.path)).toList();
      final double? latVal = () {
        final v = loc != null ? loc['lat'] : null;
        if (v == null) return null;
        if (v is double) return v;
        return double.tryParse(v.toString());
      }();
      final double? lngVal = () {
        final v = loc != null ? loc['lng'] : null;
        if (v == null) return null;
        if (v is double) return v;
        return double.tryParse(v.toString());
      }();
      final carAttrs = widget.categorySlug == 'cars'
          ? (_carFormKey.currentState?.getSelectedAttributes() ??
              const <String, String?>{})
          : const <String, String?>{};
      final rentalAttrs = widget.categorySlug == 'cars_rent'
          ? (_carRentalFormKey.currentState?.getSelectedAttributes() ??
              const <String, String?>{})
          : const <String, String?>{};
      final spareAttrs = widget.categorySlug == 'spare-parts'
          ? (_carSparePartsFormKey.currentState?.getSelectedAttributes() ??
              const <String, String?>{})
          : const <String, String?>{};

      final payload = CreateListingPayload(
        price: _price,
        governorate: gov,
        city: city,
        description: _description,
        planType: _selectedPlanType ?? 'free',
        lat: latVal,
        lng: lngVal,
        address: loc != null ? (loc['address']?.toString()) : null,
        contactPhone: _contactPhone,
        whatsappPhone: _whatsappPhone,
        make: widget.categorySlug == 'cars_rent'
            ? _carRentalFormKey.currentState?.selectedMake
            : (widget.categorySlug == 'spare-parts'
                ? _carSparePartsFormKey.currentState?.selectedMake
                : _carFormKey.currentState?.selectedMake),
        model: widget.categorySlug == 'cars_rent'
            ? _carRentalFormKey.currentState?.selectedModel
            : (widget.categorySlug == 'spare-parts'
                ? _carSparePartsFormKey.currentState?.selectedModel
                : _carFormKey.currentState?.selectedModel),
        attributes: {
          if (_propertyType != null) 'property_type': _propertyType,
          if (_contractType != null) 'contract_type': _contractType,
          if (_mainCategory != null) 'main_category': _mainCategory,
          if (_subCategory != null) 'sub_category': _subCategory,
          ...carAttrs.map((k, v) => MapEntry(k, v)),
          ...rentalAttrs.map((k, v) => MapEntry(k, v)),
          ...spareAttrs.map((k, v) => MapEntry(k, v)),
        },
      );
      final ok = await provider.submitListing(
        categorySlug: widget.categorySlug,
        payload: payload,
        mainImage: mainFile,
        images: thumbFiles,
      );
      if (!ok) {
        final msg = provider.error ?? 'فشل الإرسال';
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        return;
      }
      if (!mounted) return;
      final createdId = provider.lastCreatedId;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                createdId != null ? 'تم إنشاء الإعلان ' : 'تم إنشاء الإعلان')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الإرسال: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<bool> _promptForUsername() async {
    String input = '';
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cs.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            titlePadding: const EdgeInsetsDirectional.only(
                start: 16, end: 16, top: 12, bottom: 4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: const Text('يجب إدخال اسم المستخدم',
                textAlign: TextAlign.right),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: CustomTextField(
                    labelText: '*اسم المستخدم',
                    showTopLabel: true,
                    onChanged: (v) => input = v,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.onSurface,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = input.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: const Text('أدخل اسمًا صالحًا',
                                      textAlign: TextAlign.right),
                                ),
                              ),
                            );
                            return;
                          }
                          final ok = await context
                              .read<ProfileProvider>()
                              .updateProfile({'name': name});
                          if (!mounted) return;
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: const Text('تم حفظ الاسم',
                                      textAlign: TextAlign.right),
                                ),
                              ),
                            );
                            Navigator.of(ctx).pop(true);
                          } else {
                            final msg = context.read<ProfileProvider>().error ??
                                'تعذر حفظ الاسم';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(msg, textAlign: TextAlign.right),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('حفظ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final labelStyle = tt.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: cs.primary,
    );
    // سنلغي الـ Provider هنا للتسهيل ولعدم توفر الـ Repo الخاص به
    final List<CategoryFieldConfig> fieldsFromApi =
        _config?.categoryFields ?? const <CategoryFieldConfig>[];

    return ChangeNotifierProvider(
        create: (_) => AdCreationProvider(repository: AdCreationRepository()),
        child: Directionality(
            textDirection: TextDirection.rtl,
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
                  title: Text('اضافة إعلان \n${widget.categoryName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurface))),
              body: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. الجزء العلوي (المحافظة والمدينة - ثابتة)
                            LocationFieldsSection(
                              key: _locationKey,
                              governorates: _config?.governorates ?? const [],
                            ),

                            // 2. >>> قلب الصفحة الديناميكي: هنا كل الحقول تُرسم آلياً! <<<
                            _buildDynamicForm(
                              context,
                              widget.categorySlug,
                              fieldsFromApi,
                              labelStyle,
                            ),

                            if (_autoTitle != null &&
                                _autoTitle!.isNotEmpty) ...[
                              SizedBox(height: 5.h),
                              CustomTextField(
                                labelText: 'عنوان الإعلان',
                                initialValue: _autoTitle,
                                readOnly: true,
                                showTopLabel: true,
                                labelStyle: labelStyle,
                              ),
                            ],

                            // 3. الأجزاء الثابتة التي يجب أن تظهر تحت الـ Dynamic Fields
                            //  SizedBox(height: 5.h),

                            CustomTextField(
                              labelText: 'السعر',
                              keyboardType: TextInputType.number,
                              showTopLabel: true,
                              labelStyle: labelStyle,
                              onChanged: (v) => _price = v,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'رقم الهاتف',
                                  textAlign: TextAlign.right,
                                  style: labelStyle,
                                ),
                                SizedBox(height: 3.h),
                                CustomPhoneField(
                                  controller: _contactController,
                                  onPhoneNumberChanged: (v) =>
                                      _contactPhone = v,
                                ),
                              ],
                            ),
                            SizedBox(height: 7.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'رقم الواتساب',
                                  textAlign: TextAlign.right,
                                  style: labelStyle,
                                ),
                                SizedBox(height: 3.h),
                                CustomPhoneField(
                                  controller: _whatsappController,
                                  onPhoneNumberChanged: (v) =>
                                      _whatsappPhone = v,
                                ),
                              ],
                            ),

                            SizedBox(height: 5.h),
                            CustomDescriptionField(
                              label: 'الوصف',
                              isRequired: true,
                              labelStyle: labelStyle,
                              onChanged: (v) => _description = v,
                            ),

                            SizedBox(height: 12.h),

                            ImageUploadSection(
                                key: _imagesKey, slug: widget.categorySlug),
                            SizedBox(height: 20.h),

                            MapSelectionWidget(key: _mapKey),
                            SizedBox(height: 20.h),

                            PackageSelectionWidget(
                                onChanged: (v) =>
                                    _selectedPlanType = v ?? 'free'),
                            SizedBox(height: 5.h),

                            // زر الحفظ والإرسال (ثابت)
                            Consumer<AdCreationProvider>(
                              builder: (ctx, provider, _) => ElevatedButton(
                                onPressed: _submitting
                                    ? null
                                    : () => _submitWithProvider(provider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.primaryColor,
                                  foregroundColor: Colors.white,
                                  fixedSize: Size.fromHeight(46.h),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : Text('حفظ',
                                        style: TextStyle(fontSize: 14.sp)),
                              ),
                            ),
                            SizedBox(height: 60.h),
                          ],
                        ),
                      ),
                    ),
            )));
  }
}
