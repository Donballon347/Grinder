import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        onPressed: () => _showAddSetSheet(context),
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
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () => _showExerciseActions(context),
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

  Future<void> _showAddSetSheet(BuildContext context) async {
    final box = Hive.box('workoutExercises');
    final currentEntryRaw = box.get(exerciseEntryId);
    if (currentEntryRaw == null) return;
    final currentEntry = Map<String, dynamic>.from(currentEntryRaw as Map);
    final isStatic = currentEntry['isStatic'] as bool? ?? false;
    final usesBodyWeight = currentEntry['usesBodyWeight'] as bool? ?? false;

    final defaultRepsOrDuration = isStatic ? 30 : 10;
    final defaultWeight = currentEntry['defaultWeight'] as int? ?? 10;

    final primaryController = TextEditingController(
      text: defaultRepsOrDuration.toString(),
    );
    final secondaryController = TextEditingController(
      text: defaultWeight.toString(),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;

            void updateController(TextEditingController controller, int delta) {
              final currentValue = int.tryParse(controller.text) ?? 0;
              final nextValue = (currentValue + delta).clamp(0, 9999);
              controller.text = nextValue.toString();
            }

            Future<void> handleAdd() async {
              final primaryValue = int.tryParse(primaryController.text) ?? 0;
              final secondaryValue =
                  int.tryParse(secondaryController.text) ?? 0;
              final primaryValid = primaryValue > 0;
              if (!primaryValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      isStatic
                          ? 'Enter the duration (sec)'
                          : 'Enter the number of repetitions',
                    ),
                  ),
                );
                return;
              }

              final entryRaw = box.get(exerciseEntryId);
              if (entryRaw == null) return;
              final entry = Map<String, dynamic>.from(entryRaw as Map);
              final sets = List<Map<String, dynamic>>.from(
                entry['sets'] ?? <Map<String, dynamic>>[],
              );
              final newSet = <String, dynamic>{
                'reps': isStatic ? 0 : primaryValue,
                'duration': isStatic ? primaryValue : 0,
                'weight': usesBodyWeight ? 0 : secondaryValue,
                'usesBodyWeight': usesBodyWeight,
                'createdAt': DateTime.now().toIso8601String(),
              };
              sets.add(newSet);

              final totalReps = sets.fold<int>(
                0,
                (sum, item) => sum + (item['reps'] as int? ?? 0),
              );
              final totalDuration = sets.fold<int>(
                0,
                (sum, item) => sum + (item['duration'] as int? ?? 0),
              );

              // Получаем навигатор/мессенджер ДО await, чтобы избежать использования
              // BuildContext после асинхронного разрыва.
              final navigator = Navigator.of(modalContext);
              final messenger = ScaffoldMessenger.of(context);

              await box.put(exerciseEntryId, {
                ...entry,
                'sets': sets,
                'totalSets': sets.length,
                'totalReps': totalReps,
                'totalDuration': totalDuration,
              });

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Set added'),
                  duration: Duration(seconds: 1),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.horizontal(context),
                right: AppSpacing.horizontal(context),
                bottom: bottomInset + AppSpacing.large,
                top: AppSpacing.large,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  AppSpacing.vLarge(),
                  _AddSetStepperRow(
                    label: isStatic ? 'Duration' : 'Repetitions',
                    controller: primaryController,
                    suffix: isStatic ? 'sec' : 'reps',
                    onMinus: () => setModalState(
                      () => updateController(primaryController, -1),
                    ),
                    onPlus: () => setModalState(
                      () => updateController(primaryController, 1),
                    ),
                  ),
                  AppSpacing.vMedium(),
                  usesBodyWeight
                      ? _BodyweightRow()
                      : _AddSetStepperRow(
                          label: 'Weight',
                          controller: secondaryController,
                          suffix: 'kg',
                          onMinus: () => setModalState(
                            () => updateController(secondaryController, -1),
                          ),
                          onPlus: () => setModalState(
                            () => updateController(secondaryController, 1),
                          ),
                        ),
                  AppSpacing.vLarge(),
                  ElevatedButton(
                    style: AppColors.primaryButtonStyle,
                    onPressed: handleAdd,
                    child: const Text(
                      'Add set',
                      style: AppColors.primaryButtonTextStyle,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showExerciseActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal(context),
              vertical: AppSpacing.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.vLarge(),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Add photo'),
                  subtitle: const Text(
                    'Upload an illustration of the exercise',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add photo (soon)')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_calls_outlined),
                  title: const Text('Exercise type'),
                  subtitle: const Text('Static (sec/min) or Dynamic (reps)'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change type (soon)')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center_outlined),
                  title: const Text('Resistance mode'),
                  subtitle: const Text('Bodyweight или Weight (kg)'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change resistance (soon)')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
            ? List<Map<String, dynamic>>.from(
                entry['sets'] ?? <Map<String, dynamic>>[],
              )
            : <Map<String, dynamic>>[];
        final isStatic = entry != null
            ? entry['isStatic'] as bool? ?? false
            : false;
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
              isStatic: isStatic,
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
  final bool isStatic;
  final VoidCallback onTap;
  const _SetCard({
    required this.set,
    required this.setNumber,
    required this.isStatic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reps = set['reps'] as int? ?? 0;
    final duration = set['duration'] as int? ?? 0;
    final usesBodyWeight = set['usesBodyWeight'] as bool? ?? false;
    final weightValue = set['weight'];

    final primaryText = isStatic ? _formatDuration(duration) : '$reps reps';

    String secondaryText;
    if (usesBodyWeight) {
      if (weightValue is num && weightValue > 0) {
        secondaryText = 'Bodyweight (${weightValue.toString()} kg)';
      } else {
        secondaryText = 'Bodyweight';
      }
    } else {
      final weight = weightValue is num
          ? weightValue
          : int.tryParse(weightValue?.toString() ?? '') ?? 0;
      secondaryText = '$weight kg';
    }
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
                  primaryText,
                  style: AppColors.textMain.copyWith(color: AppColors.primary),
                ),
              ),
              Text(
                secondaryText,
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

String _formatDuration(int seconds) {
  if (seconds <= 0) return '0 sec';
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  if (minutes == 0) return '$seconds sec';
  if (remaining == 0) return '$minutes min';
  return '$minutes min $remaining sec';
}

class _AddSetStepperRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _AddSetStepperRow({
    required this.label,
    required this.controller,
    required this.suffix,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppColors.textMain.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),

        AppSpacing.vTiny(),

        SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 62),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppColors.textMain.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      suffixText: suffix,
                      suffixStyle: AppColors.textMain.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                child: _CircleIconButton(icon: Icons.remove, onTap: onMinus),
              ),

              Positioned(
                right: 0,
                child: _CircleIconButton(icon: Icons.add, onTap: onPlus),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BodyweightRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Resistance',
          style: AppColors.textMain.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vTiny(),
        Row(
          children: [
            _CircleIconButton(icon: Icons.remove, onTap: null, disabled: true),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.divider, width: 1.4),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bodyweight',
                      style: AppColors.textMain.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.swap_horiz,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            _CircleIconButton(icon: Icons.add, onTap: null, disabled: true),
          ],
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null && !disabled;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}