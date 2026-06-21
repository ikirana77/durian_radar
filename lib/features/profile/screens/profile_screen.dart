import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../auth/screens/login_register_screen.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../home/screens/home_map_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBottomNavigationBar = true});

  final bool showBottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: const [
            Text('Saya', style: AppTextStyles.pageTitle),
            SizedBox(height: 6),
            Text(
              'Akaun, laporan dan tetapan pengguna',
              style: AppTextStyles.helper,
            ),
            SizedBox(height: AppSpacing.l),
            _LoginPromptCard(),
            SizedBox(height: AppSpacing.l),
            _ProfileMenuCard(
              icon: Icons.receipt_long_rounded,
              title: 'Laporan Saya',
              subtitle: 'Lihat durian yang pernah anda laporkan',
            ),
            SizedBox(height: AppSpacing.s),
            _ProfileMenuCard(
              icon: Icons.bookmark_border_rounded,
              title: 'Lokasi Disimpan',
              subtitle: 'Simpan lokasi durian kegemaran',
            ),
            SizedBox(height: AppSpacing.s),
            _ProfileMenuCard(
              icon: Icons.notifications_none_rounded,
              title: 'Notifikasi',
              subtitle: 'Amaran lokasi fresh dan harga murah',
            ),
            SizedBox(height: AppSpacing.s),
            _ProfileMenuCard(
              icon: Icons.settings_outlined,
              title: 'Tetapan',
              subtitle: 'Bahasa, privasi dan pilihan aplikasi',
            ),
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
  const _LoginPromptCard();

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginRegisterScreen(),
                  ),
                );
              },
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
