import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart'; // FOR HIVE PATH
import 'screens/workouts_list_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'models/workout.dart';
// import 'utils/hive_utils.dart'; // FOR RESETING HIVE
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('workouts');
  await Hive.openBox('exercises'); // global exercise library
  await Hive.openBox('workoutExercises'); // per workout entries

  // ---- ДОБАВЛЕНИЕ БАЗОВЫХ УПРАЖНЕНИЙ ----
  final exercisesBox = Hive.box('exercises');
  if (exercisesBox.isEmpty) {
    final now = DateTime.now().toIso8601String();
    final uuid = Uuid();
    final baseExercises = [
      'Squats',
      'Push-ups',
      'Pull-ups',
      'Crunches',
      'Planks',
      'Burpees',
      'Lunges',
      'Jumping Jacks',
      'Mountain Climbers',
      'Leg Raises',
      'Leg Press',
      'Leg Extension',
      'Leg Curls',
    ];
    for (final name in baseExercises) {
      final id = uuid.v4();
      exercisesBox.put(id, {'id': id, 'name': name, 'createdAt': now});
    }
  }
  // ---- END BASE ----

  // ------------------FOR TESTING ONLY
  //await HiveUtils.resetAppData(); // CLEAR ALL HIVE DATA
  // final dir = await getApplicationDocumentsDirectory();
  // print('📁 Hive path: \\${dir.path}');
  // FOR TESTING ONLY------------------

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grinder',
      debugShowCheckedModeBanner: false, // убираем красный debug баннер
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(surface: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const WorkoutsListScreen(), // подключаем твой экран
      routes: {
        '/workout': (context) => WorkoutDetailScreen(
          workout: ModalRoute.of(context)!.settings.arguments as Workout,
        ),
      },
    );
  }
}
