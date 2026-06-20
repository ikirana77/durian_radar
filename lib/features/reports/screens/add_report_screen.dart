import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AddReportScreen extends StatelessWidget {
  const AddReportScreen({super.key});

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
              const _AppTextField(
                label: 'Nama gerai / lokasi',
                hint: 'Contoh: Gerai Durian Bukit Rotan',
                icon: Icons.storefront,
              ),
              const SizedBox(height: AppSpacing.m),
              const _AppTextField(
                label: 'Kawasan',
                hint: 'Contoh: Kuala Selangor',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormSectionTitle(number: '2', title: 'Jenis & Harga'),
              const SizedBox(height: AppSpacing.m),
              const _AppTextField(
                label: 'Jenis durian',
                hint: 'Contoh: Musang King, D24, XO',
                icon: Icons.eco,
              ),
              const SizedBox(height: AppSpacing.m),
              const _AppTextField(
                label: 'Harga per kg',
                hint: 'Contoh: RM38',
                icon: Icons.sell,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormSectionTitle(number: '3', title: 'Status Stok'),
              const SizedBox(height: AppSpacing.m),
              const _StockStatusRow(),
              const SizedBox(height: AppSpacing.xl),
              const _PhotoUploadDummy(),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Dummy sahaja: fungsi hantar laporan akan disambung ke Supabase nanti.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Hantar Laporan'),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Center(
                child: TextButton(
                  onPressed: () {
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
              'Lokasi semasa akan digunakan selepas fungsi map/location disambungkan.',
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
    required this.label,
    required this.hint,
    required this.icon,
  });

  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.durianGreen, width: 2),
        ),
      ),
    );
  }
}

class _StockStatusRow extends StatelessWidget {
  const _StockStatusRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        _StatusChoice(
          label: 'Banyak',
          color: AppColors.freshGreen,
          icon: Icons.check_circle,
        ),
        _StatusChoice(
          label: 'Sikit',
          color: AppColors.warningYellow,
          icon: Icons.warning_amber,
        ),
        _StatusChoice(
          label: 'Habis',
          color: AppColors.soldOutRed,
          icon: Icons.cancel,
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
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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
