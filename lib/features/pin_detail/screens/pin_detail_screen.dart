import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/favorite_service.dart';
import '../../../core/services/report_service.dart';

class PinDetailScreen extends StatelessWidget {
  const PinDetailScreen({super.key, required this.report});

  final DurianReportSummary report;

  static const Color _cream = Color(0xFFFFFAEC);
  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _softGreen = Color(0xFFEAF5E6);
  static const Color _softYellow = Color(0xFFFFF3C4);
  static const Color _softRed = Color(0xFFFFE6E2);

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(report.stockStatus);

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        actions: [
          _DetailFavoriteButton(report: report),
          const SizedBox(width: 8),
        ],
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _darkGreen,
        title: const Text(
          'Butiran Lokasi',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _HeroMapCard(
              markerLabel: report.markerLabel,
              markerColor: statusStyle.foregroundColor,
              stallName: report.stallName,
              area: report.area,
            ),
            if (report.photoUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _StallPhotoCard(photoUrl: report.photoUrl.trim()),
            ],
            const SizedBox(height: 16),
            _MainInfoCard(
              report: report,
              statusBackgroundColor: statusStyle.backgroundColor,
              statusForegroundColor: statusStyle.foregroundColor,
            ),
            const SizedBox(height: 16),
            _CommunityTrustCard(report: report),
            const SizedBox(height: 16),
            _ActionPanel(report: report),
          ],
        ),
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

class _StallPhotoCard extends StatelessWidget {
  const _StallPhotoCard({required this.photoUrl});

