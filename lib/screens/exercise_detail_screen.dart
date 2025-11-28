import 'package:flutter/material.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/theme/app_spacing.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grinder/widgets/empty_state_message.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String workoutId;
  final String exerciseEntryId;
  final String sessionTitle;
  final DateTime workoutDate;
  final String? imageUrl;
  final String exerciseName;
  const ExerciseDetailScreen({
    super.key,
    required this.workoutId,
    required this.exerciseEntryId,
    required this.sessionTitle,
    required this.workoutDate,
    required this.exerciseName,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(workoutDate);
    final horizontalPadding = AppSpacing.horizontal(context);

    final width = MediaQuery.of(context).size.width;
    final statusBar = MediaQuery.of(context).padding.top; // для высоты выреза

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Фон/картинка ПОД SafeArea, с захватом StatusBar и выреза
          Container(
            width: double.infinity,
            height: width * 0.45 + statusBar,
            decoration: BoxDecoration(
              color: imageUrl != null && imageUrl!.isNotEmpty
                  ? null
                  : AppColors.primary,
              image: imageUrl != null && imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          // Контент ВНУТРИ SafeArea
          SafeArea(
            child: Column(
              children: [
                _buildHeaderContent(context),
                _InfoSection(
                  sessionTitle: sessionTitle,
                  dateStr: dateStr,
                  horizontalPadding: horizontalPadding,
                ),
                Expanded(
                  child: _SetsList(
                    exerciseEntryId: exerciseEntryId,
                    horizontalPadding: horizontalPadding,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showEditSetModal(context),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Новый метод: контент Header'а, без бокса фона (он теперь отдельно)
  Widget _buildHeaderContent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: double.infinity,
      height: width * 0.45,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal(context),
          right: AppSpacing.horizontal(context),
          bottom: 18,
          top: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              exerciseName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSetModal(BuildContext context) async {
    // TODO: реализовать открытие модалки редактирования сета.
  }
}

class _InfoSection extends StatelessWidget {
  final String sessionTitle;
  final String dateStr;
  final double horizontalPadding;
  const _InfoSection({
    required this.sessionTitle,
    required this.dateStr,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    // style for grey (top), style for black (bottom)
    final greyStyle = AppColors.textMain.copyWith(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    final blackStyle = AppColors.textMain.copyWith(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: AppSpacing.medium,
            bottom: AppSpacing.tiny,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: greyStyle),
              AppSpacing.vTiny(),
              Text(
                sessionTitle,
                style: blackStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 14),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 2, // потолще
          color: AppColors.divider,
        ),
      ],
    );
  }
}

class _SetsList extends StatelessWidget {
  final String exerciseEntryId;
  final double horizontalPadding;
  const _SetsList({
    required this.exerciseEntryId,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('workoutExercises').listenable(),
      builder: (context, box, _) {
        final entry = box.get(exerciseEntryId);
        final sets = entry != null
            ? List<Map<String, dynamic>>.from(entry['sets'] ?? [])
            : [];
        if (sets.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 104,
              top: AppSpacing.large,
            ),
            child: const EmptyStateMessage(
              titleRedPart1: 'No ',
              titleMiddlePart: 'Sets ',
              titleRedPart2: 'Yet',
              subtitleBeforeIcon: 'Tap the ',
              subtitleAfterIcon: ' button to add first set',
              icon: Icons.add,
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 104,
            top: AppSpacing.medium,
          ),
          itemCount: sets.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.small),
          itemBuilder: (context, index) {
            final set = sets[index];
            return _SetCard(
              set: set,
              setNumber: index + 1,
              onTap: () {
                // TODO: перейти к экрану/модалке редактирования сета
              },
            );
          },
        );
      },
    );
  }
}

class _SetCard extends StatelessWidget {
  final Map<String, dynamic> set;
  final int setNumber;
  final VoidCallback onTap;
  const _SetCard({
    required this.set,
    required this.setNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reps = set['reps'] ?? 0;
    final weight = set['weight'] ?? 'BW';
    final usesBodyWeight = set['usesBodyWeight'] ?? true;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            children: [
              Text(
                '$setNumber',
                style: AppColors.textMain.copyWith(fontWeight: FontWeight.w700),
              ),
              AppSpacing.hMedium(),
              Expanded(
                child: Text(
                  '$reps reps',
                  style: AppColors.textMain.copyWith(color: AppColors.primary),
                ),
              ),
              Text(
                usesBodyWeight ? 'BW ($weight кг)' : '$weight кг',
                style: AppColors.textMain.copyWith(color: AppColors.primary),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
