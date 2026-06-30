import 'package:flutter/material.dart';

import '../../../core/services/report_service.dart';

import '../../admin/screens/admin_review_screen.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../reports/screens/add_report_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  late Future<List<DurianReportSummary>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = ReportService.fetchLatestReports(
      approvedOnly: true,
      limit: 30,
    );
  }

  Future<void> _openAddReportScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReportScreen(),
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
      backgroundColor: _DRColors.cream,
      body: Stack(
        children: [
                    Positioned.fill(
            child: FutureBuilder<List<DurianReportSummary>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                return _IllustratedMapArea(
                  reports: snapshot.data ?? const [],
                  isLoading: snapshot.connectionState ==
                      ConnectionState.waiting,
                );
              },
            ),
          ),

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(bottom: false, child: _HomeTopPanel()),
          ),

          const Positioned(right: 22, bottom: 150, child: _LocateButton()),

          Positioned(
            left: 28,
            bottom: 46,
            child: SizedBox(
              width: 270,
              child: FutureBuilder<List<DurianReportSummary>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  return _FloatingSummaryCard(
                    reports: snapshot.data ?? const [],
                    isLoading: snapshot.connectionState ==
                        ConnectionState.waiting,
                    hasError: snapshot.hasError,
                  );
                },
              ),
            ),
          ),

          Positioned(
            right: 18,
            bottom: 42,
            child: _ReportFab(
              onTap: () {
                _openAddReportScreen();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _HomeBottomBar(
        onFreshTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FreshListScreen()),
          );
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    );
  }
}

class _DRColors {
  static const Color cream = Color(0xFFFFF7E8);
  static const Color creamSoft = Color(0xFFFFFBF1);
  static const Color cardWhite = Color(0xFFFFFEF8);

  static const Color durianGreen = Color(0xFF1F6B3A);
  static const Color freshGreen = Color(0xFF5FAE43);
  static const Color paleGreen = Color(0xFFEAF6D9);

  static const Color durianYellow = Color(0xFFFFC72C);
  static const Color warningYellow = Color(0xFFF4B000);
  static const Color soldOutRed = Color(0xFFE83A2F);

  static const Color textDark = Color(0xFF173D25);
  static const Color textMuted = Color(0xFF6D756B);

  static const Color borderSoft = Color(0xFFEEDFBF);

  static const Color mapBase = Color(0xFFF3EBD8);
  static const Color mapRiver = Color(0xFFBFE3EA);
  static const Color mapGreen = Color(0xFFDCECCE);
  static const Color mapRoadYellow = Color(0xFFFFD97A);
}

class _DRAssets {
  static const String durianLogo = 'assets/images/durian_logo.png';
  static const String durianFull = 'assets/images/durian_full.png';
}

class _HomeTopPanel extends StatelessWidget {
  const _HomeTopPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
      decoration: BoxDecoration(
        color: _DRColors.creamSoft.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Image.asset(_DRAssets.durianLogo, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Durian Radar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: _DRColors.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              _IconCircle(
                icon: Icons.admin_panel_settings_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminReviewScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _IconCircle(
                icon: Icons.person_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: _DRColors.durianGreen,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Sekitar Kuala Selangor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _DRColors.durianGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _QuickChipRow(),
        ],
      ),
    );
  }
}

class _QuickChipRow extends StatelessWidget {
  const _QuickChipRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final maxWidth = constraints.maxWidth;

