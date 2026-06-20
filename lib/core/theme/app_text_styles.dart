import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const appTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.durianGreen,
  );

  static const pageTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.durianGreen,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.durianGreen,
  );

  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textCharcoal,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textCharcoal,
  );

  static const helper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.mutedText,
  );

  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}
