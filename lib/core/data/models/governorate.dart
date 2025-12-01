import 'city.dart';

class Governorate {
  final int id;
  final String name;
  final List<City> cities;

  const Governorate({
    required this.id,
    required this.name,
    required this.cities,
  });

  factory Governorate.fromMap(Map<String, dynamic> json) {
    final citiesData = json['cities'] as List<dynamic>? ?? [];
    return Governorate(
      id: json['id'] as int,
      name: json['name'] as String,
      cities: citiesData
          .where((e) => e is Map)
          .map((e) => City.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
