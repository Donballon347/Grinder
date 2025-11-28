import 'package:flutter/material.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/theme/app_spacing.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grinder/models/workout.dart';
import 'package:uuid/uuid.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _canSave = false;
  late AnimationController _animController;
  late Animation<double> _saveFadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _saveFadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _titleController.addListener(_validate);
  }

  void _validate() {
    final isFilled = _titleController.text.trim().isNotEmpty;
    if (isFilled != _canSave) {
      setState(() {
        _canSave = isFilled;
        if (_canSave) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!_canSave || !_formKey.currentState!.validate()) return;
    final box = Hive.box('workouts');
    final workout = Workout(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );
    await box.add(workout.toMap());
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleFontSize = size.width * 0.064;
    final inputFontSize = size.width * 0.045;
    final labelFontSize = size.width * 0.035;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: SizedBox(
            height: kToolbarHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cancel слева
                Positioned(
                  left: AppSpacing.horizontal(context),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(60, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: Navigator.of(context).maybePop,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                // Заголовок центр
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'New workout',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Save справа
                Positioned(
                  right: AppSpacing.horizontal(context),
                  child: FadeTransition(
                    opacity: _saveFadeAnim,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(36, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerRight,
                      ),
                      onPressed: _canSave ? _onSave : null,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: _canSave
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                          fontSize: labelFontSize + 2,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppSpacing.horizontalInsets(context),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.vLarge(),
                    _LabeledInputField(
                      label: 'Workout title',
                      controller: _titleController,
                      required: true,
                      hintText: 'Push day #1',
                      fontSize: inputFontSize,
                      labelFontSize: labelFontSize,
                      borderColor: _canSave
                          ? AppColors.primary
                          : AppColors.divider,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter workout title';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.vLarge(),
                    _LabeledInputField(
                      label: 'Description',
                      controller: _notesController,
                      hintText: 'Notes',
                      fontSize: inputFontSize,
                      labelFontSize: labelFontSize,
                      maxLines: 5,
                    ),
                    AppSpacing.vMedium(),
                    // Можно убрать, если нет кнопки снизу
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LabeledInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final String? hintText;
  final double? fontSize;
  final double? labelFontSize;
  final int? maxLines;
  final FormFieldValidator<String>? validator;
  final Color? borderColor;

  const _LabeledInputField({
    required this.label,
    required this.controller,
    this.required = false,
    this.hintText,
    this.fontSize,
    this.labelFontSize,
    this.maxLines = 1,
    this.validator,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: labelFontSize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.divider,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: borderColor ?? AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
