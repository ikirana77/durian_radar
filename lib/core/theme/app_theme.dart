import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.durianGreen,
        primary: AppColors.durianGreen,
        secondary: AppColors.durianYellow,
        surface: AppColors.softCardWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creamBackground,
        foregroundColor: AppColors.durianGreen,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.sectionTitle,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.durianYellow,
        foregroundColor: AppColors.textCharcoal,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.durianGreen,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
