import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _redirectUrl = 'durianradar://login-callback/';

  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;
  User? _user;
  bool _isSigningIn = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();

    _user = _supabase.auth.currentUser;

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) {
        return;
      }

      setState(() {
        _user = data.session?.user;
        _isSigningIn = false;
        _isSigningOut = false;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningIn = false;
      });

      _showSnack('Google login gagal. Sila cuba semula.');
    }
  }

  Future<void> _signOut() async {
    if (_isSigningOut) {
      return;
    }

    setState(() {
      _isSigningOut = true;
    });

    try {
      await _supabase.auth.signOut();

      if (!mounted) {
        return;
      }

      setState(() {
        _user = null;
        _isSigningOut = false;
      });

      _showSnack('Anda telah log keluar.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningOut = false;
      });

      _showSnack('Log keluar gagal. Sila cuba semula.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _displayName(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    return metadata['full_name']?.toString() ??
        metadata['name']?.toString() ??
        user.email ??
        'Pengguna Durian Radar';
  }

  String? _avatarUrl(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final avatar = metadata['avatar_url']?.toString();

    if (avatar == null || avatar.trim().isEmpty) {
      return null;
    }

    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: _ProfileColors.background,
      appBar: AppBar(
        backgroundColor: _ProfileColors.background,
        elevation: 0,
        foregroundColor: _ProfileColors.textDark,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.2),
        ),
      ),
      body: SafeArea(
        child: user == null
            ? _SignedOutView(
                isSigningIn: _isSigningIn,
                onGoogleTap: _signInWithGoogle,
              )
            : _SignedInView(
                user: user,
                displayName: _displayName(user),
                avatarUrl: _avatarUrl(user),
                isSigningOut: _isSigningOut,
                onSignOutTap: _signOut,
              ),
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView({required this.isSigningIn, required this.onGoogleTap});

  final bool isSigningIn;
  final VoidCallback onGoogleTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
          decoration: BoxDecoration(
            color: _ProfileColors.cardWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _ProfileColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: _ProfileColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: _ProfileColors.green,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Log masuk ke Durian Radar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ProfileColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar atau log masuk menggunakan akaun Google untuk simpan profil, kegemaran dan laporan anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ProfileColors.textMuted,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _GoogleAuthButton(isLoading: isSigningIn, onTap: onGoogleTap),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _InfoTile(
          icon: Icons.favorite_border_rounded,
          title: 'Simpan Kegemaran',
          subtitle: 'Akses semula gerai durian pilihan anda dengan mudah.',
        ),
        const SizedBox(height: 12),
        const _InfoTile(
          icon: Icons.verified_user_outlined,
          title: 'Laporan Lebih Terurus',
          subtitle: 'Laporan komuniti boleh dikaitkan dengan profil pengguna.',
        ),
      ],
    );
  }
}

class _SignedInView extends StatelessWidget {
  const _SignedInView({
    required this.user,
    required this.displayName,
    required this.avatarUrl,
    required this.isSigningOut,
    required this.onSignOutTap,
  });

  final User user;
  final String displayName;
  final String? avatarUrl;
  final bool isSigningOut;
  final VoidCallback onSignOutTap;

  @override
  Widget build(BuildContext context) {
    final email = user.email ?? 'Tiada email';

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
          decoration: BoxDecoration(
            color: _ProfileColors.cardWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _ProfileColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 43,
                backgroundColor: _ProfileColors.paleGreen,
                backgroundImage: avatarUrl == null
                    ? null
                    : NetworkImage(avatarUrl!),
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: _ProfileColors.green,
                        size: 42,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ProfileColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ProfileColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _ProfileColors.paleGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: _ProfileColors.green,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Google account connected',
                      style: TextStyle(
                        color: _ProfileColors.green,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSigningOut ? null : onSignOutTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _ProfileColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: isSigningOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    isSigningOut ? 'Sedang log keluar...' : 'Log Keluar',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoogleAuthButton extends StatelessWidget {
  const _GoogleAuthButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ProfileColors.textDark,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: isLoading ? null : onTap,
        child: Container(
          width: double.infinity,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: _ProfileColors.green,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Text(
                isLoading ? 'Membuka Google...' : 'Teruskan dengan Google',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
        color: _ProfileColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ProfileColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _ProfileColors.paleGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _ProfileColors.green, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ProfileColors.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _ProfileColors.textMuted,
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
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

class _ProfileColors {
  static const Color background = Color(0xFFF8F7F1);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color paleGreen = Color(0xFFE9F6DD);
  static const Color green = Color(0xFF2C7A35);
  static const Color red = Color(0xFFE94B46);
  static const Color textDark = Color(0xFF243527);
  static const Color textMuted = Color(0xFF738073);
  static const Color border = Color(0xFFE6E7DC);
}
