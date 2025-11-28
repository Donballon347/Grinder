import 'package:flutter/material.dart';

/// Базовая палитра бренда для централизованного использования по всему приложению.
/// Все значения заданы как константы, чтобы их легко было переиспользовать
/// и при необходимости менять в одном месте.
class AppColors {
  AppColors._();

  // Брендовые
  static const Color primary = Color(0xFF9A0101); // red 800 близко к used shade
  static const Color primaryDark = Color(0xFF8E0000);
  static const Color accent = Color(0xFFEF5350); // red 400

  // Поверхности
  static const Color background = Colors.white;
  static const Color surface = Colors.white;

  // Текст
  static const Color textPrimary = Colors.black;
  static final Color textSecondary = Color(0xFF626262);
  static final Color textTertiary = Colors.black.withValues(alpha: 0.55);

  // ========== ТЕКСТОВЫЕ СТИЛИ ==========
  static const double defaultFontSize = 15;
  static const double smallFontSize = 13;

  static final TextStyle textMain = TextStyle(
    color: textPrimary,
    fontWeight: FontWeight.w400,
    fontSize: defaultFontSize,
  );
  static final TextStyle textSmall = TextStyle(
    color: textPrimary,
    fontWeight: FontWeight.w400,
    fontSize: smallFontSize,
  );
  static final TextStyle textMainSecondary = TextStyle(
    color: textSecondary,
    fontWeight: FontWeight.w400,
    fontSize: defaultFontSize,
  );

  // Состояния
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);

  // Прочее
  static final Color divider = Colors.black.withValues(alpha: 0.08);
  static final Color shadow = Colors.black.withValues(alpha: 0.1);

  // Навигация
  static const Color navUnselected = Color(0xFF626262);
  static const Color navSeparator = Color(0xFFDCDCDC);

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
    elevation: 0,
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.white,
    ),
  );
  static const TextStyle primaryButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: Colors.white,
  );
}
