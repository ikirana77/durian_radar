import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../core/services/report_service.dart';

import '../../admin/screens/admin_review_screen.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../pin_detail/screens/pin_detail_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../reports/screens/add_report_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  late Future<List<DurianReportSummary>> _reportsFuture;

  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  bool _isLocating = false;
  String _selectedFilter = 'fresh';

  static const LatLng _defaultMapCenter = LatLng(3.3400, 101.2500);

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

  Future<void> _refreshReports() async {
    setState(() {
      _loadReports();
    });

    await _reportsFuture;
  }

  Future<void> _centerToCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) {
        return;
      }

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location service belum aktif. Sila aktifkan GPS/location.',
            ),
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (!mounted) {
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!mounted) {
          return;
        }
      }

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permission lokasi tidak dibenarkan. Sila allow location untuk center map.',
            ),
          ),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permission lokasi disekat. Sila buka Settings dan benarkan location permission.',
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) {
        return;
      }

      final userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = userLocation;
      });

      _mapController.move(userLocation, 15);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map dicenterkan ke lokasi semasa.')),
      );
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'GPS mengambil masa terlalu lama. Cuba semula di kawasan terbuka.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendapatkan lokasi semasa. Sila cuba lagi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _openAddReportScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReportScreen()),
    );

    if (!mounted) {
      return;
    }

    await _refreshReports();
  }

  Future<void> _openAdminReviewScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminReviewScreen()),
    );

    if (!mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    await _refreshReports();
  }

  Future<void> _openFreshListScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FreshListScreen()),
    );

    if (!mounted) {
      return;
    }

    await _refreshReports();
  }

  List<DurianReportSummary> _filterReports(List<DurianReportSummary> reports) {
    switch (_selectedFilter) {
      case 'available':
        return reports
            .where((report) => report.stockStatus == 'available')
            .toList(growable: false);
      case 'cheap':
        return reports
            .where((report) => _extractPriceValue(report.price) <= 25)
            .toList(growable: false);
      case 'fresh':
      default:
        return reports;
    }
  }

  double _extractPriceValue(String priceText) {
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(priceText);

    if (match == null) {
      return double.infinity;
    }

    return double.tryParse(match.group(0) ?? '') ?? double.infinity;
  }

  void _selectFilter(String filter) {
    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DRColors.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<List<DurianReportSummary>>(
              key: ValueKey('map-area-'),
              future: _reportsFuture,
              builder: (context, snapshot) {
                final reports = snapshot.data ?? const <DurianReportSummary>[];
                final filteredReports = _filterReports(reports);

                return _IllustratedMapArea(
                  mapController: _mapController,
                  reports: filteredReports,
                  currentLocation: _currentLocation,
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                );
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _HomeTopPanel(
                onAdminTap: _openAdminReviewScreen,
                selectedFilter: _selectedFilter,
                onFilterSelected: _selectFilter,
              ),
            ),
          ),

          Positioned(
            right: 22,
            bottom: 150,
            child: _LocateButton(
              isLocating: _isLocating,
              onTap: _centerToCurrentLocation,
            ),
          ),

          Positioned(
            left: 18,
            right: 16,
            bottom: 46,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FutureBuilder<List<DurianReportSummary>>(
                    key: ValueKey('home-summary-card'),
                    future: _reportsFuture,
                    builder: (context, snapshot) {
                      final reports =
                          snapshot.data ?? const <DurianReportSummary>[];
                      final filteredReports = _filterReports(reports);

                      return _FloatingSummaryCard(
                        reports: filteredReports,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        hasError: snapshot.hasError,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _ReportFab(
                  onTap: () {
                    _openAddReportScreen();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _HomeBottomBar(
        onFreshTap: _openFreshListScreen,
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
}

class _DRAssets {
  static const String durianLogo = 'assets/images/durian_logo.png';
  static const String durianFull = 'assets/images/durian_full.png';
}

class _HomeTopPanel extends StatelessWidget {
  const _HomeTopPanel({
    required this.onAdminTap,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final VoidCallback onAdminTap;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

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
                  maxLines: 2,
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
                onTap: onAdminTap,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _DRColors.durianGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _QuickChipRow(
            selectedFilter: selectedFilter,
            onSelected: onFilterSelected,
          ),
        ],
      ),
    );
  }
}

class _QuickChipRow extends StatelessWidget {
  const _QuickChipRow({required this.selectedFilter, required this.onSelected});

  final String selectedFilter;
  final ValueChanged<String> onSelected;

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
              child: _QuickChip(
                label: 'Fresh',
                icon: Icons.eco_rounded,
                iconColor: _DRColors.freshGreen,
                selected: selectedFilter == 'fresh',
                onTap: () {
                  onSelected('fresh');
                },
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: stockWidth,
              child: _QuickChip(
                label: 'Masih Ada',
                icon: Icons.calendar_month_rounded,
                iconColor: _DRColors.warningYellow,
                selected: selectedFilter == 'available',
                onTap: () {
                  onSelected('available');
                },
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: cheapWidth,
              child: _QuickChip(
                label: 'Murah',
                icon: Icons.sell_rounded,
                iconColor: _DRColors.warningYellow,
                selected: selectedFilter == 'cheap',
                onTap: () {
                  onSelected('cheap');
                },
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: selected ? _DRColors.paleGreen : _DRColors.creamSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? _DRColors.durianGreen : _DRColors.borderSoft,
              width: selected ? 1.7 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? 0.10 : 0.07),
                blurRadius: selected ? 12 : 10,
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
                decoration: BoxDecoration(
                  color: selected ? _DRColors.durianGreen : iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected
                          ? _DRColors.durianGreen
                          : _DRColors.durianGreen,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustratedMapArea extends StatelessWidget {
  const _IllustratedMapArea({
    required this.mapController,
    required this.reports,
    required this.currentLocation,
    required this.isLoading,
  });

  final MapController mapController;
  final List<DurianReportSummary> reports;
  final LatLng? currentLocation;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final validReports = reports
        .where((report) => report.latitude != 0 && report.longitude != 0)
        .toList(growable: false);

    final mapCenter =
        currentLocation ??
        (validReports.isNotEmpty
            ? LatLng(validReports.first.latitude, validReports.first.longitude)
            : _HomeMapScreenState._defaultMapCenter);

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: validReports.isNotEmpty ? 13 : 12,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.durian_radar',
            ),
            MarkerLayer(
              markers: [
                for (final report in validReports)
                  Marker(
                    point: LatLng(report.latitude, report.longitude),
                    width: 64,
                    height: 72,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PinDetailScreen(report: report),
                          ),
                        );
                      },
                      child: _MapMarker(
                        label: report.markerLabel,
                        color: _markerColor(report.stockStatus),
                        hasPhoto: report.photoUrl.trim().isNotEmpty,
                      ),
                    ),
                  ),
                if (currentLocation != null)
                  Marker(
                    point: currentLocation!,
                    width: 74,
                    height: 74,
                    child: const _UserLocationMarker(),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 18,
          right: 18,
          top: 262,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.centerLeft,
              child: isLoading
                  ? const _MapStatusPill(label: 'Memuatkan pin Supabase...')
                  : currentLocation == null
                  ? const _MapStatusPill(
                      label: 'Tekan butang lokasi untuk center map',
                    )
                  : const _MapStatusPill(label: 'Map sekitar lokasi anda'),
            ),
          ),
        ),
      ],
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

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: _DRColors.durianGreen.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _DRColors.durianGreen,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
      ],
    );
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _DRColors.borderSoft),
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
          if (label.contains('Memuatkan')) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _DRColors.durianGreen,
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: _DRColors.durianGreen,
            ),
            const SizedBox(width: 8),
          ],
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
  const _MapMarker({
    required this.label,
    required this.color,
    required this.hasPhoto,
  });

  final String label;
  final Color color;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final bool longLabel = label.length > 3;
    final Color labelColor = color.computeLuminance() > 0.55
        ? _DRColors.textDark
        : Colors.white;

    return SizedBox(
      width: 60,
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 1,
            child: CustomPaint(
              size: const Size(52, 62),
              painter: _SlimTeardropPainter(color: color),
            ),
          ),
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: labelColor,
                fontSize: longLabel ? 10.5 : 12.8,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.25,
              ),
            ),
          ),
          if (hasPhoto)
            Positioned(
              right: 7,
              top: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _DRColors.cardWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _DRColors.durianGreen.withValues(alpha: 0.85),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: _DRColors.durianGreen,
                  size: 10.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlimTeardropPainter extends CustomPainter {
  const _SlimTeardropPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.50, size.height * 0.96)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.67,
        size.width * 0.08,
        size.height * 0.42,
        size.width * 0.12,
        size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.05,
        size.width * 0.34,
        size.height * 0.00,
        size.width * 0.50,
        size.height * 0.00,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.00,
        size.width * 0.82,
        size.height * 0.05,
        size.width * 0.88,
        size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.42,
        size.width * 0.82,
        size.height * 0.67,
        size.width * 0.50,
        size.height * 0.96,
      )
      ..close();

    canvas.drawShadow(
      path.shift(const Offset(0, 2)),
      Colors.black.withValues(alpha: 0.28),
      4,
      true,
    );

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, outlinePaint);
    canvas.drawPath(path, fillPaint);

    final gloss = Path()
      ..moveTo(size.width * 0.28, size.height * 0.18)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.07,
        size.width * 0.55,
        size.height * 0.07,
        size.width * 0.66,
        size.height * 0.15,
      )
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.13,
        size.width * 0.38,
        size.height * 0.18,
        size.width * 0.28,
        size.height * 0.32,
      )
      ..close();

    canvas.drawPath(gloss, glossPaint);
  }

  @override
  bool shouldRepaint(covariant _SlimTeardropPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton({required this.isLocating, required this.onTap});

  final bool isLocating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLocating ? null : onTap,
        child: Container(
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
          child: isLocating
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _DRColors.durianGreen,
                  ),
                )
              : const Icon(
                  Icons.my_location_rounded,
                  color: _DRColors.durianGreen,
                  size: 31,
                ),
        ),
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
        : '$totalReports lokasi aktif di Durian Radar';

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
                          fontSize: 10,
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
      width: 88,
      height: 90,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _DRColors.durianYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DRColors.creamSoft, width: 6),
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
                  size: 40,
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
                'Laporkan',
                maxLines: 1,
                style: TextStyle(
                  color: _DRColors.textDark,
                  fontSize: 10,
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
