import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../core/services/favorite_service.dart';
import '../../../core/services/report_service.dart';
import '../../admin/screens/admin_review_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../pin_detail/screens/pin_detail_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../reports/screens/add_report_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

enum _HomeFilter { all, available, cheap }

class _HomeMapScreenState extends State<HomeMapScreen> {
  static const LatLng _defaultCenter = LatLng(3.1390, 101.6869);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<DurianReportSummary>> _reportsFuture;

  LatLng? _currentLocation;
  bool _isLocating = false;
  _HomeFilter _selectedFilter = _HomeFilter.all;
  Set<String> _favoriteKeys = <String>{};
  int _mapFilterRevision = 0;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadReports();
    _loadFavoriteKeys();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<DurianReportSummary>> _loadReports() async {
    return ReportService.fetchApprovedReports();
  }

  Future<void> _refreshReports() async {
    setState(() {
      _reportsFuture = _loadReports();
    });
    await _reportsFuture;
  }

  Future<void> _loadFavoriteKeys() async {
    final keys = await FavoriteService.fetchFavoriteKeys();

    if (!mounted) {
      return;
    }

    setState(() {
      _favoriteKeys = keys;
    });
  }

  bool _isFavorite(DurianReportSummary report) {
    return _favoriteKeys.contains(FavoriteService.keyForReport(report));
  }

