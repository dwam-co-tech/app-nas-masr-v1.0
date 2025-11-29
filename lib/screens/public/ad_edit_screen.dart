import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/ad_creation_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_creation_repository.dart';
import 'package:nas_masr_app/core/data/models/create_listing_payload.dart';
import 'package:nas_masr_app/core/data/reposetory/ad_details_repository.dart';
import 'package:nas_masr_app/core/data/models/ad_details_model.dart';
import 'package:nas_masr_app/core/data/reposetory/filter_repository.dart';
import 'package:nas_masr_app/core/data/models/All_filter_response.dart';
import 'package:nas_masr_app/screens/public/ad_creation_screen.dart';
import 'package:nas_masr_app/widgets/create_Ads/real_estate_creation_form.dart';
import 'package:nas_masr_app/widgets/custome_phone_filed.dart';
import 'package:nas_masr_app/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';

class EditAdScreen extends StatefulWidget {
  final String categorySlug;
  final String adId;
  final String? categoryName;
  const EditAdScreen(
      {super.key,
      required this.categorySlug,
      required this.adId,
      this.categoryName});

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final _imagesKey = GlobalKey();
  final _locationKey = GlobalKey();
  final _mapKey = GlobalKey();
  bool _loading = true;
  String? _error;
  AdDetailsModel? _details;
  CategoryFieldsResponse? _config;
  String? _price;
  String? _description;
  String? _contactPhone;
  String? _whatsappPhone;
  String? _propertyType;
  String? _contractType;
  late final TextEditingController _priceController = TextEditingController();
  late final TextEditingController _descController = TextEditingController();
  late final TextEditingController _contactController = TextEditingController();
  late final TextEditingController _whatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _priceController.dispose();
    _descController.dispose();
    _contactController.dispose();
    _whatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unifiedLabelStyle = tt.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: cs.primary,
    );
    final titleText =
        (widget.categoryName == null || widget.categoryName!.isEmpty)
            ? 'تعديل الإعلان'
            : 'تعديل اعلان  ${widget.categoryName}';
    return Directionality(
        textDirection: TextDirection.rtl,
        child: ChangeNotifierProvider(
          create: (_) => AdCreationProvider(repository: AdCreationRepository()),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                titleText,
                style: tt.titleLarge
                    ?.copyWith(fontSize: 18.sp, color: cs.onSurface),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading) ...[
                      SizedBox(height: 8.h),
                      Text('جاري تحميل بيانات الإعلان...',
                          textAlign: TextAlign.right,
                          style: tt.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: cs.onSurface.withOpacity(0.8))),
                      SizedBox(height: 12.h),
                      const Center(child: CircularProgressIndicator()),
                    ] else if (_error != null) ...[
                      SizedBox(height: 8.h),
                      Text('خطأ: ${_error!}',
                          textAlign: TextAlign.right,
                          style: tt.bodyMedium
                              ?.copyWith(fontSize: 14.sp, color: Colors.red)),
                    ] else ...[
                      Opacity(
                        opacity: 0.6,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: LocationFieldsSection(
                            key: _locationKey,
                            governorates: _config?.governorates ?? const [],
                            initialGovernorate: _details?.governorate,
                            initialCity: _details?.city,
                          ),
                        ),
                      ),
                      //SizedBox(height: 5.h),
                      Opacity(
                        opacity: 0.6,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: RealEstateCreationForm(
                            fieldsConfig: _config?.categoryFields ?? const [],
                            labelStyle: unifiedLabelStyle,
                            initialPropertyType: _propertyType,
                            initialContractType: _contractType,
                            onPropertyTypeChanged: (v) => _propertyType = v,
                            onContractTypeChanged: (v) => _contractType = v,
                          ),
                        ),
                      ),
                      //  SizedBox(height: 5.h),
                      CustomTextField(
                        labelText: 'السعر',
                        keyboardType: TextInputType.number,
                        initialValue: _priceController.text,
                        onChanged: (v) => _price = v.trim(),
                        labelStyle: unifiedLabelStyle,
                        showTopLabel: true,
                        filled: true,
                      ),
                      SizedBox(height: 8.h),
                      CustomPhoneField(
                        controller: _contactController,
                        onPhoneNumberChanged: (v) => _contactPhone = v,
                        textDirection: TextDirection.rtl,
                        label: 'هاتف التواصل',
                        labelStyle: unifiedLabelStyle,
                        showTopLabel: true,
                      ),
                      SizedBox(height: 8.h),
                      CustomPhoneField(
                        controller: _whatsController,
                        onPhoneNumberChanged: (v) => _whatsappPhone = v,
                        textDirection: TextDirection.rtl,
                        label: 'واتساب',
                        labelStyle: unifiedLabelStyle,
                        showTopLabel: true,
                      ),
                      SizedBox(height: 10.h),
                      Opacity(
                        opacity: 0.6,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: CustomDescriptionField(
                            label: 'الوصف',
                            isRequired: true,
                            initialValue: _description ?? '',
                            onChanged: (v) => _description = v,
                            labelStyle: unifiedLabelStyle,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Opacity(
                        opacity: 0.6,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: ImageUploadSection(
                            key: _imagesKey,
                            slug: widget.categorySlug,
                            initialMainImageUrl: _details?.mainImageUrl,
                            initialImageUrls: _details?.imagesUrls ?? const [],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Opacity(
                        opacity: 0.6,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: MapSelectionWidget(
                            key: _mapKey,
                            initialLat: _details?.lat,
                            initialLng: _details?.lng,
                            initialAddress: _details?.address,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    Consumer<AdCreationProvider>(
                      builder: (context, provider, _) => ElevatedButton(
                        onPressed: provider.submitting
                            ? null
                            : () async {
                                final loc =
                                    (_mapKey.currentState as dynamic)?.payload;
                                final double? latVal = (loc?['lat'] is num)
                                    ? (loc?['lat'] as num?)?.toDouble()
                                    : double.tryParse(
                                        loc?['lat']?.toString() ?? '');
                                final double? lngVal = (loc?['lng'] is num)
                                    ? (loc?['lng'] as num?)?.toDouble()
                                    : double.tryParse(
                                        loc?['lng']?.toString() ?? '');
                                final payload = CreateListingPayload(
                                  attributes: {
                                    'contract_type': _contractType,
                                    'property_type': _propertyType,
                                  },
                                  governorate:
                                      (_locationKey.currentState as dynamic)
                                          ?.selectedGov,
                                  city: (_locationKey.currentState as dynamic)
                                      ?.selectedCity,
                                  address: loc?['address']?.toString(),
                                  lat: latVal,
                                  lng: lngVal,
                                  price: _price,
                                  description: _description,
                                  contactPhone: _contactPhone,
                                  whatsappPhone: _whatsappPhone,
                                  planType: _details?.planType,
                                );
                                final ok = await provider.updateListing(
                                  categorySlug: widget.categorySlug,
                                  id: widget.adId,
                                  payload: payload,
                                  mainImage: ((_imagesKey.currentState
                                                  as dynamic)
                                              ?.mainImage ==
                                          null)
                                      ? null
                                      : File(
                                          ((_imagesKey.currentState as dynamic)
                                                  .mainImage)
                                              .path),
                                  images: (((_imagesKey.currentState as dynamic)
                                              ?.thumbImages ??
                                          []) as List)
                                      .map((x) => File((x).path))
                                      .toList(),
                                  remoteMainImageUrl:
                                      ((_imagesKey.currentState as dynamic)
                                          ?.remoteMainUrl) as String?,
                                  remoteImageUrls:
                                      (((_imagesKey.currentState as dynamic)
                                                  ?.remoteThumbUrls ??
                                              []) as List)
                                          .cast<String>(),
                                );
                                if (!mounted) return;
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('تم حفظ التعديلات')),
                                  );
                                  context.pop();
                                } else {
                                  final msg =
                                      provider.error ?? 'فشل تعديل الإعلان';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          fixedSize: Size.fromHeight(44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: provider.submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('حفظ التعديلات',
                                style: TextStyle(fontSize: 14.sp)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detailsRepo = AdDetailsRepository();
      final configRepo = CategoryRepository();
      final d = await detailsRepo.fetchAdDetails(
          categorySlug: widget.categorySlug, adId: widget.adId);
      final cfg = await configRepo.getCategoryFields(widget.categorySlug);
      _details = d;
      _config = cfg;
      _propertyType = d.attributes['property_type']?.toString();
      _contractType = d.attributes['contract_type']?.toString();
      _price = d.price.toString();
      _description = d.description.toString();
      _contactPhone = d.contactPhone.toString();
      _whatsappPhone = d.whatsappPhone?.toString();
      _priceController.text = _price ?? '';
      _descController.text = _description ?? '';
      _contactController.text = _stripDialCode(_contactPhone);
      _whatsController.text = _stripDialCode(_whatsappPhone);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _stripDialCode(String? input) {
    if (input == null) return '';
    var s = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (s.startsWith('20')) s = s.substring(2);
    return s;
  }
}
