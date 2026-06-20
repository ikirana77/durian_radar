import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.durianGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              const _BrandHeader(),
              const SizedBox(height: AppSpacing.l),
              const _HeroIllustration(),
              const SizedBox(height: AppSpacing.l),
              const _AuthCard(),
              const SizedBox(height: AppSpacing.l),
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.eco,
                color: AppColors.durianGreen,
                size: 34,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            const Text('Durian Radar', style: AppTextStyles.appTitle),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        const Text(
          'Log masuk untuk lapor durian, simpan lokasi kegemaran dan bantu komuniti.',
          textAlign: TextAlign.center,
          style: AppTextStyles.helper,
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            bottom: 20,
            child: Icon(
              Icons.park,
              size: 60,
              color: AppColors.freshGreen.withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 18,
            child: Icon(
              Icons.location_on,
              size: 74,
              color: AppColors.durianYellow.withValues(alpha: 0.95),
            ),
          ),
          Positioned(
            top: 26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PersonBubble(icon: Icons.person, label: 'Pembeli'),
                const SizedBox(width: AppSpacing.m),
                _PersonBubble(icon: Icons.eco, label: 'Durian'),
                const SizedBox(width: AppSpacing.m),
                _PersonBubble(icon: Icons.storefront, label: 'Gerai'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonBubble extends StatelessWidget {
  const _PersonBubble({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.softCardWhite,
          child: Icon(icon, color: AppColors.durianGreen),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.helper.copyWith(
            color: AppColors.durianGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard();

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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _SegmentTabs(),
          const SizedBox(height: AppSpacing.l),
          const _AuthTextField(
            label: 'Email',
            hint: 'Email',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: AppSpacing.m),
          const _AuthTextField(
            label: 'Kata Laluan',
            hint: 'Kata Laluan',
            icon: Icons.lock_outline,
            obscureText: true,
            suffixIcon: Icons.visibility_outlined,
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Lupa kata laluan?'),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dummy sahaja. Login sebenar akan disambung ke Supabase Auth nanti.',
                    ),
                  ),
                );
              },
              child: const Text('Log Masuk'),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const _GoogleButton(),
          const SizedBox(height: AppSpacing.m),
          const _DividerWithText(text: 'atau'),
          const SizedBox(height: AppSpacing.m),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.person_outline),
            label: const Text('Teruskan sebagai tetamu'),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text('Belum ada akaun? ', style: AppTextStyles.helper),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Daftar sekarang',
                  style: AppTextStyles.helper.copyWith(
                    color: AppColors.durianGreen,
                    fontWeight: FontWeight.w700,
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

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.softCardWhite,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(color: AppColors.durianGreen),
              ),
              child: Text(
                'Log Masuk',
                textAlign: TextAlign.center,
                style: AppTextStyles.helper.copyWith(
                  color: AppColors.durianGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: Text(
                'Daftar',
                textAlign: TextAlign.center,
                style: AppTextStyles.helper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.durianGreen),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: AppColors.durianGreen),
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

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.durianGreen,
          side: const BorderSide(color: AppColors.durianGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dummy sahaja. Google Sign-In sebenar akan dibuat kemudian.',
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleLetterLogo(),
            const SizedBox(width: AppSpacing.s),
            Text(
              'Teruskan dengan Google',
              style: AppTextStyles.helper.copyWith(
                color: AppColors.durianGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLetterLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.red,
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderSoft)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(text, style: AppTextStyles.helper),
        ),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.verified_user, color: AppColors.freshGreen, size: 24),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            'Kami hanya guna maklumat anda untuk akaun dan laporan komuniti.',
            style: AppTextStyles.helper.copyWith(color: AppColors.mutedText),
          ),
        ),
      ],
    );
  }
}
