import 'package:flutter/material.dart';

import '../../../core/services/favorite_service.dart';
import '../../../core/services/report_service.dart';
import '../../pin_detail/screens/pin_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<DurianReportSummary>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<List<DurianReportSummary>> _loadFavorites() async {
    final favoriteKeys = await FavoriteService.fetchFavoriteKeys();
    final reports = await ReportService.fetchApprovedReports();

    return reports
        .where(
          (report) =>
              favoriteKeys.contains(FavoriteService.keyForReport(report)),
        )
        .toList(growable: false);
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _loadFavorites();
    });

    await _favoritesFuture;
  }

  Future<void> _removeFavorite(DurianReportSummary report) async {
    await FavoriteService.removeReport(report);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${report.stallName} dibuang daripada Kegemaran.'),
      ),
    );

    await _refreshFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FavoriteColors.background,
      appBar: AppBar(
        backgroundColor: _FavoriteColors.background,
        elevation: 0,
        foregroundColor: _FavoriteColors.textDark,
        title: const Text(
          'Kegemaran',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.2),
        ),
      ),
      body: RefreshIndicator(
        color: _FavoriteColors.green,
        onRefresh: _refreshFavorites,
        child: FutureBuilder<List<DurianReportSummary>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            final favorites = snapshot.data ?? const <DurianReportSummary>[];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _FavoriteColors.green),
              );
            }

            if (favorites.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                children: const [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: _FavoriteColors.green,
                    size: 70,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Belum ada gerai kegemaran',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _FavoriteColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan ikon hati pada kad gerai untuk simpan lokasi durian yang anda suka.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _FavoriteColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = favorites[index];

                return _FavoriteReportCard(
                  report: report,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PinDetailScreen(report: report),
                      ),
                    );
                  },
                  onRemoveTap: () => _removeFavorite(report),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteReportCard extends StatelessWidget {
  const _FavoriteReportCard({
    required this.report,
    required this.onTap,
    required this.onRemoveTap,
  });

  final DurianReportSummary report;
  final VoidCallback onTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _FavoriteColors.cardWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _FavoriteColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 82,
                  height: 72,
                  child: report.photoUrl.trim().isNotEmpty
                      ? Image.network(
                          report.photoUrl.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return _FavoriteFallbackImage(
                              label: report.markerLabel,
                            );
                          },
                        )
                      : _FavoriteFallbackImage(label: report.markerLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.stallName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _FavoriteColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      report.area,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _FavoriteColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.variety,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _FavoriteColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.price,
                      style: const TextStyle(
                        color: _FavoriteColors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemoveTap,
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: _FavoriteColors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteFallbackImage extends StatelessWidget {
  const _FavoriteFallbackImage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _FavoriteColors.paleGreen,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: _FavoriteColors.green,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FavoriteColors {
  static const Color background = Color(0xFFF8F7F1);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color paleGreen = Color(0xFFE9F6DD);
  static const Color green = Color(0xFF2C7A35);
  static const Color red = Color(0xFFE94B46);
  static const Color textDark = Color(0xFF243527);
  static const Color textMuted = Color(0xFF738073);
  static const Color border = Color(0xFFE6E7DC);
}
