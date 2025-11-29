// ===========================================
// core/data/models/car_model.dart
// ===========================================
class CarModel {
  final int id;
  final String name;
  const CarModel({required this.id, required this.name});
  factory CarModel.fromMap(Map<String, dynamic> json) {
    return CarModel(id: json['id'] as int, name: json['name'] as String);
  }
}


