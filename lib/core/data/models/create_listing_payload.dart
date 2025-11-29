class CreateListingPayload {
  final String? price;
  final String? governorate;
  final String? city;
  final String? description;
  final String? planType;
  final double? lat;
  final double? lng;
  final String? address;
  final String? contactPhone;
  final String? whatsappPhone;
  final String? make;
  final String? model;
  final Map<String, dynamic> attributes;

  const CreateListingPayload({
    this.price,
    this.governorate,
    this.city,
    this.description,
    this.planType,
    this.lat,
    this.lng,
    this.address,
    this.contactPhone,
    this.whatsappPhone,
    this.make,
    this.model,
    this.attributes = const {},
  });

  Map<String, dynamic> toFormMap() {
    final Map<String, dynamic> map = {};
    if (price != null) map['price'] = price;
    if (governorate != null) map['governorate'] = governorate;
    if (city != null) map['city'] = city;
    if (description != null) map['description'] = description;
    if (planType != null) map['plan_type'] = planType;
    if (lat != null) map['lat'] = lat.toString();
    if (lng != null) map['lng'] = lng.toString();
    if (address != null) map['address'] = address;
    if (contactPhone != null) map['contact_phone'] = contactPhone;
    if (whatsappPhone != null) map['whatsapp_phone'] = whatsappPhone;
    if (make != null) map['make'] = make;
    if (model != null) map['model'] = model;
    attributes.forEach((key, value) {
      if (value != null) {
        map['attributes[$key]'] = value.toString();
      }
    });
    return map;
  }
}
