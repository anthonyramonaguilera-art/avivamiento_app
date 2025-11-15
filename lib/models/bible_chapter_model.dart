class BibleChapterModel {
  final String id;
  final String number;

  BibleChapterModel({
    required this.id,
    required this.number,
  });

  factory BibleChapterModel.fromMap(Map<String, dynamic> data) {
    return BibleChapterModel(
      id: data['id'] ?? 'Sin ID',
      number: data['number'] ?? '0',
    );
  }
}