  Future<void> _toggleFavorite(DurianReportSummary report) async {
    final isNowFavorite = await FavoriteService.toggleReport(report);

    if (!mounted) {
      return;
    }

    await _loadFavoriteKeys();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${report.stallName} ditambah ke Kegemaran.'
              : '${report.stallName} dibuang daripada Kegemaran.',
        ),
      ),
    );
  }

  Future<void> _openFavoritesScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );

    if (!mounted) {
      return;
    }

    await _loadFavoriteKeys();
  }

  Future<void> _openAddReportScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddReportScreen()),
    );

    if (!mounted) return;
    await _refreshReports();
  }

  Future<void> _openFreshListScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FreshListScreen()),
    );

    if (!mounted) return;
    await _refreshReports();
  }

  Future<void> _openAdminReviewScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminReviewScreen()),
    );

    if (!mounted) return;
    await _refreshReports();
  }

  Future<void> _openProfileScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  Future<void> _centerToCurrentLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;

      if (!serviceEnabled) {
        _showSnack('Location service belum aktif. Sila aktifkan GPS/location.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
      }

      if (permission == LocationPermission.denied) {
        _showSnack('Permission lokasi tidak dibenarkan.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnack('Permission lokasi disekat. Sila buka Settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = userLocation;
      });

      _mapController.move(userLocation, 14.5);
      _showSnack('Map dicenterkan ke lokasi semasa.');
    } on TimeoutException {
      if (!mounted) return;
      _showSnack('GPS mengambil masa terlalu lama. Cuba semula.');
    } catch (_) {
      if (!mounted) return;
      _showSnack('Gagal mendapatkan lokasi semasa.');
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(5.0, 18.0);
    _mapController.move(camera.center, newZoom);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<DurianReportSummary> _applyFilters(List<DurianReportSummary> reports) {
    final query = _searchController.text.trim().toLowerCase();

    var filtered = reports.where((report) {
      final matchesQuery =
          query.isEmpty ||
          report.stallName.toLowerCase().contains(query) ||
          report.area.toLowerCase().contains(query) ||
          report.variety.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      switch (_selectedFilter) {
        case _HomeFilter.available:
          return report.stockStatus == 'available';
        case _HomeFilter.cheap:
          return _parsePrice(report.price) <= 25;
        case _HomeFilter.all:
          return true;
      }
    }).toList();

    if (_currentLocation != null) {
      filtered.sort((a, b) {
        final distanceA = _distanceKm(a);
        final distanceB = _distanceKm(b);
        return distanceA.compareTo(distanceB);
      });
    }

    return filtered;
  }

  double _parsePrice(String raw) {
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(raw);
    if (match == null) return double.infinity;
    return double.tryParse(match.group(0) ?? '') ?? double.infinity;
  }

  double _distanceKm(DurianReportSummary report) {
    if (_currentLocation == null) return double.infinity;

    final meters = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      report.latitude,
      report.longitude,
    );

    return meters / 1000;
  }

  String _formatDistance(DurianReportSummary report) {
    final km = _distanceKm(report);
    if (km.isInfinite) return '—';
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
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

  String _stockLabel(String stockStatus) {
    switch (stockStatus) {
      case 'available':
        return 'Banyak';
      case 'low_stock':
        return 'Sederhana';
      case 'sold_out':
        return 'Hampir Habis';
      default:
        return 'Tersedia';
    }
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _DRColors.borderSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filter Peta Durian',
                    style: TextStyle(
                      color: _DRColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _BottomSheetFilterChip(
                      label: 'Semua',
                      selected: _selectedFilter == _HomeFilter.all,
                      onTap: () {
                        setState(() {
                          _selectedFilter = _HomeFilter.all;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _BottomSheetFilterChip(
                      label: 'Masih Ada',
                      selected: _selectedFilter == _HomeFilter.available,
                      onTap: () {
                        setState(() {
                          _selectedFilter = _HomeFilter.available;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _BottomSheetFilterChip(
                      label: 'Murah (≤ RM25/kg)',
                      selected: _selectedFilter == _HomeFilter.cheap,
                      onTap: () {
                        setState(() {
                          _selectedFilter = _HomeFilter.cheap;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showHowToUseSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _MenuInfoSheet(
          icon: Icons.help_outline_rounded,
          title: 'Cara Guna Durian Radar',
          bullets: [
            'Tekan Peta untuk lihat lokasi gerai durian aktif.',
            'Gunakan Fresh, Masih Ada dan Murah untuk tapis lokasi.',
            'Tekan pin pada peta untuk lihat butiran gerai.',
            'Tekan Lapor untuk hantar lokasi gerai durian baharu.',
            'Simpan gerai pilihan menggunakan ikon hati.',
          ],
        );
      },
    );
  }

  Future<void> _showAboutAppSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _MenuInfoSheet(
          icon: Icons.info_outline_rounded,
          title: 'Tentang Durian Radar',
          imageAsset: _DRAssets.developerTeam,
          bullets: [
            'Durian Radar membantu pengguna mencari gerai durian aktif.',
            'Data lokasi dikemas kini melalui laporan komuniti.',
            'Admin boleh menyemak dan mengesahkan laporan sebelum dipaparkan.',
            'Dibangunkan oleh: Mdm Intan, Nazlah, Hanum, Qausar dan Sharizat, pasukan pembangun aplikasi dari Kolej Vokasional Kuala Selangor.',
            'Versi ini dibangunkan untuk demo aplikasi dan pengujian awal.',
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _HomeDrawer(
        onFreshTap: _openFreshListScreen,
        onMapTap: () {},
        onReportTap: _openAddReportScreen,
        onFavoritesTap: _openFavoritesScreen,
        onProfileTap: _openProfileScreen,
        onAdminTap: _openAdminReviewScreen,
        onHelpTap: _showHowToUseSheet,
        onAboutTap: _showAboutAppSheet,
      ),
      backgroundColor: _DRColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            _HomeTopSection(
              searchController: _searchController,
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                  _mapFilterRevision++;
                });
              },
              onSearchChanged: (_) {
                setState(() {});
              },
              onMenuTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              onNotificationTap: _openAdminReviewScreen,
              onFilterTap: _openFilterSheet,
            ),
            Expanded(
              child: FutureBuilder<List<DurianReportSummary>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  final allReports =
                      snapshot.data ?? const <DurianReportSummary>[];
                  final reports = _applyFilters(allReports);
                  final previewReport = reports.isNotEmpty
                      ? reports.first
                      : null;

                  final mapCenter =
                      _currentLocation ??
                      (reports.isNotEmpty
                          ? LatLng(
                              reports.first.latitude,
                              reports.first.longitude,
                            )
                          : _defaultCenter);

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: mapCenter,
                          initialZoom: reports.isNotEmpty ? 11.6 : 10.5,
                          minZoom: 5,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.durian_radar',
                          ),
                          MarkerLayer(
                            key: ValueKey(
                              'markers-${_selectedFilter.name}-$_mapFilterRevision-${reports.length}-${_searchController.text}',
                            ),
                            markers: [
                              for (final report in reports)
                                if (report.latitude != 0 &&
                                    report.longitude != 0)
                                  Marker(
                                    point: LatLng(
                                      report.latitude,
                                      report.longitude,
                                    ),
                                    width: 64,
                                    height: 74,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PinDetailScreen(report: report),
                                          ),
                                        );
                                      },
                                      child: _MapMarker(
                                        label: report.markerLabel,
                                        color: _markerColor(report.stockStatus),
                                        hasPhoto: report.photoUrl
                                            .trim()
                                            .isNotEmpty,
                                      ),
                                    ),
                                  ),
                              if (_currentLocation != null)
                                Marker(
                                  point: _currentLocation!,
                                  width: 30,
                                  height: 30,
                                  child: const _CurrentLocationDot(),
                                ),
                            ],
                          ),
                        ],
                      ),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _DRColors.durianGreen,
                              ),
                            ),
                          ),
                        ),

                      Positioned(
                        left: 12,
                        right: 168,
                        top: 10,
                        child: _MapHintBanner(
                          text: _currentLocation == null
                              ? 'Tekan lokasi untuk center map'
                              : 'Map sekitar anda',
                        ),
                      ),

                      Positioned(
                        right: 12,
                        top: 116,
                        child: _MapControlColumn(
                          isLocating: _isLocating,
                          onLocateTap: _centerToCurrentLocation,
                          onZoomInTap: () => _zoomBy(1),
                          onZoomOutTap: () => _zoomBy(-1),
                        ),
                      ),

                      Positioned(
                        right: 12,
                        top: 14,
                        child: const _MapLegendCard(),
                      ),

                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 16,
                        child: _HomeFreshPreviewCard(
                          report: previewReport,
                          count: reports.length,
                          hasLoading:
                              snapshot.connectionState ==
                              ConnectionState.waiting,
                          onViewAllTap: _openFreshListScreen,
                          onCardTap: previewReport == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PinDetailScreen(
                                        report: previewReport,
                                      ),
                                    ),
                                  );
                                },
                          distanceText: previewReport == null
                              ? null
                              : _formatDistance(previewReport),
                          stockLabel: previewReport == null
                              ? null
                              : _stockLabel(previewReport.stockStatus),
                          isFavorite:
                              previewReport != null &&
                              _isFavorite(previewReport),
                          onFavoriteTap: previewReport == null
                              ? null
                              : () => _toggleFavorite(previewReport),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MockupBottomBar(
        onFreshTap: _openFreshListScreen,
        onMapTap: () {},
        onReportTap: _openAddReportScreen,
        onFavouriteTap: _openFavoritesScreen,
        onProfileTap: _openProfileScreen,
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.onFreshTap,
    required this.onMapTap,
    required this.onReportTap,
    required this.onFavoritesTap,
    required this.onProfileTap,
    required this.onAdminTap,
    required this.onHelpTap,
    required this.onAboutTap,
  });

  final VoidCallback onFreshTap;
  final VoidCallback onMapTap;
  final VoidCallback onReportTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onProfileTap;
  final VoidCallback onAdminTap;
  final VoidCallback onHelpTap;
  final VoidCallback onAboutTap;

  void _closeThenRun(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    Future<void>.delayed(const Duration(milliseconds: 160), action);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _DRColors.appBackground,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerBrandHeader(),
            const SizedBox(height: 8),
            _DrawerActionItem(
              icon: Icons.map_rounded,
              title: 'Peta',
              subtitle: 'Lihat lokasi gerai durian aktif',
              selected: true,
              onTap: () {
                Navigator.of(context).pop();
                onMapTap();
              },
            ),
            _DrawerActionItem(
              icon: Icons.view_list_rounded,
              title: 'Fresh List',
              subtitle: 'Senarai gerai durian terkini',
              onTap: () => _closeThenRun(context, onFreshTap),
            ),
            _DrawerActionItem(
              icon: Icons.add_location_alt_rounded,
              title: 'Laporkan Durian',
              subtitle: 'Tambah lokasi gerai durian baharu',
              onTap: () => _closeThenRun(context, onReportTap),
            ),
            _DrawerActionItem(
              icon: Icons.favorite_rounded,
              title: 'Kegemaran',
              subtitle: 'Gerai durian yang anda simpan',
              onTap: () => _closeThenRun(context, onFavoritesTap),
            ),
            _DrawerActionItem(
              icon: Icons.person_rounded,
              title: 'Profil / Akaun',
              subtitle: 'Log masuk dan urus akaun Google',
              onTap: () => _closeThenRun(context, onProfileTap),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 18, 22, 8),
              child: Text(
                'Pengurusan',
                style: TextStyle(
                  color: _DRColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            _DrawerActionItem(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Admin Review',
              subtitle: 'Semak dan sahkan laporan komuniti',
              onTap: () => _closeThenRun(context, onAdminTap),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 18, 22, 8),
              child: Text(
                'Maklumat',
                style: TextStyle(
                  color: _DRColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            _DrawerActionItem(
              icon: Icons.help_outline_rounded,
              title: 'Cara Guna',
              subtitle: 'Panduan ringkas menggunakan app',
              onTap: () => _closeThenRun(context, onHelpTap),
            ),
            _DrawerActionItem(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Durian Radar',
              subtitle: 'Maklumat aplikasi dan fungsi utama',
              onTap: () => _closeThenRun(context, onAboutTap),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _DrawerBrandHeader extends StatelessWidget {
  const _DrawerBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _DRColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            _DRAssets.durianLogo,
            width: 62,
            height: 62,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) {
              return Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: _DRColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: _DRColors.durianGreen,
                  size: 34,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DURIAN',
                  style: TextStyle(
                    color: _DRColors.textDark,
                    fontSize: 20,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'RADAR',
                  style: TextStyle(
                    color: _DRColors.freshGreen,
                    fontSize: 20,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cari durian fresh sekitar anda',
                  style: TextStyle(
                    color: _DRColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerActionItem extends StatelessWidget {
  const _DrawerActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? _DRColors.paleGreen : Colors.transparent;
    final iconBg = selected ? _DRColors.durianGreen : _DRColors.creamSoft;
    final iconColor = selected ? Colors.white : _DRColors.durianGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 23),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: selected
                              ? _DRColors.durianGreen
                              : _DRColors.textDark,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _DRColors.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: selected ? _DRColors.durianGreen : _DRColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuInfoSheet extends StatelessWidget {
  const _MenuInfoSheet({
    required this.icon,
    required this.title,
    required this.bullets,
    this.imageAsset,
  });

  final IconData icon;
  final String title;
  final List<String> bullets;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.88,
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: BoxDecoration(
            color: _DRColors.cardWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: _DRColors.borderSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _DRColors.paleGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: _DRColors.durianGreen, size: 27),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _DRColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageAsset != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              width: double.infinity,
                              color: _DRColors.creamSoft,
                              child: ClipRect(
                                child: Transform.scale(
                                  scale: 1.0,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    imageAsset!,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, _, _) {
                                      return Container(
                                        width: double.infinity,
                                        height: 180,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _DRColors.paleGreen,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _DRColors.borderSoft,
                                          ),
                                        ),
                                        child: const Text(
                                          'Gambar pasukan pembangun belum dijumpai.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _DRColors.durianGreen,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      for (final bullet in bullets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: _DRColors.freshGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  bullet,
                                  style: const TextStyle(
                                    color: _DRColors.textDark,
                                    fontSize: 13.5,
                                    height: 1.32,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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

class _HomeTopSection extends StatelessWidget {
  const _HomeTopSection({
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onSearchChanged,
    required this.onMenuTap,
    required this.onNotificationTap,
    required this.onFilterTap,
  });

  final TextEditingController searchController;
  final _HomeFilter selectedFilter;
  final ValueChanged<_HomeFilter> onFilterSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DRColors.cardWhite,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              _TopSquareButton(icon: Icons.menu_rounded, onTap: onMenuTap),
              const SizedBox(width: 12),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        _DRAssets.durianLogo,
                        width: 58,
                        height: 58,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) {
                          return Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: _DRColors.paleGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.radar_rounded,
                              color: _DRColors.durianGreen,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DURIAN',
                            style: TextStyle(
                              color: _DRColors.textDark,
                              fontSize: 18,
                              height: 0.92,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'RADAR',
                            style: TextStyle(
                              color: _DRColors.freshGreen,
                              fontSize: 18,
                              height: 0.92,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _TopSquareButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SearchBox(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 10),
              _FilterPillButton(onTap: onFilterTap),
            ],
          ),
          const SizedBox(height: 12),
          _FilterChipRow(
            selectedFilter: selectedFilter,
            onSelected: onFilterSelected,
          ),
        ],
      ),
    );
  }
}

class _TopSquareButton extends StatelessWidget {
  const _TopSquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DRColors.cardWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _DRColors.borderSoft),
          ),
          child: Icon(icon, color: _DRColors.textDark, size: 22),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _DRColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DRColors.borderSoft),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: _DRColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Cari lokasi durian...',
          hintStyle: TextStyle(
            color: _DRColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _DRColors.textMuted,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 44),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _FilterPillButton extends StatelessWidget {
  const _FilterPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DRColors.cardWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _DRColors.borderSoft),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, color: _DRColors.textDark, size: 18),
              SizedBox(width: 6),
              Text(
                'Filter',
                style: TextStyle(
                  color: _DRColors.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.selectedFilter,
    required this.onSelected,
  });

  final _HomeFilter selectedFilter;
  final ValueChanged<_HomeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StaticChip(
            label: 'Fresh',
            icon: Icons.eco_rounded,
            color: _DRColors.freshGreen,
            selected: selectedFilter == _HomeFilter.all,
            onTap: () => onSelected(_HomeFilter.all),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StaticChip(
            label: 'Masih Ada',
            icon: Icons.inventory_2_rounded,
            color: _DRColors.warningYellow,
            selected: selectedFilter == _HomeFilter.available,
            onTap: () => onSelected(_HomeFilter.available),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StaticChip(
            label: 'Murah',
            icon: Icons.sell_rounded,
            color: _DRColors.warningYellow,
            selected: selectedFilter == _HomeFilter.cheap,
            onTap: () => onSelected(_HomeFilter.cheap),
          ),
        ),
      ],
    );
  }
}

class _StaticChip extends StatelessWidget {
  const _StaticChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? _DRColors.paleGreen : _DRColors.cardWhite,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? _DRColors.durianGreen : _DRColors.borderSoft,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected ? _DRColors.durianGreen : color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? _DRColors.durianGreen
                        : _DRColors.textDark,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
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

class _MapHintBanner extends StatelessWidget {
  const _MapHintBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _DRColors.cardWhite.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: _DRColors.durianGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DRColors.textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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

class _MapControlColumn extends StatelessWidget {
  const _MapControlColumn({
    required this.isLocating,
    required this.onLocateTap,
    required this.onZoomInTap,
    required this.onZoomOutTap,
  });

  final bool isLocating;
  final VoidCallback onLocateTap;
  final VoidCallback onZoomInTap;
  final VoidCallback onZoomOutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoundMapButton(
          onTap: isLocating ? null : onLocateTap,
          child: isLocating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _DRColors.durianGreen,
                  ),
                )
              : const Icon(
                  Icons.my_location_rounded,
                  color: _DRColors.textDark,
                  size: 22,
                ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _DRColors.cardWhite.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _VerticalControlButton(
                icon: Icons.add_rounded,
                onTap: onZoomInTap,
              ),
              Container(width: 36, height: 1, color: _DRColors.borderSoft),
              _VerticalControlButton(
                icon: Icons.remove_rounded,
                onTap: onZoomOutTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DRColors.cardWhite.withValues(alpha: 0.96),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Center(child: child)),
      ),
    );
  }
}

class _VerticalControlButton extends StatelessWidget {
  const _VerticalControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, color: _DRColors.textDark, size: 20),
      ),
    );
  }
}

