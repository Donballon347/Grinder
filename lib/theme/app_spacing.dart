import 'package:flutter/material.dart';

/// Единая система отступов и адаптивный horizontal padding для всего приложения.
/// Адаптированный стиль и структура под AppColors.
class AppSpacing {
  AppSpacing._(); // Приватный конструктор для использования только статических членов

  /// Адаптивный горизонтальный отступ (обычно ~6% ширины экрана)
  static double horizontal(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.06;

  /// Горизонтальные EdgeInsets
  static EdgeInsets horizontalInsets(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: horizontal(context));

  // Вертикальные константы (можно настраивать под ваш гайдлайн)
  static const double tiny = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 28.0;
  static const double section = 40.0;

  /// Для вертикального пространства через SizedBox
  static SizedBox vTiny() => const SizedBox(height: tiny);
  static SizedBox vSmall() => const SizedBox(height: small);
  static SizedBox vMedium() => const SizedBox(height: medium);
  static SizedBox vLarge() => const SizedBox(height: large);
  static SizedBox vSection() => const SizedBox(height: section);

  /// Для горизонтального пространства через SizedBox
  static SizedBox hTiny() => const SizedBox(width: tiny);
  static SizedBox hSmall() => const SizedBox(width: small);
  static SizedBox hMedium() => const SizedBox(width: medium);
  static SizedBox hLarge() => const SizedBox(width: large);
  static SizedBox hSection() => const SizedBox(width: section);
}
