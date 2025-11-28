import 'package:flutter/material.dart';
import 'package:grinder/models/workout.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/theme/app_spacing.dart';
import 'package:intl/intl.dart';
import 'package:grinder/widgets/empty_state_message.dart';
import 'package:grinder/screens/exercises_screen.dart';
import 'package:grinder/screens/exercise_detail_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({required this.workout, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.06;
    final titleFontSize = size.width * 0.064;
    final dateFontSize = size.width * 0.037;
    final descFontSize = size.width * 0.043;
    final exercisesTitleFontSize = size.width * 0.041;
    final formattedDate = DateFormat(
      'EEE, MMM d, yyyy',
    ).format(workout.createdAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        title: Text(
          workout.title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            onPressed: () {},
            tooltip: 'More',
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box('workoutExercises').listenable(),
          builder: (context, workoutExerciseBox, _) {
            final exercises =
                workoutExerciseBox.values
                    .cast<Map>()
                    .map((value) => Map<String, dynamic>.from(value))
                    .where((value) => value['workoutId'] == workout.id)
                    .toList()
                  ..sort((a, b) {
                    final aDate =
                        DateTime.tryParse(a['createdAt'] as String? ?? '') ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    final bDate =
                        DateTime.tryParse(b['createdAt'] as String? ?? '') ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                    return bDate.compareTo(aDate);
                  });

            return ValueListenableBuilder<Box>(
              valueListenable: Hive.box('exercises').listenable(),
              builder: (context, exerciseLibraryBox, __) {
                final exerciseNames = <String, String>{};
                for (final entry in exerciseLibraryBox.toMap().entries) {
                  final value = Map<String, dynamic>.from(entry.value as Map);
                  final id = value['id'] as String? ?? entry.key.toString();
                  exerciseNames[id] =
                      value['name'] as String? ?? 'Unnamed exercise';
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.015),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (workout.description != null &&
                          workout.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            workout.description!,
                            style: TextStyle(
                              fontSize: descFontSize,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      SizedBox(height: size.height * 0.025),
                      Container(
                        width: double.infinity,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: AppColors.divider,
                      ),
                      SizedBox(height: size.height * 0.012),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'EXERCISES (${exercises.length})',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: exercisesTitleFontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: titleFontSize * 0.98,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExercisesScreen(workoutId: workout.id),
                                ),
                              );
                            },
                            tooltip: 'Add Exercise',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (exercises.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                EmptyStateMessage(
                                  titleRedPart1: 'No ',
                                  titleMiddlePart: 'Exercises ',
                                  titleRedPart2: 'Yet',
                                  subtitleBeforeIcon: 'Tap the ',
                                  subtitleAfterIcon:
                                      ' button to add your first exercise',
                                  icon: Icons.add,
                                ),
                                const SizedBox(height: 29),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: AppColors.primaryButtonStyle,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ExercisesScreen(
                                            workoutId: workout.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Add Exercise',
                                      style: AppColors.primaryButtonTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.only(
                              bottom: AppSpacing.large,
                              top: AppSpacing.small,
                            ),
                            itemCount: exercises.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.divider,
                              indent: 0,
                              endIndent: 0,
                            ),
                            itemBuilder: (context, index) {
                              final entry = exercises[index];
                              final exerciseId =
                                  entry['exerciseId'] as String? ?? '';
                              final name =
                                  exerciseNames[exerciseId] ?? 'Exercise';
                              final imageUrl =
                                  entry['imageUrl'] as String? ?? '';

                              // Получаем все сеты для упражнения
                              final sets = (entry['sets'] as List?) != null
                                  ? (entry['sets'] as List)
                                        .map(
                                          (e) => Map<String, dynamic>.from(e),
                                        )
                                        .toList()
                                  : [];
                              final totalSets = sets.length;
                              int totalReps = 0;
                              int totalDuration = 0;
                              bool isStatic = false;

                              for (final s in sets) {
                                totalReps += s['reps'] as int? ?? 0;
                                totalDuration += s['duration'] as int? ?? 0;
                                if ((s['duration'] as int?) != null &&
                                    (s['duration'] as int?)! > 0) {
                                  isStatic = true;
                                }
                              }

                              String label;
                              if (isStatic && totalDuration > 0) {
                                final min = totalDuration ~/ 60;
                                final sec = totalDuration % 60;
                                final timeStr = min > 0
                                    ? '${min}min${sec > 0 ? ' $sec sec' : ''}'
                                    : '$sec sec';
                                label = '$totalSets sets · $timeStr';
                              } else {
                                label = '$totalSets sets · $totalReps reps';
                              }

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseDetailScreen(
                                        workoutId: workout.id,
                                        exerciseEntryId:
                                            entry['id']?.toString() ?? '',
                                        sessionTitle: workout.title,
                                        workoutDate: workout.createdAt,
                                        exerciseName: name,
                                        imageUrl: imageUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.white,
                                  height: 82,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _buildExerciseImageOrInitials(
                                        name,
                                        imageUrl,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.048,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 7),
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.0385,
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 14),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Widget _buildExerciseImageOrInitials(String name, String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return Container(
      width: 64,
      height: 64,
      color: Colors.black12,
      child: ClipRect(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 64,
          height: 64,
        ),
      ),
    );
  }
  final words = name.split(' ');
  final initials = words
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();
  return Container(
    width: 64,
    height: 64,
    color: AppColors.primary,
    alignment: Alignment.center,
    child: Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
