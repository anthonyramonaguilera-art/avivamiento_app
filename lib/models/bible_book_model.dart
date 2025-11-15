//Aca manejo el modelo de los libros de la biblia
class BibleBookModel {
  final String id;
  final String name;
  final String testament;

  const BibleBookModel({
    required this.id,
    required this.name,
    required this.testament,
  });

  factory BibleBookModel.fromMap(Map<String, dynamic> data) {
    return BibleBookModel(
      id: data['id'] ?? 'Sin ID',
      name: data['name'] ?? 'Desconocido',
      testament: data['testament'] ?? 'OT',
    );
  }
}