        if (maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        final availableWidth = (maxWidth - (gap * 2)).clamp(
          0.0,
          double.infinity,
        );

        final freshWidth = availableWidth * 0.30;
        final stockWidth = availableWidth * 0.40;
        final cheapWidth = availableWidth * 0.30;

        return Row(
          children: [
            SizedBox(
              width: freshWidth,
              child: const _QuickChip(
                label: 'Fresh',
                icon: Icons.eco_rounded,
                iconColor: _DRColors.freshGreen,
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: stockWidth,
              child: const _QuickChip(
                label: 'Masih Ada',
                icon: Icons.calendar_month_rounded,
                iconColor: _DRColors.warningYellow,
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: cheapWidth,
              child: const _QuickChip(
                label: 'Murah',
                icon: Icons.sell_rounded,
                iconColor: _DRColors.warningYellow,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DRColors.cardWhite,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: _DRColors.durianGreen, size: 27),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: _DRColors.creamSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _DRColors.borderSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: _DRColors.durianGreen,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustratedMapArea extends StatelessWidget {
  const _IllustratedMapArea({
    required this.reports,
    required this.isLoading,
  });

  final List<DurianReportSummary> reports;
  final bool isLoading;

  static const List<Offset> _markerAnchors = [
    Offset(0.55, 0.32),
    Offset(0.25, 0.43),
    Offset(0.72, 0.49),
    Offset(0.49, 0.60),
    Offset(0.38, 0.36),
    Offset(0.62, 0.68),
    Offset(0.18, 0.55),
    Offset(0.80, 0.37),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DRColors.mapBase,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final visibleReports = reports
              .take(_markerAnchors.length)
              .toList(growable: false);

          return Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _SoftMapPainter()),
              ),
              if (isLoading)
                Positioned(
                  top: (height * 0.46).clamp(210.0, height - 180).toDouble(),
                  left: (width * 0.22).clamp(18.0, width - 210).toDouble(),
                  child: const _MapStatusPill(
                    label: 'Memuatkan pin Supabase...',
                  ),
                ),
              for (int index = 0; index < visibleReports.length; index++)
                _buildReportMarker(
                  report: visibleReports[index],
                  index: index,
                  width: width,
                  height: height,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportMarker({
    required DurianReportSummary report,
    required int index,
    required double width,
    required double height,
  }) {
    final anchor = _markerAnchors[index % _markerAnchors.length];

    final left = (width * anchor.dx).clamp(12.0, width - 90).toDouble();
    final top = (height * anchor.dy).clamp(210.0, height - 180).toDouble();

    return Positioned(
      top: top,
      left: left,
      child: _MapMarker(
        label: report.markerLabel,
        color: _markerColor(report.stockStatus),
      ),
    );
  }

  Color _markerColor(String stockStatus) {
    switch (stockStatus) {
      case 'available':
        return _DRColors.freshGreen;
      case 'low_stock':
        return _DRColors.warningYellow;
      case 'sold_out':
        return _DRColors.soldOutRed;
      default:
        return _DRColors.freshGreen;
    }
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _DRColors.borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _DRColors.durianGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _DRColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool longLabel = label.length > 3;

    return SizedBox(
      width: 78,
      height: 84,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 8,
            child: Icon(
              Icons.location_on_rounded,
              size: 70,
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
          const Positioned(
            top: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 74,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 4,
            child: Icon(Icons.location_on_rounded, size: 66, color: color),
          ),
          Positioned(
            top: 24,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: longLabel ? 13 : 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _DRColors.cardWhite,
        shape: BoxShape.circle,
        border: Border.all(color: _DRColors.borderSoft, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.my_location_rounded,
        color: _DRColors.durianGreen,
        size: 31,
      ),
    );
  }
}

class _FloatingSummaryCard extends StatelessWidget {
  const _FloatingSummaryCard({
    required this.reports,
    required this.isLoading,
    required this.hasError,
  });

  final List<DurianReportSummary> reports;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final totalReports = reports.length;
    final latestUpdate = reports.isEmpty ? null : reports.first.updatedTime;

    final title = isLoading
        ? 'Memuatkan laporan...'
        : hasError
            ? 'Laporan belum dimuat'
            : totalReports == 0
                ? 'Belum ada lokasi fresh'
                : '$totalReports lokasi dari Supabase';

    final subtitle = isLoading
        ? 'Sedang sambung ke database'
        : hasError
            ? 'Buka Fresh List untuk cuba semula'
            : totalReports == 0
                ? 'Tekan + untuk laporan pertama'
                : 'Data live daripada Fresh List';

    final updateText = isLoading
        ? 'Menyemak data terkini...'
        : hasError
            ? 'Ada isu sambungan data'
            : latestUpdate == null
                ? 'Menunggu laporan komuniti'
                : 'Update terbaru: $latestUpdate';

    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: _DRColors.paleGreen,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(_DRAssets.durianFull, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DRColors.durianGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DRColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: hasError
                          ? _DRColors.soldOutRed
                          : _DRColors.freshGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        updateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _DRColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
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
}

class _ReportFab extends StatelessWidget {
  const _ReportFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 108,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: _DRColors.durianYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DRColors.creamSoft, width: 7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: _DRColors.textDark,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _DRColors.creamSoft.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Laporkan Durian',
                maxLines: 1,
                style: TextStyle(
                  color: _DRColors.textDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({required this.onFreshTap, required this.onProfileTap});

  final VoidCallback onFreshTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 34),
        decoration: BoxDecoration(
          color: _DRColors.creamSoft,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _BottomNavItem(
              icon: Icons.map_rounded,
              label: 'Map',
              selected: true,
            ),
            _BottomNavItem(
              icon: Icons.eco_outlined,
              label: 'Fresh',
              selected: false,
              onTap: onFreshTap,
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Saya',
              selected: false,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _DRColors.durianGreen : const Color(0xFF2E302E);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 34 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: _DRColors.durianGreen,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftMapPainter extends CustomPainter {
  const _SoftMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _DRColors.mapBase);

    final greenPaint = Paint()
      ..color = _DRColors.mapGreen.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.80, size.height * 0.20, 130, 170),
      greenPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.52, 90, 140),
      greenPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.66, size.height * 0.63, 150, 120),
      greenPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.25, 86, 70),
      greenPaint,
    );

    final riverPaint = Paint()
      ..color = _DRColors.mapRiver
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverLeft = Path()
      ..moveTo(-20, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.10,
        size.height * 0.46,
        size.width * 0.03,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.00,
        size.height * 0.84,
        size.width * 0.12,
        size.height + 30,
      );

    final riverBottom = Path()
      ..moveTo(size.width * 0.10, size.height * 0.86)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.77,
        size.width * 0.58,
        size.height * 0.90,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height,
        size.width + 30,
        size.height * 0.84,
      );

    canvas.drawPath(riverLeft, riverPaint);
    canvas.drawPath(riverBottom, riverPaint);

    _drawMajorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.02, size.height * 0.31)
        ..quadraticBezierTo(
          size.width * 0.36,
          size.height * 0.20,
          size.width * 0.74,
          size.height * 0.36,
        )
        ..quadraticBezierTo(
          size.width * 0.90,
          size.height * 0.42,
          size.width * 1.06,
          size.height * 0.39,
        ),
    );

    _drawMajorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.46, -20)
        ..quadraticBezierTo(
          size.width * 0.48,
          size.height * 0.28,
          size.width * 0.43,
          size.height * 0.50,
        )
        ..quadraticBezierTo(
          size.width * 0.39,
          size.height * 0.70,
          size.width * 0.50,
          size.height + 30,
        ),
    );

    _drawMajorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.18, size.height * 1.02)
        ..quadraticBezierTo(
          size.width * 0.42,
          size.height * 0.74,
          size.width * 0.60,
          size.height * 0.58,
        )
        ..quadraticBezierTo(
          size.width * 0.77,
          size.height * 0.42,
          size.width * 0.88,
          size.height * 0.06,
        ),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.05, size.height * 0.44)
        ..lineTo(size.width * 0.92, size.height * 0.30),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.58)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.48,
          size.width * 0.90,
          size.height * 0.55,
        ),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.20, size.height * 0.25)
        ..quadraticBezierTo(
          size.width * 0.38,
          size.height * 0.43,
          size.width * 0.70,
          size.height * 0.70,
        ),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.14, size.height * 0.70)
        ..lineTo(size.width * 0.86, size.height * 0.72),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.70, size.height * 0.18)
        ..lineTo(size.width * 0.55, size.height * 0.82),
    );

    _drawText(
      canvas,
      'KUALA\nSELANGOR',
      Offset(size.width * 0.27, size.height * 0.28),
      size: 15,
      weight: FontWeight.w800,
    );

    _drawText(
      canvas,
      'Taman\nMelawati',
      Offset(size.width * 0.54, size.height * 0.26),
      size: 11,
    );

    _drawText(
      canvas,
      'Kampung\nBukit Rotan',
      Offset(size.width * 0.45, size.height * 0.46),
      size: 11,
    );

    _drawText(
      canvas,
      'Bestari\nJaya',
      Offset(size.width * 0.83, size.height * 0.59),
      size: 11,
    );

    _drawText(
      canvas,
      'Sungai\nSelangor',
      Offset(size.width * 0.08, size.height * 0.66),
      size: 10,
      color: const Color(0xFF438BA0),
    );

    _drawRouteLabel(
      canvas,
      'B18',
      Offset(size.width * 0.46, size.height * 0.22),
    );

    _drawRouteLabel(
      canvas,
      'AH2',
      Offset(size.width * 0.76, size.height * 0.36),
      blue: true,
    );
  }

  void _drawMajorRoad(Canvas canvas, Path path) {
    final outerPaint = Paint()
      ..color = _DRColors.mapRoadYellow
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final innerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, innerPaint);
  }

  void _drawMinorRoad(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.62)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double size = 12,
    Color color = const Color(0xFF7B817B),
    FontWeight weight = FontWeight.w600,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          height: 1.1,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    textPainter.paint(canvas, offset);
  }

  void _drawRouteLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    bool blue = false,
  }) {
    final rect = Rect.fromLTWH(offset.dx, offset.dy, 28, 16);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    final paint = Paint()
      ..color = blue ? const Color(0xFF3D8ADB) : const Color(0xFFFFD34F);

    canvas.drawRRect(rrect, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        offset.dx + (28 - textPainter.width) / 2,
        offset.dy + (16 - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