  final String photoUrl;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8DEC3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(47, 107, 63, 0.10),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            photoUrl,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                width: double.infinity,
                height: 240,
                color: const Color(0xFFFFFAEC),
                child: const Center(
                  child: CircularProgressIndicator(color: _green),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 190,
                color: const Color(0xFFFFFAEC),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined, color: _green, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Gambar gerai tidak dapat dipaparkan',
                      style: TextStyle(
                        color: _darkGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Row(
              children: [
                Icon(Icons.photo_camera_rounded, color: _green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Gambar Gerai / Papan Harga',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

class _HeroMapCard extends StatelessWidget {
  const _HeroMapCard({
    required this.markerLabel,
    required this.markerColor,
    required this.stallName,
    required this.area,
  });

  final String markerLabel;
  final Color markerColor;
  final String stallName;
  final String area;

  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _green = Color(0xFF2F6B3F);
  static const Color _mapBase = Color(0xFFF3EBD8);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245,
      decoration: BoxDecoration(
        color: _mapBase,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFFE8DEC3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(47, 107, 63, 0.10),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DetailMapPainter())),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _LargeMarker(label: markerLabel, color: markerColor),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stallName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _darkGreen,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            size: 16,
                            color: _green,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6F776F),
                                fontWeight: FontWeight.w700,
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
          ),
          const Positioned(
            right: 14,
            top: 14,
            child: _MapPill(label: 'Live report'),
          ),
        ],
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({
    required this.report,
    required this.statusBackgroundColor,
    required this.statusForegroundColor,
  });

  final DurianReportSummary report;
  final Color statusBackgroundColor;
  final Color statusForegroundColor;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _softGreen = Color(0xFFEAF5E6);
  static const Color _softYellow = Color(0xFFFFF3C4);

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Maklumat Durian',
            style: TextStyle(
              color: _darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.eco_rounded,
                label: report.variety,
                backgroundColor: _softGreen,
                foregroundColor: _green,
              ),
              _InfoChip(
                icon: Icons.payments_rounded,
                label: report.price,
                backgroundColor: _softYellow,
                foregroundColor: _darkGreen,
              ),
              _InfoChip(
                icon: Icons.inventory_2_rounded,
                label: report.statusText,
                backgroundColor: statusBackgroundColor,
                foregroundColor: statusForegroundColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailRow(
            icon: Icons.storefront_rounded,
            title: 'Nama gerai / lokasi',
            value: report.stallName,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.place_rounded,
            title: 'Kawasan',
            value: report.area,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.update_rounded,
            title: 'Kemaskini',
            value: report.updatedTime,
          ),
          if (report.note.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Color(0xFFE8DEC3)),
              ),
              child: Text(
                report.note,
                style: const TextStyle(
                  color: Color(0xFF6F776F),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommunityTrustCard extends StatelessWidget {
  const _CommunityTrustCard({required this.report});

  final DurianReportSummary report;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  Widget build(BuildContext context) {
    final approvalText = report.isApproved
        ? 'Laporan ini telah disahkan oleh admin.'
        : 'Laporan ini masih menunggu semakan admin.';

    return _WhiteCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: report.isApproved
                  ? const Color(0xFFEAF5E6)
                  : const Color(0xFFFFF3C4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              report.isApproved
                  ? Icons.verified_rounded
                  : Icons.hourglass_top_rounded,
              color: report.isApproved ? _green : Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.isApproved ? 'Disahkan' : 'Menunggu Semakan',
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  approvalText,
                  style: const TextStyle(
                    color: Color(0xFF6F776F),
                    height: 1.3,
                    fontWeight: FontWeight.w600,
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

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.report});

  final DurianReportSummary report;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _textMuted = Color(0xFF6F776F);

  Future<void> _openNavigation(BuildContext context) async {
    final latitude = report.latitude;
    final longitude = report.longitude;

    if (latitude == 0 || longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koordinat lokasi belum tersedia untuk laporan ini.'),
        ),
      );
      return;
    }

    final uri = Uri.https('waze.com', '/ul', {
      'll': '$latitude,$longitude',
      'navigate': 'yes',
      'utm_source': 'durian_radar',
    });

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Waze.')),
      );
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final normalizedPhone = _normalizeMalaysianPhone(report.sellerPhone);

    if (normalizedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nombor WhatsApp penjual belum tersedia untuk laporan ini.',
          ),
        ),
      );
      return;
    }

    final message = Uri.encodeComponent(
      'Hai, saya jumpa lokasi durian anda melalui aplikasi Durian Radar. Masih ada stok?',
    );

    final uri = Uri.parse('https://wa.me/$normalizedPhone?text=$message');

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  String _normalizeMalaysianPhone(String value) {
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return '';
    }

    if (digits.startsWith('0')) {
      digits = '6$digits';
    } else if (digits.startsWith('1')) {
      digits = '60$digits';
    }

    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = report.sellerPhone.trim().isNotEmpty;

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tindakan',
            style: TextStyle(
              color: _darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openNavigation(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.directions_car_filled_rounded),
                  label: const Text(
                    'Arah Waze',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openWhatsApp(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857),
                    foregroundColor: _darkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(
                    hasPhone
                        ? Icons.chat_rounded
                        : Icons.phone_disabled_rounded,
                  ),
                  label: Text(
                    hasPhone ? 'WhatsApp' : 'Hubungi',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasPhone
                ? 'Butang WhatsApp menggunakan nombor penjual yang dihantar bersama laporan komuniti.'
                : 'Tekan Arah Waze untuk panduan jalan ke gerai. Nombor penjual belum tersedia untuk laporan ini.',
            style: const TextStyle(
              color: _textMuted,
              height: 1.3,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Color(0xFFE8DEC3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(47, 107, 63, 0.08),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LargeMarker extends StatelessWidget {
  const _LargeMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool longLabel = label.length > 3;

    return SizedBox(
      width: 86,
      height: 94,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 8,
            child: Icon(
              Icons.location_on_rounded,
              size: 82,
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
          const Positioned(
            top: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 86,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 5,
            child: Icon(Icons.location_on_rounded, size: 76, color: color),
          ),
          Positioned(
            top: 28,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: longLabel ? 13 : 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPill extends StatelessWidget {
  const _MapPill({required this.label});

  final String label;

  static const Color _green = Color(0xFF2F6B3F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_done_rounded, color: _green, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _green,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _green, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6F776F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _DetailMapPainter extends CustomPainter {
  const _DetailMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF3EBD8),
    );

    final riverPaint = Paint()
      ..color = const Color(0xFFBFE3EA)
      ..strokeWidth = 36
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = const Color(0xFFFFD97A)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minorRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final greenPaint = Paint()
      ..color = const Color(0xFFDCECCE)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.14, 90, 70),
      greenPaint,
    );

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.72, size.height * 0.60, 130, 90),
      greenPaint,
    );

    final river = Path()
      ..moveTo(-20, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.42,
        size.width * 0.04,
        size.height + 30,
      );

    canvas.drawPath(river, riverPaint);

    final roadOne = Path()
      ..moveTo(size.width * 0.08, size.height + 20)
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.62,
        size.width * 0.80,
        -10,
      );

    final roadTwo = Path()
      ..moveTo(-20, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.36,
        size.width + 20,
        size.height * 0.44,
      );

    canvas.drawPath(roadOne, roadPaint);
    canvas.drawPath(roadTwo, minorRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailFavoriteButton extends StatefulWidget {
  const _DetailFavoriteButton({required this.report});

  final DurianReportSummary report;

  @override
  State<_DetailFavoriteButton> createState() => _DetailFavoriteButtonState();
}

class _DetailFavoriteButtonState extends State<_DetailFavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFavorite = await FavoriteService.isFavorite(widget.report);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isNowFavorite = await FavoriteService.toggleReport(widget.report);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isNowFavorite;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite
              ? '${widget.report.stallName} ditambah ke Kegemaran.'
              : '${widget.report.stallName} dibuang daripada Kegemaran.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _isFavorite ? 'Buang daripada Kegemaran' : 'Tambah Kegemaran',
      onPressed: _isLoading ? null : _toggleFavorite,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2C7A35),
              ),
            )
          : Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite
                  ? const Color(0xFFE94B46)
                  : const Color(0xFF2C7A35),
            ),
    );
  }
}
