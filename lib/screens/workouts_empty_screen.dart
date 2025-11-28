import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/widgets/app_bottom_nav_bar.dart';
import 'package:grinder/widgets/empty_state_message.dart';
import 'package:grinder/screens/add_workout_screen.dart';
import 'package:grinder/theme/app_spacing.dart';

class WorkoutsEmptyScreen extends StatelessWidget {
  const WorkoutsEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    // Адаптивные отступы и размеры шрифтов
    final horizontalPadding = AppSpacing.horizontal(context);
    final titleFontSize = size.width * 0.064; // ~25 на ширине 390
    // Размеры текста считаются внутри дочерних виджетов при необходимости

    // Цвета берём напрямую из AppColors при необходимости

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: horizontalPadding,
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
            padding: EdgeInsets.only(right: horizontalPadding),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
                );
              },
              icon: Icon(
                Symbols.add,
                weight: 700,
                color: AppColors.textPrimary,
                size: titleFontSize,
              ),
              tooltip: 'Add',
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        onTap: (_) {},
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: AppSpacing.horizontalInsets(context),
              child: Column(
                children: [
                  // Центральное пустое состояние
                  const Expanded(
                    child: EmptyStateMessage(
                      titleRedPart1: 'No ',
                      titleMiddlePart: 'Workouts ',
                      titleRedPart2: 'Yet',
                      subtitleBeforeIcon: 'Tap the ',
                      subtitleAfterIcon: ' button to create your first workout',
                      icon: Icons.add,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
