import 'package:flutter/material.dart';
import 'package:grinder/theme/app_colors.dart';
import 'package:grinder/theme/app_spacing.dart';

class EmptyStateMessage extends StatelessWidget {
  final String titleRedPart1;
  final String titleMiddlePart;
  final String titleRedPart2;
  final String subtitleBeforeIcon; // текст до иконки
  final String subtitleAfterIcon; // текст после иконки
  final IconData? icon;
  final double? iconSize;

  const EmptyStateMessage({
    required this.titleRedPart1,
    required this.titleMiddlePart,
    required this.titleRedPart2,
    required this.subtitleBeforeIcon,
    required this.subtitleAfterIcon,
    this.icon,
    this.iconSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headlineFontSize = size.width * 0.061;
    final subtitleFontSize = size.width * 0.038;
    final Color red = AppColors.primary;
    final Color grey = AppColors.textSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: headlineFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: titleRedPart1,
                  style: TextStyle(color: red),
                ),
                TextSpan(text: titleMiddlePart),
                TextSpan(
                  text: titleRedPart2,
                  style: TextStyle(color: red),
                ),
              ],
            ),
          ),
          AppSpacing.vMedium(),
          // Подзаголовок с иконкой между частями текста
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (subtitleBeforeIcon.isNotEmpty)
                Text(
                  subtitleBeforeIcon,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    icon,
                    size: iconSize ?? subtitleFontSize + 2,
                    color: red,
                  ),
                ),
              if (subtitleAfterIcon.isNotEmpty)
                Text(
                  subtitleAfterIcon,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
