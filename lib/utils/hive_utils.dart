import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class HiveUtils {
  /// Очищает и закрывает все активные Hive боксы.
  /// Для production-проектов лучше вручную поддерживать список имён используемых боксов.
  static Future<void> clearAllHiveData() async {
    try {
      final boxNames = <String>[
        'workouts',
        'exercises',
        'workoutExercises',
      ]; // Добавьте сюда свои боксы при расширении функционала
      bool atLeastOne = false;
      for (final name in boxNames) {
        if (Hive.isBoxOpen(name)) {
          final box = Hive.box(name);
          await box.clear();
          await box.close();
          debugPrint('[HiveUtils] Box "$name" очищен и закрыт.');
          atLeastOne = true;
        }
      }
      if (atLeastOne) {
        debugPrint('[HiveUtils] ✅ Все боксы очищены и закрыты!');
      } else {
        debugPrint('[HiveUtils] Нет открытых Hive боксов для очистки.');
      }
    } catch (e, s) {
      debugPrint('[HiveUtils] Ошибка при очистке Hive: $e\n$s');
    }
  }

  /// Сброс всех данных приложения через очистку hive, вызывать можно откуда угодно
  static Future<void> resetAppData() async {
    await clearAllHiveData();
  }
}
