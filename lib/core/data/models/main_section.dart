import 'sub_section.dart';

class MainSection {
  final int id;
  final String name;
  final List<SubSection> subSections;

  const MainSection({
    required this.id,
    required this.name,
    required this.subSections,
  });

  factory MainSection.fromMap(Map<String, dynamic> json) {
    final subSectionsData = json['sub_sections'] as List<dynamic>? ?? [];
    return MainSection(
      id: json['id'] as int,
      name: json['name'] as String,
      subSections: subSectionsData
          .where((e) => e is Map)
          .map((e) => SubSection.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
