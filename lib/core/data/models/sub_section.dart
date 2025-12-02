class SubSection {
  final int id;
  final String name;
  final int mainSectionId;

  const SubSection({
    required this.id,
    required this.name,
    required this.mainSectionId,
  });

  factory SubSection.fromMap(Map<String, dynamic> json) {
    return SubSection(
      id: json['id'] as int,
      name: json['name'] as String,
      mainSectionId: json['main_section_id'] as int,
    );
  }
}
