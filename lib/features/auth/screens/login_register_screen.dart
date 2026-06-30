import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _statusMessage;
  bool _isStatusError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('AUTH DEBUG: Button pressed.');
    debugPrint('AUTH DEBUG: Mode = ${_isRegisterMode ? "register" : "login"}');
    debugPrint('AUTH DEBUG: Email = $email');

    if (email.isEmpty || password.isEmpty) {
      _showStatus('Sila masukkan email dan kata laluan.', isError: true);
      return;
    }

    if (!email.contains('@')) {
      _showStatus('Sila masukkan email yang sah.', isError: true);
      return;
    }

    if (_isRegisterMode && password.length < 6) {
      _showStatus(
        'Kata laluan mesti sekurang-kurangnya 6 aksara.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = _isRegisterMode
          ? 'Sedang mendaftar akaun...'
          : 'Sedang log masuk...';
      _isStatusError = false;
    });

    try {
      if (_isRegisterMode) {
        final response = await AuthService.signUpWithEmail(
          email: email,
          password: password,
        );

        debugPrint('AUTH DEBUG: Register response user = ${response.user?.id}');
        debugPrint(
          'AUTH DEBUG: Register response session = ${response.session != null}',
        );

        if (!mounted) return;

        if (response.session != null) {
          _showStatus(
            'Akaun berjaya didaftarkan dan anda telah log masuk.',
          );

          await Future<void>.delayed(const Duration(milliseconds: 900));

          if (!mounted) return;
          Navigator.pop(context, true);
          return;
        }

        _showStatus(
          'Akaun berjaya didaftarkan. Sila semak email jika pengesahan diperlukan.',
        );

        setState(() {
          _isRegisterMode = false;
        });
      } else {
        final response = await AuthService.signInWithEmail(
          email: email,
          password: password,
        );

        debugPrint('AUTH DEBUG: Login response user = ${response.user?.id}');
        debugPrint(
          'AUTH DEBUG: Login response session = ${response.session != null}',
        );

        if (!mounted) return;

        if (response.session == null) {
          _showStatus(
            'Login belum lengkap. Sila semak pengesahan email.',
            isError: true,
          );
          return;
        }

        _showStatus('Log masuk berjaya.');

        await Future<void>.delayed(const Duration(milliseconds: 900));

        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (error) {
      debugPrint('AUTH DEBUG ERROR: $error');

      if (!mounted) return;

      _showStatus(
        AuthService.getReadableError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _toggleAuthMode(bool registerMode) {
    if (_isLoading) return;

    setState(() {
      _isRegisterMode = registerMode;
      _statusMessage = null;
      _isStatusError = false;
    });
  }

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
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context, false);
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
              _AuthCard(
                emailController: _emailController,
                passwordController: _passwordController,
                isRegisterMode: _isRegisterMode,
                isPasswordVisible: _isPasswordVisible,
                isLoading: _isLoading,
                statusMessage: _statusMessage,
                isStatusError: _isStatusError,
                onToggleMode: _toggleAuthMode,
                onTogglePasswordVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                onSubmit: _submitAuth,
                onGuestContinue: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context, false);
                      },
              ),
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
  const _PersonBubble({
    required this.icon,
    required this.label,
  });

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
  const _AuthCard({
    required this.emailController,
    required this.passwordController,
    required this.isRegisterMode,
    required this.isPasswordVisible,
    required this.isLoading,
    required this.statusMessage,
    required this.isStatusError,
    required this.onToggleMode,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.onGuestContinue,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isRegisterMode;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? statusMessage;
  final bool isStatusError;
  final ValueChanged<bool> onToggleMode;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSubmit;
  final VoidCallback? onGuestContinue;

  @override
  Widget build(BuildContext context) {
    final buttonText = isRegisterMode ? 'Daftar Akaun' : 'Log Masuk';

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
          _SegmentTabs(
            isRegisterMode: isRegisterMode,
            onToggleMode: onToggleMode,
          ),
          const SizedBox(height: AppSpacing.l),
          _AuthTextField(
            controller: emailController,
            label: 'Email',
            hint: 'nama@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.m),
          _AuthTextField(
            controller: passwordController,
            label: 'Kata Laluan',
            hint: 'Minimum 6 aksara',
            icon: Icons.lock_outline,
            obscureText: !isPasswordVisible,
            enabled: !isLoading,
            suffixIcon: IconButton(
              onPressed: isLoading ? null : onTogglePasswordVisibility,
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.durianGreen,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          if (statusMessage != null) ...[
            _StatusBox(
              message: statusMessage!,
              isError: isStatusError,
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          if (!isRegisterMode)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fungsi reset kata laluan akan dibuat dalam checkpoint seterusnya.',
                              ),
                            ),
                          );
                      },
                child: const Text('Lupa kata laluan?'),
              ),
            ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(buttonText),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const _GoogleButton(),
          const SizedBox(height: AppSpacing.m),
          const _DividerWithText(text: 'atau'),
          const SizedBox(height: AppSpacing.m),
          TextButton.icon(
            onPressed: onGuestContinue,
            icon: const Icon(Icons.person_outline),
            label: const Text('Teruskan sebagai tetamu'),
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                isRegisterMode ? 'Sudah ada akaun? ' : 'Belum ada akaun? ',
                style: AppTextStyles.helper,
              ),
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        onToggleMode(!isRegisterMode);
                      },
                child: Text(
                  isRegisterMode ? 'Log masuk' : 'Daftar sekarang',
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

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : AppColors.durianGreen;
    final backgroundColor = isError
        ? Colors.red.withValues(alpha: 0.08)
        : AppColors.paleGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.isRegisterMode,
    required this.onToggleMode,
  });

  final bool isRegisterMode;
  final ValueChanged<bool> onToggleMode;

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
            child: _SegmentTabButton(
              text: 'Log Masuk',
              isSelected: !isRegisterMode,
              onTap: () {
                onToggleMode(false);
              },
            ),
          ),
          Expanded(
            child: _SegmentTabButton(
              text: 'Daftar',
              isSelected: isRegisterMode,
              onTap: () {
                onToggleMode(true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTabButton extends StatelessWidget {
  const _SegmentTabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? AppColors.durianGreen : AppColors.mutedText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softCardWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: isSelected
              ? Border.all(color: AppColors.durianGreen)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.helper.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.durianGreen),
        suffixIcon: suffixIcon,
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
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Google Sign-In akan dibuat selepas konfigurasi OAuth Supabase.',
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