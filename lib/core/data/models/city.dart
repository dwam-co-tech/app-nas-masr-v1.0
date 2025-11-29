// ===========================================
// core/data/models/city.dart
// ===========================================
class City {
  final int id;
  final String name;
  const City({required this.id, required this.name});
  factory City.fromMap(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

