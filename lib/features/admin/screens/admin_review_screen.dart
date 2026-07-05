import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/report_service.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  late Future<List<DurianReportSummary>> _pendingReportsFuture;
  String? _busyReportId;

  static const String _adminEmail = 'intankeristina@gmail.com';

  bool get _isAdmin {
    final email = AuthService.currentUser?.email?.trim().toLowerCase() ?? '';
    return email == _adminEmail;
  }

  static const Color _cream = Color(0xFFFFFAEC);
  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  void initState() {
    super.initState();
    if (_isAdmin) {
      _loadPendingReports();
    } else {
      _pendingReportsFuture = Future.value(const <DurianReportSummary>[]);
    }
  }

  void _loadPendingReports() {
    _pendingReportsFuture = ReportService.fetchPendingReports();
  }

  Future<void> _refresh() async {
    if (!_isAdmin) {
      return;
    }

    setState(_loadPendingReports);
    await _pendingReportsFuture;
  }

  Future<void> _approveReport(DurianReportSummary report) async {
    final confirmed = await _confirmReviewAction(
      title: 'Luluskan laporan?',
      message:
          'Laporan "${report.stallName}" akan dipaparkan kepada pengguna awam.',
      confirmLabel: 'Approve',
      confirmColor: _green,
    );

    if (confirmed != true) {
      return;
    }

    await _reviewReport(
      report: report,
      actionLabel: 'approve',
      action: () => ReportService.approveReport(report.id),
      successMessage: 'Laporan diluluskan.',
    );
  }

  Future<void> _rejectReport(DurianReportSummary report) async {
    final confirmed = await _confirmReviewAction(
      title: 'Tolak laporan?',
      message:
          'Laporan "${report.stallName}" akan ditolak dan tidak dipaparkan kepada pengguna awam.',
      confirmLabel: 'Reject',
      confirmColor: Colors.red,
    );

    if (confirmed != true) {
      return;
    }

    await _reviewReport(
      report: report,
      actionLabel: 'reject',
      action: () => ReportService.rejectReport(report.id),
      successMessage: 'Laporan ditolak.',
    );
  }

  Future<bool?> _confirmReviewAction({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6F776F),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reviewReport({
    required DurianReportSummary report,
    required String actionLabel,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    if (_busyReportId != null) {
      return;
    }

    setState(() {
      _busyReportId = '${report.id}-$actionLabel';
    });

    try {
      await action();

      final updatedReports = await ReportService.fetchPendingReports();

      if (!mounted) {
        return;
      }

      setState(() {
        _pendingReportsFuture = Future.value(updatedReports);
        _busyReportId = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busyReportId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ReportService.getReadableError(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _cream,
          elevation: 0,
          foregroundColor: _darkGreen,
          title: const Text(
            'Admin Review',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: _MessageView(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Akses admin sahaja',
            message:
                'Halaman ini hanya boleh digunakan oleh admin Durian Radar.',
            buttonLabel: 'Kembali',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        foregroundColor: _darkGreen,
        title: const Text(
          'Admin Review',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<DurianReportSummary>>(
          future: _pendingReportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _green),
              );
            }

            if (snapshot.hasError) {
              return _MessageView(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuatkan laporan',
                message: ReportService.getReadableError(snapshot.error!),
                buttonLabel: 'Cuba Lagi',
                onPressed: _refresh,
              );
            }

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return _MessageView(
                icon: Icons.verified_rounded,
                title: 'Tiada laporan pending',
                message: 'Semua laporan komuniti sudah disemak.',
                buttonLabel: 'Refresh',
                onPressed: _refresh,
              );
            }

            return RefreshIndicator(
              color: _green,
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                itemCount: reports.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final report = reports[index];

                  return _PendingReportCard(
                    report: report,
                    isApproving: _busyReportId == '${report.id}-approve',
                    isRejecting: _busyReportId == '${report.id}-reject',
                    onApprove: () => _approveReport(report),
                    onReject: () => _rejectReport(report),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PendingReportCard extends StatelessWidget {
  const _PendingReportCard({
    required this.report,
    required this.isApproving,
    required this.isRejecting,
    required this.onApprove,
    required this.onReject,
  });

  final DurianReportSummary report;
  final bool isApproving;
  final bool isRejecting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _yellow = Color(0xFFFFC857);
  static const Color _textMuted = Color(0xFF6F776F);

  bool get _hasCoordinates {
    return report.latitude != 0 && report.longitude != 0;
  }

  bool get _hasSellerPhone {
    return report.sellerPhone.trim().isNotEmpty;
  }

  bool get _hasPhotoUrl {
    return report.photoUrl.trim().isNotEmpty;
  }

  Future<void> _openAdminNavigation(BuildContext context) async {
    if (!_hasCoordinates) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinat laporan belum tersedia.')),
      );
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }

  Future<void> _openAdminWhatsApp(BuildContext context) async {
    final normalizedPhone = _normalizeMalaysianPhone(report.sellerPhone);

    if (normalizedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombor WhatsApp penjual belum tersedia.'),
        ),
      );
      return;
    }

    final message = Uri.encodeComponent(
      'Hai, saya admin Durian Radar. Saya ingin semak laporan durian yang dihantar melalui aplikasi.',
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
    final isBusy = isApproving || isRejecting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DEC3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(47, 107, 63, 0.08),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MarkerBadge(label: report.markerLabel),
              const SizedBox(width: 12),
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
                    Text(
                      report.area,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _yellow.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_hasPhotoUrl) ...[
            _AdminPhotoPreview(photoUrl: report.photoUrl.trim()),
            const SizedBox(height: 14),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.eco_rounded, label: report.variety),
              _InfoChip(icon: Icons.payments_rounded, label: report.price),
              _InfoChip(
                icon: Icons.inventory_2_rounded,
                label: report.statusText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAEC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8DEC3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Semakan admin',
                  style: TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _AdminDetailLine(
                  icon: Icons.phone_rounded,
                  label: 'WhatsApp',
                  value: _hasSellerPhone
                      ? report.sellerPhone.trim()
                      : 'Tiada nombor',
                ),
                const SizedBox(height: 8),
                _AdminDetailLine(
                  icon: Icons.location_on_rounded,
                  label: 'Koordinat',
                  value: _hasCoordinates
                      ? '${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}'
                      : 'Tiada koordinat',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isBusy || !_hasCoordinates
                            ? null
                            : () => _openAdminNavigation(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side: const BorderSide(color: _green),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.map_rounded),
                        label: const Text(
                          'Semak Map',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isBusy || !_hasSellerPhone
                            ? null
                            : () => _openAdminWhatsApp(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _darkGreen,
                          side: const BorderSide(color: _yellow),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.chat_rounded),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (report.note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              report.note,
              style: const TextStyle(color: _textMuted, height: 1.3),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: isRejecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.close_rounded),
                  label: const Text(
                    'Reject',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: isApproving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text(
                    'Approve',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminPhotoPreview extends StatelessWidget {
  const _AdminPhotoPreview({required this.photoUrl});

  final String photoUrl;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Image.network(
            photoUrl,
            width: double.infinity,
            height: 190,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                width: double.infinity,
                height: 190,
                color: const Color(0xFFFFFAEC),
                child: const Center(
                  child: CircularProgressIndicator(color: _green),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAEC),
                  border: Border.all(color: const Color(0xFFE8DEC3)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined, color: _green, size: 34),
                    SizedBox(height: 8),
                    Text(
                      'Gambar gerai tidak dapat dipaparkan',
                      textAlign: TextAlign.center,
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
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_camera_rounded, color: _green, size: 15),
                  SizedBox(width: 5),
                  Text(
                    'Gambar laporan',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDetailLine extends StatelessWidget {
  const _AdminDetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _darkGreen = Color(0xFF17412A);
  static const Color _textMuted = Color(0xFF6F776F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.w900,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MarkerBadge extends StatelessWidget {
  const _MarkerBadge({required this.label});

  final String label;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _softGreen = Color(0xFFEAF5E6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green, width: 1.3),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: _green, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static const Color _green = Color(0xFF2F6B3F);
  static const Color _softGreen = Color(0xFFEAF5E6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _green),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

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
            border: Border.all(color: const Color(0xFFE8DEC3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: _darkGreen, size: 38),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6F776F), height: 1.35),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
