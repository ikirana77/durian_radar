import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../../shared/widgets/durian_report_card.dart';
import '../../durian/data/dummy_durian_reports.dart';
import '../../durian/models/durian_report.dart';
import '../../home/screens/home_map_screen.dart';
import '../../profile/screens/profile_screen.dart';

class FreshListScreen extends StatefulWidget {
  const FreshListScreen({super.key, this.showBottomNavigationBar = true});

  final bool showBottomNavigationBar;

  @override
  State<FreshListScreen> createState() => _FreshListScreenState();
}

class _FreshListScreenState extends State<FreshListScreen> {
  DurianStockStatus? _selectedStatus;

  List<DurianReport> get _filteredReports {
    if (_selectedStatus == null) {
      return dummyDurianReports;
    }

    return dummyDurianReports
        .where((report) => report.stockStatus == _selectedStatus)
        .toList();
  }

  void _selectStatus(DurianStockStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reports = _filteredReports;

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
              _FreshFilterRow(
                selectedStatus: _selectedStatus,
                onStatusSelected: _selectStatus,
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: reports.isEmpty
                    ? const _EmptyFreshState()
                    : ListView.separated(
                        itemCount: reports.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: AppSpacing.s);
                        },
                        itemBuilder: (context, index) {
                          final report = reports[index];

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
      bottomNavigationBar: widget.showBottomNavigationBar
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
  const _FreshFilterRow({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final DurianStockStatus? selectedStatus;
  final ValueChanged<DurianStockStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FreshStatusChip(
                  label: 'Semua',
                  icon: Icons.grid_view_rounded,
                  selected: selectedStatus == null,
                  onTap: () => onStatusSelected(null),
                ),
                const SizedBox(width: 8),
                _FreshStatusChip(
                  label: 'Ada',
                  icon: Icons.check_circle_rounded,
                  selected: selectedStatus == DurianStockStatus.available,
                  onTap: () => onStatusSelected(DurianStockStatus.available),
                ),
                const SizedBox(width: 8),
                _FreshStatusChip(
                  label: 'Sikit',
                  icon: Icons.warning_amber_rounded,
                  selected: selectedStatus == DurianStockStatus.lowStock,
                  onTap: () => onStatusSelected(DurianStockStatus.lowStock),
                ),
                const SizedBox(width: 8),
                _FreshStatusChip(
                  label: 'Habis',
                  icon: Icons.cancel_rounded,
                  selected: selectedStatus == DurianStockStatus.soldOut,
                  onTap: () => onStatusSelected(DurianStockStatus.soldOut),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FreshStatusChip extends StatelessWidget {
  const _FreshStatusChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? AppColors.durianGreen
        : AppColors.creamBackground;
    final foregroundColor = selected ? Colors.white : AppColors.durianGreen;
    final borderColor = selected
        ? AppColors.durianGreen
        : const Color(0xFFEEDFBF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: foregroundColor),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFreshState extends StatelessWidget {
  const _EmptyFreshState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEDFBF)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.durianGreen,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'Tiada laporan dijumpai',
              style: TextStyle(
                color: AppColors.durianGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Cuba pilih filter yang lain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6D756B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
