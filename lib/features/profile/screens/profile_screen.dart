import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/screens/login_register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      await AuthService.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Anda telah log keluar.')));

      setState(() {
        _isSigningOut = false;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(AuthService.getReadableError(error))),
        );

      setState(() {
        _isSigningOut = false;
      });
    }
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isLoggedIn = user != null;
    final email = user?.email ?? 'Tetamu';

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.creamBackground,
        elevation: 0,
        foregroundColor: AppColors.durianGreen,
        title: const Text('Profil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(isLoggedIn: isLoggedIn, email: email),
              const SizedBox(height: AppSpacing.l),
              if (isLoggedIn) ...[
                _InfoCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Akaun Aktif',
                  description:
                      'Anda boleh menghantar laporan durian dan membantu komuniti.',
                ),
                const SizedBox(height: AppSpacing.m),
                _InfoCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  description: email,
                ),
                const SizedBox(height: AppSpacing.l),
                ElevatedButton.icon(
                  onPressed: _isSigningOut ? null : _signOut,
                  icon: _isSigningOut
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    _isSigningOut ? 'Sedang log keluar...' : 'Log Keluar',
                  ),
                ),
              ] else ...[
                _InfoCard(
                  icon: Icons.person_outline,
                  title: 'Anda sedang guna mod tetamu',
                  description:
                      'Log masuk untuk simpan aktiviti dan hantar laporan komuniti.',
                ),
                const SizedBox(height: AppSpacing.l),
                ElevatedButton.icon(
                  onPressed: _goToLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Log Masuk / Daftar'),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              const _InfoCard(
                icon: Icons.info_outline,
                title: 'Durian Radar',
                description:
                    'Aplikasi komuniti untuk mencari lokasi durian segar secara terkini.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isLoggedIn, required this.email});

  final bool isLoggedIn;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.paleGreen,
            child: Icon(
              isLoggedIn ? Icons.person : Icons.person_outline,
              color: AppColors.durianGreen,
              size: 46,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            isLoggedIn ? 'Akaun Durian Radar' : 'Tetamu',
            style: AppTextStyles.appTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            email,
            style: AppTextStyles.helper.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.paleGreen,
            child: Icon(icon, color: AppColors.durianGreen),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.helper.copyWith(
                    color: AppColors.durianGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.helper.copyWith(
                    color: AppColors.mutedText,
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