class _MapLegendCard extends StatelessWidget {
  const _MapLegendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendRow(color: _DRColors.freshGreen, label: 'Banyak'),
          SizedBox(height: 4),
          _LegendRow(color: _DRColors.warningYellow, label: 'Sederhana'),
          SizedBox(height: 4),
          _LegendRow(color: _DRColors.soldOutRed, label: 'Hampir Habis'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _DRColors.textDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HomeFreshPreviewCard extends StatelessWidget {
  const _HomeFreshPreviewCard({
    required this.report,
    required this.count,
    required this.hasLoading,
    required this.onViewAllTap,
    required this.onCardTap,
    required this.distanceText,
    required this.stockLabel,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final DurianReportSummary? report;
  final int count;
  final bool hasLoading;
  final VoidCallback onViewAllTap;
  final VoidCallback? onCardTap;
  final String? distanceText;
  final String? stockLabel;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.11),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fresh List',
                      style: TextStyle(
                        color: _DRColors.textDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Lokasi durian berhampiran anda',
                      style: TextStyle(
                        color: _DRColors.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewAllTap,
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: _DRColors.durianGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CircularProgressIndicator(color: _DRColors.durianGreen),
            )
          else if (report == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _DRColors.creamSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _DRColors.borderSoft),
              ),
              child: const Text(
                'Tiada lokasi durian sepadan dengan carian/filter semasa.',
                style: TextStyle(
                  color: _DRColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onCardTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _DRColors.borderSoft),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 84,
                        height: 68,
                        child: report!.photoUrl.trim().isNotEmpty
                            ? Image.network(
                                report!.photoUrl.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) {
                                  return _PreviewImageFallback(
                                    label: report!.markerLabel,
                                  );
                                },
                              )
                            : _PreviewImageFallback(label: report!.markerLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report!.stallName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _DRColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: _DRColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  report!.area,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _DRColors.textMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.eco_outlined,
                                size: 14,
                                color: _DRColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  report!.variety,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _DRColors.textMuted,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Text(
                                report!.price,
                                style: const TextStyle(
                                  color: _DRColors.durianGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Stok: ${stockLabel ?? '-'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _DRColors.textDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _FavoriteMiniButton(
                          isFavorite: isFavorite,
                          onTap: onFavoriteTap,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          distanceText ?? '—',
                          style: const TextStyle(
                            color: _DRColors.freshGreen,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _DRColors.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (!hasLoading) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$count lokasi aktif di Durian Radar',
                style: const TextStyle(
                  color: _DRColors.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavoriteMiniButton extends StatelessWidget {
  const _FavoriteMiniButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFavorite ? _DRColors.soldOutRed : _DRColors.creamSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? Colors.white : _DRColors.textMuted,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _PreviewImageFallback extends StatelessWidget {
  const _PreviewImageFallback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DRColors.paleGreen,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: _DRColors.durianGreen,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF3D7BFF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D7BFF).withValues(alpha: 0.28),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
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
    final longLabel = label.length > 3;
    final labelColor = color.computeLuminance() > 0.55
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

class _BottomSheetFilterChip extends StatelessWidget {
  const _BottomSheetFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : _DRColors.durianGreen,
          fontWeight: FontWeight.w800,
        ),
      ),
      selected: selected,
      selectedColor: _DRColors.durianGreen,
      backgroundColor: _DRColors.creamSoft,
      side: BorderSide(
        color: selected ? _DRColors.durianGreen : _DRColors.borderSoft,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _MockupBottomBar extends StatelessWidget {
  const _MockupBottomBar({
    required this.onFreshTap,
    required this.onMapTap,
    required this.onReportTap,
    required this.onFavouriteTap,
    required this.onProfileTap,
  });

  final VoidCallback onFreshTap;
  final VoidCallback onMapTap;
  final VoidCallback onReportTap;
  final VoidCallback onFavouriteTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 78 + bottomPadding,
      decoration: const BoxDecoration(
        color: _DRColors.cardWhite,
        border: Border(top: BorderSide(color: _DRColors.borderSoft)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            Expanded(
              child: _BottomBarItem(
                icon: Icons.view_list_rounded,
                label: 'Fresh List',
                onTap: onFreshTap,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                icon: Icons.location_on_rounded,
                label: 'Peta',
                selected: true,
                onTap: onMapTap,
              ),
            ),
            SizedBox(
              width: 78,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onReportTap,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: _DRColors.freshGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Lapor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _DRColors.textDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                icon: Icons.favorite_border_rounded,
                label: 'Kegemaran',
                onTap: onFavouriteTap,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                onTap: onProfileTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _DRColors.freshGreen : _DRColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DRColors {
  static const Color appBackground = Color(0xFFF8F7F1);
  static const Color creamSoft = Color(0xFFFFFBF3);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color paleGreen = Color(0xFFE9F6DD);

  static const Color durianGreen = Color(0xFF2C7A35);
  static const Color freshGreen = Color(0xFF5FB542);
  static const Color warningYellow = Color(0xFFF4B322);
  static const Color soldOutRed = Color(0xFFE94B46);

  static const Color textDark = Color(0xFF243527);
  static const Color textMuted = Color(0xFF738073);
  static const Color borderSoft = Color(0xFFE6E7DC);
}

class _DRAssets {
  static const String durianLogo = 'assets/images/durian_logo.png';
  static const String developerTeam = 'assets/images/team_developers.png';
}
