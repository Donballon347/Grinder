import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/theme/app_spacing.dart';
import 'package:grinder/widgets/empty_state_message.dart';

class ExercisesScreen extends StatefulWidget {
  final String workoutId;
  const ExercisesScreen({super.key, required this.workoutId});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredExercises(
    List<Map<String, dynamic>> allExercises,
  ) {
    if (_searchQuery.isEmpty) {
      return allExercises;
    }
    final query = _searchQuery.toLowerCase();
    return allExercises.where((exercise) {
      final name = (exercise['name'] as String? ?? '').toLowerCase();
      return name.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getAllExercises(Box box) {
    final entries = box.toMap().entries;
    final exercises =
        entries.map((entry) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          return {...map, 'id': map['id'] ?? entry.key.toString()};
        }).toList()..sort((a, b) {
          final aDate =
              DateTime.tryParse(a['createdAt'] as String? ?? '') ??
              DateTime.fromMicrosecondsSinceEpoch(0);
          final bDate =
              DateTime.tryParse(b['createdAt'] as String? ?? '') ??
              DateTime.fromMicrosecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
    return exercises;
  }

  Future<void> _handleAddExerciseToWorkout(String exerciseId) async {
    final workoutBox = Hive.box('workoutExercises');
    final newId = 'we_${_uuid.v4()}';
    await workoutBox.put(newId, {
      'id': newId,
      'workoutId': widget.workoutId,
      'exerciseId': exerciseId,
      'sets': <Map<String, dynamic>>[],
      'totalSets': 0,
      'totalReps': 0,
      'usesBodyWeight': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise added to workout'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleCreateExercise(String name) async {
    try {
      final box = Hive.box('exercises');
      final id = _uuid.v4();
      await box.put(id, {
        'id': id,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });
      // // Автоматически добавляем упражнение в текущую тренировку
      // await _handleAddExerciseToWorkout(id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise created'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating exercise: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ---------------- модалка создания упражнения -------------
  Future<String?> _showCreateExerciseSheet() async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ExerciseCreateSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = AppSpacing.horizontal(context);
    final searchFontSize = size.width * 0.043;
    final exerciseNameFontSize = size.width * 0.048;
    final exerciseSubtitleFontSize = size.width * 0.0385;

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
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Exercises',
          style: AppColors.textMain.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box('exercises').listenable(),
          builder: (context, exerciseBox, _) {
            final allExercises = _getAllExercises(exerciseBox);
            final hasExercises = allExercises.isNotEmpty;
            final displayExercises = _getFilteredExercises(allExercises);

            return ValueListenableBuilder<Box>(
              valueListenable: Hive.box('workoutExercises').listenable(),
              builder: (context, workoutBox, __) {
                return Column(
                  children: [
                    if (hasExercises)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.medium,
                          horizontalPadding,
                          AppSpacing.small,
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.left,
                          style: AppColors.textMain,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: AppColors.textMainSecondary.copyWith(
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              size: searchFontSize * 1.1,
                            ),
                            filled: true,
                            fillColor: AppColors.textSecondary.withValues(
                              alpha: 0.05,
                            ), // светло-серый!
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                width: 1.4,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 4,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: hasExercises
                          ? displayExercises.isEmpty
                                ? Center(
                                    child: EmptyStateMessage(
                                      titleRedPart1: 'No ',
                                      titleMiddlePart: 'Exercises ',
                                      titleRedPart2: 'Found',
                                      subtitleBeforeIcon: '',
                                      subtitleAfterIcon: '',
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                      vertical: AppSpacing.small,
                                    ),
                                    itemCount: displayExercises.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.divider.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    itemBuilder: (context, index) {
                                      final exercise = displayExercises[index];
                                      final exerciseId =
                                          exercise['id']?.toString() ?? '';
                                      final name =
                                          exercise['name'] as String? ??
                                          'Unnamed Exercise';
                                      final subtitle =
                                          exercise['subtitle'] as String? ?? '';
                                      return _ExerciseTile(
                                        name: name,
                                        subtitle: subtitle,
                                        nameFontSize: exerciseNameFontSize,
                                        subtitleFontSize:
                                            exerciseSubtitleFontSize,
                                        onAdd: exerciseId.isEmpty
                                            ? null
                                            : () => _handleAddExerciseToWorkout(
                                                exerciseId,
                                              ),
                                      );
                                    },
                                  )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: const EmptyStateMessage(
                                titleRedPart1: 'No ',
                                titleMiddlePart: 'Exercises ',
                                titleRedPart2: 'Yet',
                                subtitleBeforeIcon: 'Tap the ',
                                subtitleAfterIcon:
                                    ' button to create your first exercise',
                                icon: Icons.add,
                              ),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: AppSpacing.medium,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppColors.primaryButtonStyle,
                          onPressed: () async {
                            if (!mounted) return;
                            final name = await _showCreateExerciseSheet();
                            if (!mounted) return;
                            if (name != null && name.trim().isNotEmpty) {
                              await _handleCreateExercise(name);
                              if (!mounted) return;
                            }
                          },
                          child: const Text(
                            'Create Exercise',
                            style: AppColors.primaryButtonTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ExerciseCreateSheet extends StatefulWidget {
  const ExerciseCreateSheet({super.key});
  @override
  State<ExerciseCreateSheet> createState() => _ExerciseCreateSheetState();
}

class _ExerciseCreateSheetState extends State<ExerciseCreateSheet> {
  late final TextEditingController controller;
  bool canSave = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(() {
      setState(() => canSave = controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppSpacing.horizontal(context);
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.large,
        top: AppSpacing.large,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vLarge(),
          Text(
            'Create exercise',
            style: AppColors.textMain.copyWith(fontSize: 18),
          ),
          AppSpacing.vMedium(),
          TextField(
            controller: controller,
            autofocus: true,
            style: AppColors.textMain.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Exercise name',
              filled: true,
              fillColor: AppColors.textSecondary.withValues(alpha: 0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 14,
              ),
            ),
          ),
          AppSpacing.vLarge(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppColors.primaryButtonStyle,
              onPressed: canSave
                  ? () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop(controller.text.trim());
                    }
                  : null,
              child: const Text(
                'Save',
                style: AppColors.primaryButtonTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatefulWidget {
  final String name;
  final String? subtitle;
  final double nameFontSize;
  final double subtitleFontSize;
  final VoidCallback? onAdd;

  const _ExerciseTile({
    required this.name,
    this.subtitle,
    required this.nameFontSize,
    required this.subtitleFontSize,
    this.onAdd,
  });

  @override
  State<_ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<_ExerciseTile> {
  bool _showCheck = false;

  void _handleAdd() async {
    if (widget.onAdd != null) {
      widget.onAdd!();
      setState(() => _showCheck = true);
      await Future.delayed(const Duration(milliseconds: 650));
      if (mounted) setState(() => _showCheck = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onAdd == null;
    final addColor = isDisabled
        ? AppColors.textSecondary.withValues(alpha: 0.4)
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: AppColors.textMain),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(widget.subtitle!, style: AppColors.textSmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _showCheck
                ? Container(
                    key: const ValueKey('check'),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey('plus'),
                    onTap: isDisabled ? null : _handleAdd,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: addColor, width: 1.5),
                      ),
                      child: Icon(Icons.add, color: addColor, size: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
