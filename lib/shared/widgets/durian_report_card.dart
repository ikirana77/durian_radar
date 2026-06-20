import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class DurianReportCard extends StatelessWidget {
  const DurianReportCard({
    super.key,
    required this.stallName,
    required this.area,
    required this.variety,
    required this.price,
    required this.status,
    required this.updatedTime,
    required this.statusColor,
  });

  final String stallName;
  final String area;
  final String variety;
  final String price;
  final String status;
  final String updatedTime;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 86,
            width: 86,
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.storefront,
              color: AppColors.durianGreen,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stallName, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(area, style: AppTextStyles.helper)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    _MiniInfo(icon: Icons.eco, text: variety),
                    const SizedBox(width: AppSpacing.s),
                    _MiniInfo(icon: Icons.sell, text: price),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.helper.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(updatedTime, style: AppTextStyles.helper),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.durianGreen),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.helper.copyWith(
                color: AppColors.textCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
