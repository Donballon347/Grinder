class Exercise {
  final String id;            // exerciseEntryId
  final String name;          // название упражнения
  final String? imageUrl;     // картинка (необязательно)
  final List<Map<String, dynamic>> sets; // список сетов

  Exercise({
    required this.id,
    required this.name,
    this.imageUrl,
    this.sets = const [],
  });
}
