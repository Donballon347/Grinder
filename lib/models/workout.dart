import 'exercise.dart';

class Workout {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.title,
    this.description,
    DateTime? createdAt,
    List<Exercise>? exercises,
  })  : createdAt = createdAt ?? DateTime.now(),
        exercises = exercises ?? const [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'exercises': [], // Позже: сериализация упражнений
  };

  factory Workout.fromMap(Map map) {
    return Workout(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      exercises: const [], // Позже: парсинг упражнений если появится
    );
  }
}
