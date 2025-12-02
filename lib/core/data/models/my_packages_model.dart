class MyPackage {
  final String title;
  final String badgeText;
  final String? expiresAtHuman;
  final String? note;

  MyPackage({
    required this.title,
    required this.badgeText,
    this.expiresAtHuman,
    this.note,
  });

  factory MyPackage.fromMap(Map<String, dynamic> map) {
    return MyPackage(
      title: map['title']?.toString() ?? '',
      badgeText: map['badge_text']?.toString() ?? '',
      expiresAtHuman: map['expires_at_human']?.toString(),
      note: map['note']?.toString(),
    );
  }
}
