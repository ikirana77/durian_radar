import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../../shared/widgets/durian_report_card.dart';
import '../../auth/screens/login_register_screen.dart';
import '../../home/screens/home_map_screen.dart';

class FreshListScreen extends StatelessWidget {
  const FreshListScreen({super.key});

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
                child: ListView(
                  children: const [
                    DurianReportCard(
                      stallName: 'Gerai Durian Bukit Rotan',
                      area: 'Bukit Rotan, Kuala Selangor',
                      variety: 'Musang King',
                      price: 'RM38/kg',
                      status: 'Masih Ada',
                      updatedTime: '12 min',
                      statusColor: AppColors.freshGreen,
                    ),
                    DurianReportCard(
                      stallName: 'Durian Tepi Jalan Assam Jawa',
                      area: 'Assam Jawa, Selangor',
                      variety: 'D24',
                      price: 'RM28/kg',
                      status: 'Stok Sikit',
                      updatedTime: '25 min',
                      statusColor: AppColors.warningYellow,
                    ),
                    DurianReportCard(
                      stallName: 'Warung Durian Bestari',
                      area: 'Puncak Alam',
                      variety: 'XO',
                      price: 'RM22/kg',
                      status: 'Dah Habis',
                      updatedTime: '1 jam',
                      statusColor: AppColors.soldOutRed,
                    ),
                    DurianReportCard(
                      stallName: 'Durian Kampung Fresh',
                      area: 'Kuala Selangor',
                      variety: 'Kampung',
                      price: 'RM15/kg',
                      status: 'Masih Ada',
                      updatedTime: '2 jam',
                      statusColor: AppColors.freshGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DurianBottomNav(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeMapScreen()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginRegisterScreen(),
              ),
            );
          }
        },
      ),
    );
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
