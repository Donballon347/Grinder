import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grinder/models/workout.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/theme/app_spacing.dart';
import 'package:grinder/widgets/empty_state_message.dart';
import 'add_workout_screen.dart';
import 'package:grinder/widgets/app_bottom_nav_bar.dart';
import 'workout_detail_screen.dart';

class WorkoutsListScreen extends StatefulWidget {
  const WorkoutsListScreen({super.key});

  @override
  State<WorkoutsListScreen> createState() => _WorkoutsListScreenState();
}

class _WorkoutsListScreenState extends State<WorkoutsListScreen> {
  bool _newestFirst = true;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('workouts');
    final titleFontSize = MediaQuery.of(context).size.width * 0.064;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: AppSpacing.horizontal(context),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Workouts',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.horizontal(context)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() => _newestFirst = !_newestFirst);
                  },
                  icon: Icon(
                    Icons.swap_vert,
                    color: AppColors.textPrimary,
                    size: titleFontSize * 0.85,
                  ),
                  tooltip: _newestFirst ? 'Сначала новые' : 'Сначала старые',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: AppColors.textPrimary,
                    size: titleFontSize,
                  ),
                  tooltip: 'Add',
                ),
              ],
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, _, __) {
          var workouts = box.values.toList();
          if (_newestFirst) {
            workouts = workouts.reversed.toList();
          }
          if (workouts.isEmpty) {
            return const EmptyStateMessage(
              titleRedPart1: 'No ',
              titleMiddlePart: 'Workouts ',
              titleRedPart2: 'Yet',
              subtitleBeforeIcon: 'Tap the ',
              subtitleAfterIcon: ' button to create your first workout',
              icon: Icons.add,
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal(context),
              vertical: AppSpacing.large,
            ),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => AppSpacing.vMedium(),
            itemBuilder: (context, index) {
              final map = workouts[index] as Map;
              final workout = Workout.fromMap(map);
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(workout: workout),
                    ),
                  );
                },
                child: _WorkoutTile(workout: workout),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final Workout workout;
  const _WorkoutTile({required this.workout});
  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${workout.createdAt.day.toString().padLeft(2, '0')} '
        '${_monthShort(workout.createdAt.month)} ${workout.createdAt.year}';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: MediaQuery.of(context).size.width * 0.048,
              ),
            ),
            if (workout.description != null && workout.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  workout.description!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: MediaQuery.of(context).size.width * 0.0385,
                  ),
                ),
              ),
            AppSpacing.vSmall(),
            Text(
              dateStr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: MediaQuery.of(context).size.width * 0.031,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
