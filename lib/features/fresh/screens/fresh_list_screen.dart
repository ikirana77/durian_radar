import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../../shared/widgets/durian_report_card.dart';
import '../../home/screens/home_map_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../durian/data/dummy_durian_reports.dart';
import '../../durian/models/durian_report.dart';

class FreshListScreen extends StatelessWidget {
  const FreshListScreen({super.key, this.showBottomNavigationBar = true});

  final bool showBottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FreshHeader(),
              const SizedBox(height: AppSpacing.l),
              const _FreshFilterRow(),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: ListView.separated(
                  itemCount: dummyDurianReports.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: AppSpacing.s);
                  },
                  itemBuilder: (context, index) {
                    final report = dummyDurianReports[index];

                    return DurianReportCard(
                      stallName: report.stallName,
                      area: report.area,
                      variety: report.variety,
                      price: report.price,
                      status: report.statusText,
                      updatedTime: report.updatedTime,
                      statusColor: _statusColor(report.stockStatus),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showBottomNavigationBar
          ? DurianBottomNav(
              selectedIndex: 1,
              onDestinationSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeMapScreen(),
                    ),
                  );
                }

                if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
              },
            )
          : null,
    );
  }
}

Color _statusColor(DurianStockStatus status) {
  switch (status) {
    case DurianStockStatus.available:
      return AppColors.freshGreen;
    case DurianStockStatus.lowStock:
      return AppColors.warningYellow;
    case DurianStockStatus.soldOut:
      return AppColors.soldOutRed;
  }
}

class _FreshHeader extends StatelessWidget {
  const _FreshHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fresh Hari Ini', style: AppTextStyles.pageTitle),
              SizedBox(height: 4),
              Text(
                'Senarai laporan durian terkini',
                style: AppTextStyles.helper,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          color: AppColors.durianGreen,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune),
          color: AppColors.durianGreen,
        ),
      ],
    );
  }
}

class _FreshFilterRow extends StatelessWidget {
  const _FreshFilterRow();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppFilterChip(label: 'Semua', icon: Icons.grid_view),
          SizedBox(width: AppSpacing.s),
          AppFilterChip(label: 'Masih Ada', icon: Icons.check_circle),
          SizedBox(width: AppSpacing.s),
          AppFilterChip(label: 'Murah', icon: Icons.sell),
          SizedBox(width: AppSpacing.s),
          AppFilterChip(label: 'Dekat', icon: Icons.near_me),
        ],
      ),
    );
  }
}
