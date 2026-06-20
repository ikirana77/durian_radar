import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../../shared/widgets/durian_summary_card.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../reports/screens/add_report_screen.dart';
import '../../auth/screens/login_register_screen.dart';

class HomeMapScreen extends StatelessWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              SizedBox(height: AppSpacing.l),
              _FilterRow(),
              SizedBox(height: AppSpacing.l),
              Expanded(child: _DummyMapArea()),
              SizedBox(height: AppSpacing.l),
              DurianSummaryCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          backgroundColor: AppColors.durianYellow,
          foregroundColor: AppColors.textCharcoal,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddReportScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: DurianBottomNav(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FreshListScreen()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginRegisterScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.eco, color: AppColors.durianGreen),
        ),
        const SizedBox(width: AppSpacing.m),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Durian Radar', style: AppTextStyles.appTitle),
              SizedBox(height: 2),
              Text(
                'Cari durian fresh sekitar anda',
                style: AppTextStyles.helper,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.search),
          color: AppColors.durianGreen,
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.person_outline),
          color: AppColors.durianGreen,
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppFilterChip(label: 'Fresh', icon: Icons.flash_on),
          SizedBox(width: AppSpacing.s),
          AppFilterChip(label: 'Masih Ada', icon: Icons.check_circle),
          SizedBox(width: AppSpacing.s),
          AppFilterChip(label: 'Murah', icon: Icons.sell),
          SizedBox(width: AppSpacing.s),
          AppFilterChip(label: 'Sekitar saya', icon: Icons.near_me),
        ],
      ),
    );
  }
}

class _DummyMapArea extends StatelessWidget {
  const _DummyMapArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE7D1),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
          const Positioned(
            top: 80,
            left: 70,
            child: _MapMarker(label: 'MK', color: AppColors.freshGreen),
          ),
          const Positioned(
            top: 160,
            right: 80,
            child: _MapMarker(label: 'D24', color: AppColors.warningYellow),
          ),
          const Positioned(
            bottom: 110,
            left: 110,
            child: _MapMarker(label: 'XO', color: AppColors.soldOutRed),
          ),
          const Positioned(bottom: 60, right: 40, child: _LocateButton()),
          const Positioned(left: 20, bottom: 24, child: _MapHintCard()),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_drop_down,
          color: AppColors.textCharcoal,
          size: 24,
        ),
      ],
    );
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.my_location, color: AppColors.durianGreen),
    );
  }
}

class _MapHintCard extends StatelessWidget {
  const _MapHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.softCardWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.durianGreen),
          SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              '12 lokasi fresh hari ini. Harga semasa dikemaskini komuniti.',
              style: AppTextStyles.helper,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPaint = Paint()
      ..color = const Color(0xFFB8DDE6).withValues(alpha: 0.8)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(20, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.15,
        size.width - 30,
        size.height * 0.35,
      );

    final roadPath2 = Path()
      ..moveTo(size.width * 0.2, size.height - 20)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.55,
        size.width * 0.8,
        30,
      );

    final riverPath = Path()
      ..moveTo(10, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.65,
        size.width - 10,
        size.height * 0.85,
      );

    canvas.drawPath(roadPath, roadPaint);
    canvas.drawPath(roadPath2, roadPaint);
    canvas.drawPath(riverPath, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
