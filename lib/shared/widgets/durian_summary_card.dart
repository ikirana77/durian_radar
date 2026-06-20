import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class DurianSummaryCard extends StatelessWidget {
  const DurianSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _SummaryItem(number: '12', label: 'Fresh hari ini'),
          ),
          Expanded(
            child: _SummaryItem(number: 'RM28', label: 'Harga terendah'),
          ),
          Expanded(
            child: _SummaryItem(number: '8 min', label: 'Terbaru'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(child: Text(number, style: AppTextStyles.sectionTitle)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.helper.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
