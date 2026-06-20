import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.durianGreen),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.helper),
        ],
      ),
    );
  }
}
