import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../auth/screens/login_register_screen.dart';
import '../../durian/data/durian_report_store.dart';
import '../../durian/models/durian_report.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../home/screens/home_map_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBottomNavigationBar = true});

  final bool showBottomNavigationBar;

  void _resetDummyData(BuildContext context) {
    durianReportStore.resetToDummyData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.durianGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: const Text(
          'Dummy data telah direset semula.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _openLoginRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            const Text('Saya', style: AppTextStyles.pageTitle),
            const SizedBox(height: 6),
            const Text(
              'Akaun, laporan dan tetapan pengguna',
              style: AppTextStyles.helper,
            ),
            const SizedBox(height: AppSpacing.l),
            _LoginPromptCard(onLoginPressed: () => _openLoginRegister(context)),
            const SizedBox(height: AppSpacing.l),
            const _ProfileMenuCard(
              icon: Icons.receipt_long_rounded,
              title: 'Laporan Saya',
              subtitle: 'Lihat durian yang pernah anda laporkan',
            ),
            const SizedBox(height: AppSpacing.s),
            const _ProfileMenuCard(
              icon: Icons.bookmark_border_rounded,
              title: 'Lokasi Disimpan',
              subtitle: 'Simpan lokasi durian kegemaran',
            ),
            const SizedBox(height: AppSpacing.s),
            const _ProfileMenuCard(
              icon: Icons.notifications_none_rounded,
              title: 'Notifikasi',
              subtitle: 'Amaran lokasi fresh dan harga murah',
            ),
            const SizedBox(height: AppSpacing.s),
            const _ProfileMenuCard(
              icon: Icons.settings_outlined,
              title: 'Tetapan',
              subtitle: 'Bahasa, privasi dan pilihan aplikasi',
            ),
            const SizedBox(height: AppSpacing.l),
            _DeveloperToolsCard(onResetPressed: () => _resetDummyData(context)),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNavigationBar
          ? DurianBottomNav(
              selectedIndex: 2,
              onDestinationSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeMapScreen(),
                    ),
                  );
                }

                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FreshListScreen(),
                    ),
                  );
                }
              },
            )
          : null,
    );
  }
}

class _LoginPromptCard extends StatelessWidget {
  const _LoginPromptCard({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF6D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.durianGreen,
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Log Masuk',
            style: TextStyle(
              color: AppColors.durianGreen,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Log masuk untuk simpan laporan durian, lokasi kegemaran dan sejarah carian.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6D756B),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Log Masuk / Daftar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.durianGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEDFBF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1C2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.warningYellow),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.durianGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6D756B),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6D756B)),
        ],
      ),
    );
  }
}

class _DeveloperToolsCard extends StatelessWidget {
  const _DeveloperToolsCard({required this.onResetPressed});

  final VoidCallback onResetPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DurianReport>>(
      valueListenable: durianReportStore,
      builder: (context, reports, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF1),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.developer_mode_rounded,
                    color: AppColors.durianGreen,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Developer Tools',
                      style: TextStyle(
                        color: AppColors.durianGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Kawasan ini untuk testing app sahaja. Nanti boleh disembunyikan sebelum release.',
                style: TextStyle(
                  color: Color(0xFF6D756B),
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEEDFBF)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEAF6D9),
                      child: Icon(
                        Icons.radar_rounded,
                        color: AppColors.durianGreen,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${reports.length} laporan dalam memory',
                        style: const TextStyle(
                          color: Color(0xFF173D25),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onResetPressed,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset Dummy Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.soldOutRed,
                    side: const BorderSide(color: AppColors.soldOutRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
