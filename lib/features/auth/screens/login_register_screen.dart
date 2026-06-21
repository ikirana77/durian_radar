import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitAuthForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final modeText = _isLoginMode
        ? 'Login dummy berjaya'
        : 'Daftar dummy berjaya';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.durianGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Text(
          '$modeText untuk $email. Auth sebenar akan dibuat selepas backend siap.',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _continueAsGuest() {
    Navigator.pop(context);
  }

  String? _validateName(String? value) {
    if (_isLoginMode) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Nama wajib diisi untuk daftar akaun.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Emel wajib diisi.';
    }

    if (!value.contains('@')) {
      return 'Masukkan emel yang sah.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kata laluan wajib diisi.';
    }

    if (value.length < 6) {
      return 'Kata laluan minimum 6 aksara.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            _AuthHeader(
              title: _isLoginMode ? 'Log Masuk' : 'Daftar Akaun',
              subtitle: _isLoginMode
                  ? 'Masuk ke akaun Durian Radar anda.'
                  : 'Cipta akaun Durian Radar baharu.',
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    _AuthHeroCard(isLoginMode: _isLoginMode),
                    const SizedBox(height: AppSpacing.l),
                    _AuthModeSwitch(
                      isLoginMode: _isLoginMode,
                      onChanged: (isLogin) {
                        if (isLogin != _isLoginMode) {
                          _toggleMode();
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLoginMode) ...[
                            _AuthTextField(
                              controller: _nameController,
                              label: 'Nama',
                              hint: 'Contoh: Intan Keristina',
                              icon: Icons.person_outline_rounded,
                              validator: _validateName,
                            ),
                            const SizedBox(height: AppSpacing.m),
                          ],
                          _AuthTextField(
                            controller: _emailController,
                            label: 'Emel',
                            hint: 'contoh@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          _AuthTextField(
                            controller: _passwordController,
                            label: 'Kata laluan',
                            hint: 'Minimum 6 aksara',
                            icon: Icons.lock_outline_rounded,
                            obscureText: !_isPasswordVisible,
                            validator: _validatePassword,
                            suffixIcon: IconButton(
                              onPressed: _togglePasswordVisibility,
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              color: AppColors.durianGreen,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          _PrimaryAuthButton(
                            label: _isLoginMode ? 'Log Masuk' : 'Daftar Akaun',
                            icon: _isLoginMode
                                ? Icons.login_rounded
                                : Icons.person_add_alt_rounded,
                            onPressed: _submitAuthForm,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _GuestButton(onPressed: _continueAsGuest),
                    const SizedBox(height: AppSpacing.l),
                    _AuthNoticeCard(isLoginMode: _isLoginMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.title,
    required this.subtitle,
    required this.onBackPressed,
  });

  final String title;
  final String subtitle;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.pageTitle),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.helper),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeroCard extends StatelessWidget {
  const _AuthHeroCard({required this.isLoginMode});

  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEEDFBF)),
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
            child: Icon(
              isLoginMode
                  ? Icons.verified_user_outlined
                  : Icons.person_add_alt_rounded,
              color: AppColors.durianGreen,
              size: 42,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isLoginMode ? 'Selamat Datang Semula' : 'Sertai Durian Radar',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.durianGreen,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            isLoginMode
                ? 'Login masih dummy buat masa ini. Paparan ini disediakan sebagai foundation sebelum Supabase Auth.'
                : 'Pendaftaran masih dummy buat masa ini. Nanti akaun ini akan disambungkan kepada backend sebenar.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6D756B),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({required this.isLoginMode, required this.onChanged});

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEEDFBF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthModeButton(
              label: 'Log Masuk',
              selected: isLoginMode,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _AuthModeButton(
              label: 'Daftar',
              selected: !isLoginMode,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.durianGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.durianGreen,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
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
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.durianGreen),
        suffixIcon: suffixIcon,
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

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
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

class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_outline_rounded),
        label: const Text('Teruskan sebagai Guest'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.durianGreen,
          side: const BorderSide(color: Color(0xFFEEDFBF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _AuthNoticeCard extends StatelessWidget {
  const _AuthNoticeCard({required this.isLoginMode});

  final bool isLoginMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEDFBF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warningYellow,
            size: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              isLoginMode
                  ? 'Untuk MVP ini, login belum mengubah status pengguna. Ia cuma UI foundation sebelum backend sebenar.'
                  : 'Pendaftaran ini belum menyimpan akaun sebenar. Data auth akan dibuat apabila Supabase Auth disambungkan.',
              style: const TextStyle(
                color: Color(0xFF6D756B),
                fontSize: 12.5,
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
