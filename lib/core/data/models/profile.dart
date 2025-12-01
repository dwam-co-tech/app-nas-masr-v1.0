class Profile {
  final String id;
  final String? name;
  final String? phone;
  final String? referralCode;
  final String? code;
  final double? lat;
  final double? lng;
  final String? address;
  final bool? otpVerified;
  final String? otp;

  const Profile({
    required this.id,
    this.name,
    this.phone,
    this.referralCode,
    this.code,
    this.lat,
    this.lng,
    this.address,
    this.otpVerified,
    this.otp,
  });

  factory Profile.fromApi(Map<String, dynamic> json) {
    final data = json;
    final id = (data['id'] ?? '').toString();
    final name = data['name']?.toString();
    final phone = data['phone']?.toString();
    final ref = data['referral_code']?.toString();
    final code = data['code']?.toString();
    final latStr = data['lat']?.toString();
    final lngStr = data['lng']?.toString();
    final address = data['address']?.toString();
    final otpVerifiedRaw = data['otp_verified'];
    final otpVerified = otpVerifiedRaw is bool
        ? otpVerifiedRaw
        : (otpVerifiedRaw?.toString().toLowerCase() == 'true');
    final otp = data['otp']?.toString();
    final lat = (latStr == null || latStr.isEmpty) ? null : double.tryParse(latStr);
    final lng = (lngStr == null || lngStr.isEmpty) ? null : double.tryParse(lngStr);
    return Profile(id: id, name: name, phone: phone, referralCode: ref, code: code, lat: lat, lng: lng, address: address, otpVerified: otpVerified, otp: otp);
  }
}
