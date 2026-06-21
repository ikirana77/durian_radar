import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../durian/data/durian_report_store.dart';
import '../../durian/models/durian_report.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DurianStockStatus _selectedStatus = DurianStockStatus.available;

  @override
  void dispose() {
    _stallNameController.dispose();
    _areaController.dispose();
    _varietyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitReport() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final stallName = _stallNameController.text.trim();
    final area = _areaController.text.trim();
    final variety = _varietyController.text.trim();
    final price = _priceController.text.trim();

    final report = DurianReport(
      id: 'DR${DateTime.now().millisecondsSinceEpoch}',
      markerLabel: _markerLabelFromVariety(variety),
      stallName: stallName,
      area: area,
      variety: variety,
      price: price,
      stockStatus: _selectedStatus,
      statusText: _statusText(_selectedStatus),
      updatedTime: 'Baru sahaja',
    );

    durianReportStore.addReport(report);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.durianGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Text(
          'Laporan diterima: $stallName, $area, $variety, $price',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    Navigator.pop(context);
  }

  String _markerLabelFromVariety(String variety) {
    final cleaned = variety.trim().toUpperCase();

    if (cleaned.isEmpty) {
      return 'NEW';
    }

    if (cleaned.contains('MUSANG')) {
      return 'MK';
    }

    if (cleaned.contains('KAMPUNG')) {
      return 'KG';
    }

    if (cleaned.length <= 4) {
      return cleaned;
    }

    return cleaned.substring(0, 3);
  }

  String _statusText(DurianStockStatus status) {
    switch (status) {
      case DurianStockStatus.available:
        return 'Masih Ada';
      case DurianStockStatus.lowStock:
        return 'Stok Sikit';
      case DurianStockStatus.soldOut:
        return 'Dah Habis';
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

  IconData _statusIcon(DurianStockStatus status) {
    switch (status) {
      case DurianStockStatus.available:
        return Icons.check_circle_rounded;
      case DurianStockStatus.lowStock:
        return Icons.warning_amber_rounded;
      case DurianStockStatus.soldOut:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            _ReportHeader(onBackPressed: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _IntroCard(),
                      const SizedBox(height: AppSpacing.l),
                      const _SectionTitle(
                        title: 'Maklumat Gerai',
                        subtitle: 'Masukkan maklumat asas lokasi durian.',
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _DurianTextField(
                        controller: _stallNameController,
                        label: 'Nama gerai',
                        hint: 'Contoh: Gerai Durian Bukit Rotan',
                        icon: Icons.storefront_rounded,
                        validatorMessage: 'Nama gerai wajib diisi.',
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _DurianTextField(
                        controller: _areaController,
                        label: 'Kawasan',
                        hint: 'Contoh: Bukit Rotan, Kuala Selangor',
                        icon: Icons.location_on_rounded,
                        validatorMessage: 'Kawasan wajib diisi.',
                      ),
                      const SizedBox(height: AppSpacing.l),
                      const _SectionTitle(
                        title: 'Maklumat Durian',
                        subtitle: 'Nyatakan jenis, harga dan status stok.',
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _DurianTextField(
                        controller: _varietyController,
                        label: 'Jenis durian',
                        hint: 'Contoh: Musang King, D24, Kampung, XO',
                        icon: Icons.eco_rounded,
                        validatorMessage: 'Jenis durian wajib diisi.',
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _DurianTextField(
                        controller: _priceController,
                        label: 'Harga',
                        hint: 'Contoh: RM38/kg',
                        icon: Icons.sell_rounded,
                        keyboardType: TextInputType.text,
                        validatorMessage: 'Harga wajib diisi.',
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _StockStatusSelector(
                        selectedStatus: _selectedStatus,
                        statusText: _statusText,
                        statusColor: _statusColor,
                        statusIcon: _statusIcon,
                        onChanged: (status) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.l),
                      const _SectionTitle(
                        title: 'Nota Tambahan',
                        subtitle: 'Optional, tapi berguna untuk pengguna lain.',
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _DurianTextField(
                        controller: _noteController,
                        label: 'Nota ringkas',
                        hint:
                            'Contoh: Parking tepi jalan, gerai buka sampai malam.',
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SubmitButton(onPressed: _submitReport),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.durianGreen,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporkan Durian', style: AppTextStyles.pageTitle),
                SizedBox(height: 3),
                Text(
                  'Bantu pengguna lain jumpa durian fresh',
                  style: AppTextStyles.helper,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEEDFBF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF6D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: AppColors.durianGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Laporan akan masuk ke senarai Fresh Hari Ini secara sementara. Nanti kita sambungkan kepada database Supabase.',
              style: TextStyle(
                color: Color(0xFF6D756B),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.durianGreen,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6D756B),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DurianTextField extends StatelessWidget {
  const _DurianTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.isRequired = true,
    this.validatorMessage,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final bool isRequired;
  final String? validatorMessage;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (!isRequired) {
          return null;
        }

        if (value == null || value.trim().isEmpty) {
          return validatorMessage ?? 'Medan ini wajib diisi.';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.durianGreen),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: AppColors.durianGreen,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9B9F98),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFEEDFBF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: AppColors.durianGreen,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.soldOutRed, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.soldOutRed, width: 1.4),
        ),
      ),
    );
  }
}

class _StockStatusSelector extends StatelessWidget {
  const _StockStatusSelector({
    required this.selectedStatus,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.onChanged,
  });

  final DurianStockStatus selectedStatus;
  final String Function(DurianStockStatus status) statusText;
  final Color Function(DurianStockStatus status) statusColor;
  final IconData Function(DurianStockStatus status) statusIcon;
  final ValueChanged<DurianStockStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final statuses = DurianStockStatus.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status stok',
          style: TextStyle(
            color: AppColors.durianGreen,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: statuses.map((status) {
            final isSelected = selectedStatus == status;
            final color = statusColor(status);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: status == statuses.last ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.16)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFEEDFBF),
                        width: isSelected ? 1.4 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(statusIcon(status), color: color, size: 24),
                        const SizedBox(height: 7),
                        Text(
                          statusText(status),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? color : const Color(0xFF6D756B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.send_rounded),
        label: const Text('Hantar Laporan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.durianGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
