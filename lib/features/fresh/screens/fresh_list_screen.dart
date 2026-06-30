import 'package:flutter/material.dart';

import '../../../core/services/report_service.dart';
import '../../profile/screens/profile_screen.dart';
import '../../reports/screens/add_report_screen.dart';

class FreshListScreen extends StatefulWidget {
  const FreshListScreen({super.key});

  @override
  State<FreshListScreen> createState() => _FreshListScreenState();
}

class _FreshListScreenState extends State<FreshListScreen> {
  late Future<List<DurianReportSummary>> _reportsFuture;

  static const Color _cream = Color(0xFFFFFAEC);
  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _yellow = Color(0xFFFFC857);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = ReportService.fetchLatestReports(
      approvedOnly: false,
      limit: 30,
    );
  }

  Future<void> _refreshReports() async {
    setState(_loadReports);
    await _reportsFuture;
  }

  Future<void> _openAddReportScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddReportScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(_loadReports);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Fresh List',
          style: TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.person_rounded,
              color: _green,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddReportScreen,
        backgroundColor: _yellow,
        foregroundColor: _darkGreen,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Laporkan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<DurianReportSummary>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: ReportService.getReadableError(snapshot.error!),
                onRetry: () {
                  setState(_loadReports);
                },
              );
            }

            final reports = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: _refreshReports,
              color: _green,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeaderCard(
                      totalReports: reports.length,
                    ),
                  ),
                  if (reports.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyView(
                        onAddReport: _openAddReportScreen,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                      sliver: SliverList.separated(
                        itemCount: reports.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final report = reports[index];

                          return _FreshReportCard(
                            report: report,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.totalReports,
  });

  final int totalReports;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _yellow = Color(0xFFFFC857);
  static const Color _textMuted = Color(0xFF6F776F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFE8DEC3),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(47, 107, 63, 0.10),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: _darkGreen,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Durian paling fresh sekitar anda',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    totalReports == 0
                        ? 'Belum ada laporan untuk dipaparkan.'
                        : '$totalReports laporan dimuatkan daripada Supabase.',
                    style: const TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.cloud_done_rounded,
              color: _green,
            ),
          ],
        ),
      ),
    );
  }
}

class _FreshReportCard extends StatelessWidget {
  const _FreshReportCard({
    required this.report,
  });

  final DurianReportSummary report;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _softGreen = Color(0xFFEAF5E6);
  static const Color _softYellow = Color(0xFFFFF3C4);
  static const Color _softRed = Color(0xFFFFE6E2);
  static const Color _textMuted = Color(0xFF6F776F);

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(report.stockStatus);
    final approvalText = report.isApproved ? 'Disahkan' : 'Menunggu semakan';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8DEC3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(47, 107, 63, 0.08),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MarkerBadge(
            label: report.markerLabel,
            backgroundColor: statusStyle.backgroundColor,
            foregroundColor: statusStyle.foregroundColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.stallName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: _textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniChip(
                      icon: Icons.eco_rounded,
                      label: report.variety,
                      backgroundColor: _softGreen,
                      foregroundColor: _green,
                    ),
                    _MiniChip(
                      icon: Icons.payments_rounded,
                      label: report.price,
                      backgroundColor: _softYellow,
                      foregroundColor: _darkGreen,
                    ),
                    _MiniChip(
                      icon: Icons.circle_rounded,
                      label: report.statusText,
                      backgroundColor: statusStyle.backgroundColor,
                      foregroundColor: statusStyle.foregroundColor,
                    ),
                  ],
                ),
                if (report.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    report.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      report.isApproved
                          ? Icons.verified_rounded
                          : Icons.hourglass_top_rounded,
                      size: 16,
                      color: report.isApproved ? _green : Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      approvalText,
                      style: TextStyle(
                        color: report.isApproved ? _green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.update_rounded,
                      size: 16,
                      color: _textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      report.updatedTime,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String stockStatus) {
    switch (stockStatus) {
      case 'available':
        return const _StatusStyle(
          backgroundColor: _softGreen,
          foregroundColor: _green,
        );
      case 'low_stock':
        return const _StatusStyle(
          backgroundColor: _softYellow,
          foregroundColor: _darkGreen,
        );
      case 'sold_out':
        return const _StatusStyle(
          backgroundColor: _softRed,
          foregroundColor: Colors.red,
        );
      default:
        return const _StatusStyle(
          backgroundColor: _softGreen,
          foregroundColor: _green,
        );
    }
  }
}

class _MarkerBadge extends StatelessWidget {
  const _MarkerBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: foregroundColor,
          width: 1.4,
        ),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: foregroundColor,
            fontSize: label.length > 3 ? 12 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: _green,
          ),
          SizedBox(height: 14),
          Text(
            'Memuatkan laporan durian...',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8DEC3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Laporan gagal dimuatkan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6F776F),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Cuba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.onAddReport,
  });

  final VoidCallback onAddReport;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _yellow = Color(0xFFFFC857);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFE8DEC3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: _darkGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada laporan fresh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hantar laporan pertama supaya komuniti boleh tahu lokasi durian terkini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6F776F),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAddReport,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                ),
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text(
                  'Laporkan Durian',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

