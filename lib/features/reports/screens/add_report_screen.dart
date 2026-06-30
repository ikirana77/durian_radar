import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/report_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/screens/login_register_screen.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedStockStatus = 'Banyak';
  bool _isSubmitting = false;
  String? _statusMessage;
  bool _isStatusError = false;

  static const String _temporarySpotId = '00000000-0000-0000-0000-000000000001';

  @override
  void dispose() {
    _stallNameController.dispose();
    _areaController.dispose();
    _varietyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    final stallName = _stallNameController.text.trim();
    final area = _areaController.text.trim();
    final variety = _varietyController.text.trim();
    final priceText = _priceController.text.trim();

    if (stallName.isEmpty) {
      _showStatus('Sila masukkan nama gerai atau lokasi.', isError: true);
      return;
    }

    if (area.isEmpty) {
      _showStatus('Sila masukkan kawasan.', isError: true);
      return;
    }

    if (variety.isEmpty) {
      _showStatus('Sila masukkan jenis durian.', isError: true);
      return;
    }

    final price = _parsePrice(priceText);

    if (price == null || price <= 0) {
      _showStatus(
        'Sila masukkan harga yang sah. Contoh: 38 atau RM38.',
        isError: true,
      );
      return;
    }

    if (!AuthService.isLoggedIn) {
      final shouldContinue = await _askUserToLogin();

      if (shouldContinue != true || !AuthService.isLoggedIn) {
        _showStatus(
          'Sila log masuk dahulu sebelum menghantar laporan.',
          isError: true,
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Sedang menghantar laporan ke Supabase...';
      _isStatusError = false;
    });

    try {
      await ReportService.createPendingReport(
  spotId: _temporarySpotId,
  stallName: stallName,
  area: area,
  variety: variety,
  pricePerKg: price,
  stockStatus: _selectedStockStatus,
);

      if (!mounted) return;

      _showStatus(
        'Laporan berjaya dihantar untuk semakan admin.',
      );

      await Future<void>.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showStatus(
        ReportService.getReadableError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool?> _askUserToLogin() async {
    _showStatus(
      'Anda perlu log masuk sebelum menghantar laporan.',
      isError: true,
    );

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginRegisterScreen(),
      ),
    );
  }

  double? _parsePrice(String value) {
    final cleaned = value
        .replaceAll('RM', '')
        .replaceAll('rm', '')
        .replaceAll(',', '.')
        .replaceAll('/kg', '')
        .replaceAll('kg', '')
        .trim();

    return double.tryParse(cleaned);
  }

  void _showStatus(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
      _isStatusError = isError;
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ReportHeader(),
              const SizedBox(height: AppSpacing.xl),
              const _LocationPreviewCard(),
              const SizedBox(height: AppSpacing.l),
              const _FormSectionTitle(number: '1', title: 'Maklumat Lokasi'),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _stallNameController,
                label: 'Nama gerai / lokasi',
                hint: 'Contoh: Gerai Durian Bukit Rotan',
                icon: Icons.storefront,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _areaController,
                label: 'Kawasan',
                hint: 'Contoh: Kuala Selangor',
                icon: Icons.location_on_outlined,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormSectionTitle(number: '2', title: 'Jenis & Harga'),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _varietyController,
                label: 'Jenis durian',
                hint: 'Contoh: Musang King, D24, XO',
                icon: Icons.eco,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.m),
              _AppTextField(
                controller: _priceController,
                label: 'Harga per kg',
                hint: 'Contoh: RM38',
                icon: Icons.sell,
                keyboardType: TextInputType.number,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormSectionTitle(number: '3', title: 'Status Stok'),
              const SizedBox(height: AppSpacing.m),
              _StockStatusRow(
                selectedStatus: _selectedStockStatus,
                enabled: !_isSubmitting,
                onSelected: (status) {
                  setState(() {
                    _selectedStockStatus = status;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const _PhotoUploadDummy(),
              if (_statusMessage != null) ...[
                const SizedBox(height: AppSpacing.l),
                _StatusBox(
                  message: _statusMessage!,
                  isError: _isStatusError,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Sedang Hantar...' : 'Hantar Laporan',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Center(
                child: TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: AppColors.durianGreen,
        ),
        const SizedBox(width: AppSpacing.s),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Laporkan Durian', style: AppTextStyles.pageTitle),
              SizedBox(height: 4),
              Text(
                'Tambah laporan durian fresh untuk komuniti',
                style: AppTextStyles.helper,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.paleGreen,
            child: Icon(Icons.location_on, color: AppColors.durianGreen),
          ),
          SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              'Untuk checkpoint ini, laporan dihantar ke Supabase menggunakan lokasi sementara. Sambungan map/location sebenar akan dibuat selepas ini.',
              style: AppTextStyles.helper,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.durianGreen,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.durianGreen),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.softCardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.durianGreen, width: 2),
        ),
      ),
    );
  }
}

class _StockStatusRow extends StatelessWidget {
  const _StockStatusRow({
    required this.selectedStatus,
    required this.enabled,
    required this.onSelected,
  });

  final String selectedStatus;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        _StatusChoice(
          label: 'Banyak',
          color: AppColors.freshGreen,
          icon: Icons.check_circle,
          selected: selectedStatus == 'Banyak',
          enabled: enabled,
          onTap: () {
            onSelected('Banyak');
          },
        ),
        _StatusChoice(
          label: 'Sikit',
          color: AppColors.warningYellow,
          icon: Icons.warning_amber,
          selected: selectedStatus == 'Sikit',
          enabled: enabled,
          onTap: () {
            onSelected('Sikit');
          },
        ),
        _StatusChoice(
          label: 'Habis',
          color: AppColors.soldOutRed,
          icon: Icons.cancel,
          selected: selectedStatus == 'Habis',
          enabled: enabled,
          onTap: () {
            onSelected('Habis');
          },
        ),
      ],
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.helper.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoUploadDummy extends StatelessWidget {
  const _PhotoUploadDummy();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            color: AppColors.durianGreen,
            size: 36,
          ),
          SizedBox(height: AppSpacing.s),
          Text(
            'Tambah gambar gerai / papan harga',
            style: AppTextStyles.cardTitle,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Fungsi upload gambar akan dibuat selepas Supabase Storage disambungkan.',
            textAlign: TextAlign.center,
            style: AppTextStyles.helper,
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.soldOutRed : AppColors.durianGreen;
    final backgroundColor = isError
        ? AppColors.soldOutRed.withValues(alpha: 0.08)
        : AppColors.paleGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.helper.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}