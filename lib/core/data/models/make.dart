import 'car_model.dart';
class Make {
  final int id;
  final String name;
  final List<CarModel> models;
  const Make({required this.id, required this.name, required this.models});

  factory Make.fromMap(Map<String, dynamic> json) {
    final modelsData = json['models'] as List<dynamic>? ?? [];
    return Make(
      id: json['id'] as int,
      name: json['name'] as String,
      models: modelsData.map((e) => CarModel.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }
}