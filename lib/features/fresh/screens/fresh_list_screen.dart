import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../../shared/widgets/durian_report_card.dart';
import '../../durian/data/durian_report_store.dart';
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
  final TextEditingController _searchController = TextEditingController();

  DurianStockStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isSearchVisible = false;

  List<DurianReport> _filteredReports(List<DurianReport> sourceReports) {
    final query = _searchQuery.trim().toLowerCase();

    return sourceReports.where((report) {
      final matchesStatus =
          _selectedStatus == null || report.stockStatus == _selectedStatus;

      final searchableText = [
        report.id,
        report.markerLabel,
        report.stallName,
        report.area,
        report.variety,
        report.price,
        report.statusText,
        report.updatedTime,
      ].join(' ').toLowerCase();

      final matchesSearch = query.isEmpty || searchableText.contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _selectStatus(DurianStockStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;

      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DurianReport>>(
      valueListenable: durianReportStore,
      builder: (context, allReports, child) {
        final reports = _filteredReports(allReports);

        return Scaffold(
          backgroundColor: AppColors.creamBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FreshHeader(
                    isSearchVisible: _isSearchVisible,
                    onSearchPressed: _toggleSearch,
                    onResetPressed: _resetFilters,
                  ),
                  if (_isSearchVisible) ...[
                    const SizedBox(height: AppSpacing.m),
                    _FreshSearchBar(
                      controller: _searchController,
                      onChanged: _updateSearchQuery,
                      onClear: _clearSearch,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  _FreshFilterRow(
                    selectedStatus: _selectedStatus,
                    onStatusSelected: _selectStatus,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _FreshResultSummary(
                    totalCount: allReports.length,
                    filteredCount: reports.length,
                    hasActiveFilter:
                        _selectedStatus != null || _searchQuery.isNotEmpty,
                  ),
                  const SizedBox(height: AppSpacing.m),
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
      },
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
  const _FreshHeader({
    required this.isSearchVisible,
    required this.onSearchPressed,
    required this.onResetPressed,
  });

  final bool isSearchVisible;
  final VoidCallback onSearchPressed;
  final VoidCallback onResetPressed;

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
          onPressed: onSearchPressed,
          icon: Icon(
            isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
          ),
          color: AppColors.durianGreen,
        ),
        IconButton(
          onPressed: onResetPressed,
          icon: const Icon(Icons.restart_alt_rounded),
          color: AppColors.durianGreen,
        ),
      ],
    );
  }
}

class _FreshSearchBar extends StatelessWidget {
  const _FreshSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEEDFBF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari gerai, kawasan, jenis durian atau harga...',
              hintStyle: const TextStyle(
                color: Color(0xFF8A9087),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.durianGreen,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.durianGreen,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
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

class _FreshResultSummary extends StatelessWidget {
  const _FreshResultSummary({
    required this.totalCount,
    required this.filteredCount,
    required this.hasActiveFilter,
  });

  final int totalCount;
  final int filteredCount;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    final text = hasActiveFilter
        ? '$filteredCount daripada $totalCount laporan dijumpai'
        : '$totalCount laporan fresh tersedia';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDFBF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.list_alt_rounded,
            color: AppColors.durianGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6D756B),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
              'Cuba pilih kata carian atau filter yang lain.',
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
