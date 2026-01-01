class HomeModel {
  final String? bannerUrl;
  final String? supportNumber;
  final String? emergencyNumber;
  final String? passwordChangeNumber;
  final int? freeAdDaysValidity;

  const HomeModel({
    this.bannerUrl,
    this.supportNumber,
    this.emergencyNumber,
    this.passwordChangeNumber,
    this.freeAdDaysValidity,
  });

  /// ينشئ موديل من خريطة الاستجابة، ويدمج `baseUrl` للرابط النسبي عند الحاجة
  factory HomeModel.fromMap(
    Map<String, dynamic> map, {
    required String baseUrl,
  }) {
    String? raw = map['panner_image']?.toString() ?? map['value']?.toString();
    if (raw != null && raw.isNotEmpty) {
      if (!raw.startsWith('http')) {
        if (!raw.startsWith('/')) raw = '/$raw';
        raw = '$baseUrl$raw';
      }
    }

    final supportNumber =
        map['support_number']?.toString() ?? map['supportNumber']?.toString();
    final emergencyNumber = map['emergency_number']?.toString() ??
        map['emergencyNumber']?.toString();
    final passwordChangeNumber = map['sub_support_number']?.toString() ??
        map['subSupportNumber']?.toString();

    // Parse free_ad_days_validity
    int? freeDays;
    final fdRaw = map['free_ad_days_validity'];
    if (fdRaw is int) {
      freeDays = fdRaw;
    } else if (fdRaw != null) {
      freeDays = int.tryParse(fdRaw.toString());
    }

    return HomeModel(
      bannerUrl: raw,
      supportNumber: supportNumber,
      emergencyNumber: emergencyNumber,
      passwordChangeNumber: passwordChangeNumber,
      freeAdDaysValidity: freeDays,
    );
  }

  /// بعض الـ APIs ترجع قائمة بإعدادات النظام؛ نستخرج القيم المطلوبة بشكل مرن
  factory HomeModel.fromApiList(
    List<dynamic> data, {
    required String baseUrl,
  }) {
    String? banner;
    String? support;
    String? emergency;
    int? freeDays;

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final key = item['key']?.toString().toLowerCase();
        final val = item['value']?.toString();
        final pn = item['panner_image']?.toString();

        if (banner == null) {
          if (pn != null && pn.isNotEmpty) {
            banner = pn;
          } else if (key == 'panner_image' ||
              key == 'banner_image' ||
              (val != null && val.contains('/banner/'))) {
            banner = val;
          }
        }
        if (support == null) {
          if (item['support_number'] != null) {
            support = item['support_number']?.toString();
          } else if (key == 'support_number') {
            support = val;
          }
        }
        if (emergency == null) {
          if (item['emergency_number'] != null) {
            emergency = item['emergency_number']?.toString();
          } else if (key == 'emergency_number') {
            emergency = val;
          }
        }
        // Check for free_ad_days_validity
        if (freeDays == null) {
          if (item['free_ad_days_validity'] != null) {
            final raw = item['free_ad_days_validity'];
            freeDays = (raw is int) ? raw : int.tryParse(raw.toString());
          } else if (key == 'free_ad_days_validity') {
            freeDays = int.tryParse(val ?? '');
          }
        }
      }
    }
    if (banner != null && banner.isNotEmpty) {
      if (!banner.startsWith('http')) {
        if (!banner.startsWith('/')) banner = '/$banner';
        banner = '$baseUrl$banner';
      }
    }
    return HomeModel(
      bannerUrl: banner,
      supportNumber: support,
      emergencyNumber: emergency,
      freeAdDaysValidity: freeDays,
    );
  }
}
