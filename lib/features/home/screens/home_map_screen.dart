import 'package:flutter/material.dart';

import '../../profile/screens/profile_screen.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../reports/screens/add_report_screen.dart';

class HomeMapScreen extends StatelessWidget {
  const HomeMapScreen({super.key, this.showBottomNavigationBar = true});

  final bool showBottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DRColors.cream,
      body: Stack(
        children: [
          const Positioned.fill(child: _IllustratedMapArea()),

          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(bottom: false, child: _HomeTopPanel()),
          ),

          const Positioned(right: 22, bottom: 150, child: _LocateButton()),

          const Positioned(
            left: 28,
            bottom: 46,
            child: SizedBox(width: 270, child: _FloatingSummaryCard()),
          ),

          Positioned(
            right: 18,
            bottom: 42,
            child: _ReportFab(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReportScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: showBottomNavigationBar
          ? _HomeBottomBar(
              onFreshTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FreshListScreen(),
                  ),
                );
              },
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            )
          : null,
    );
  }
}

class _DRColors {
  static const Color cream = Color(0xFFFFF7E8);
  static const Color creamSoft = Color(0xFFFFFBF1);
  static const Color cardWhite = Color(0xFFFFFEF8);

  static const Color durianGreen = Color(0xFF1F6B3A);
  static const Color freshGreen = Color(0xFF5FAE43);
  static const Color paleGreen = Color(0xFFEAF6D9);

  static const Color durianYellow = Color(0xFFFFC72C);
  static const Color warningYellow = Color(0xFFF4B000);
  static const Color soldOutRed = Color(0xFFE83A2F);

  static const Color textDark = Color(0xFF173D25);
  static const Color textMuted = Color(0xFF6D756B);

  static const Color borderSoft = Color(0xFFEEDFBF);

  static const Color mapBase = Color(0xFFF3EBD8);
  static const Color mapRiver = Color(0xFFBFE3EA);
  static const Color mapGreen = Color(0xFFDCECCE);
  static const Color mapRoadYellow = Color(0xFFFFD97A);
}

class _DRAssets {
  static const String durianLogo = 'assets/images/durian_logo.png';
  static const String durianFull = 'assets/images/durian_full.png';
}

class _HomeTopPanel extends StatelessWidget {
  const _HomeTopPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
      decoration: BoxDecoration(
        color: _DRColors.creamSoft.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Image.asset(_DRAssets.durianLogo, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Durian Radar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: _DRColors.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              _IconCircle(icon: Icons.search_rounded, onTap: () {}),
              const SizedBox(width: 12),
              _IconCircle(
                icon: Icons.person_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: _DRColors.durianGreen,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Sekitar Kuala Selangor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _DRColors.durianGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final availableWidth = constraints.maxWidth - (gap * 2);

              return Row(
                children: [
                  SizedBox(
                    width: availableWidth * 0.30,
                    child: const _QuickChip(
                      label: 'Fresh',
                      icon: Icons.eco_rounded,
                      iconColor: _DRColors.freshGreen,
                    ),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: availableWidth * 0.40,
                    child: const _QuickChip(
                      label: 'Masih Ada',
                      icon: Icons.calendar_month_rounded,
                      iconColor: _DRColors.warningYellow,
                    ),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: availableWidth * 0.30,
                    child: const _QuickChip(
                      label: 'Murah',
                      icon: Icons.sell_rounded,
                      iconColor: _DRColors.warningYellow,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DRColors.cardWhite,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: _DRColors.durianGreen, size: 27),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: _DRColors.creamSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _DRColors.borderSoft, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: _DRColors.durianGreen,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustratedMapArea extends StatelessWidget {
  const _IllustratedMapArea();

  void _showMarkerDetail(
    BuildContext context, {
    required String stallName,
    required String area,
    required String variety,
    required String price,
    required String status,
    required String updatedTime,
    required Color statusColor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _DurianMarkerDetailSheet(
          stallName: stallName,
          area: area,
          variety: variety,
          price: price,
          status: status,
          updatedTime: updatedTime,
          statusColor: statusColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DRColors.mapBase,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _SoftMapPainter()),
              ),
              Positioned(
                top: height * 0.32,
                left: width * 0.55,
                child: _MapMarker(
                  label: 'MK',
                  color: _DRColors.freshGreen,
                  onTap: () {
                    _showMarkerDetail(
                      context,
                      stallName: 'Gerai Durian Bukit Rotan',
                      area: 'Bukit Rotan, Kuala Selangor',
                      variety: 'Musang King',
                      price: 'RM38/kg',
                      status: 'Masih Ada',
                      updatedTime: '12 min lepas',
                      statusColor: _DRColors.freshGreen,
                    );
                  },
                ),
              ),
              Positioned(
                top: height * 0.43,
                left: width * 0.25,
                child: _MapMarker(
                  label: 'D24',
                  color: _DRColors.warningYellow,
                  onTap: () {
                    _showMarkerDetail(
                      context,
                      stallName: 'Durian Tepi Jalan Assam Jawa',
                      area: 'Assam Jawa, Selangor',
                      variety: 'D24',
                      price: 'RM28/kg',
                      status: 'Stok Sikit',
                      updatedTime: '25 min lepas',
                      statusColor: _DRColors.warningYellow,
                    );
                  },
                ),
              ),
              Positioned(
                top: height * 0.49,
                right: width * 0.15,
                child: _MapMarker(
                  label: 'KG',
                  color: _DRColors.freshGreen,
                  onTap: () {
                    _showMarkerDetail(
                      context,
                      stallName: 'Durian Kampung Fresh',
                      area: 'Kuala Selangor',
                      variety: 'Kampung',
                      price: 'RM15/kg',
                      status: 'Masih Ada',
                      updatedTime: '2 jam lepas',
                      statusColor: _DRColors.freshGreen,
                    );
                  },
                ),
              ),
              Positioned(
                top: height * 0.60,
                left: width * 0.49,
                child: _MapMarker(
                  label: 'Habis',
                  color: _DRColors.soldOutRed,
                  onTap: () {
                    _showMarkerDetail(
                      context,
                      stallName: 'Warung Durian Bestari',
                      area: 'Puncak Alam',
                      variety: 'XO',
                      price: 'RM22/kg',
                      status: 'Dah Habis',
                      updatedTime: '1 jam lepas',
                      statusColor: _DRColors.soldOutRed,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool longLabel = label.length > 3;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 78,
        height: 84,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 8,
              child: Icon(
                Icons.location_on_rounded,
                size: 70,
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ),
            const Positioned(
              top: 0,
              child: Icon(
                Icons.location_on_rounded,
                size: 74,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 4,
              child: Icon(Icons.location_on_rounded, size: 66, color: color),
            ),
            Positioned(
              top: 24,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: longLabel ? 13 : 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurianMarkerDetailSheet extends StatelessWidget {
  const _DurianMarkerDetailSheet({
    required this.stallName,
    required this.area,
    required this.variety,
    required this.price,
    required this.status,
    required this.updatedTime,
    required this.statusColor,
  });

  final String stallName;
  final String area;
  final String variety;
  final String price;
  final String status;
  final String updatedTime;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: _DRColors.cardWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: _DRColors.borderSoft,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: _DRColors.paleGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      _DRAssets.durianFull,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stallName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _DRColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: _DRColors.durianGreen,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _DRColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DetailInfoPill(
                    label: 'Jenis',
                    value: variety,
                    icon: Icons.eco_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DetailInfoPill(
                    label: 'Harga',
                    value: price,
                    icon: Icons.sell_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    updatedTime,
                    style: const TextStyle(
                      color: _DRColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border_rounded),
                    label: const Text('Simpan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _DRColors.durianGreen,
                      side: const BorderSide(color: _DRColors.borderSoft),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.near_me_rounded),
                    label: const Text('Arahkan Saya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DRColors.durianGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailInfoPill extends StatelessWidget {
  const _DetailInfoPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _DRColors.creamSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DRColors.borderSoft),
      ),
      child: Row(
        children: [
          Icon(icon, color: _DRColors.warningYellow, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _DRColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _DRColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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

class _LocateButton extends StatelessWidget {
  const _LocateButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _DRColors.cardWhite,
        shape: BoxShape.circle,
        border: Border.all(color: _DRColors.borderSoft, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.my_location_rounded,
        color: _DRColors.durianGreen,
        size: 31,
      ),
    );
  }
}

class _FloatingSummaryCard extends StatelessWidget {
  const _FloatingSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: _DRColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: _DRColors.paleGreen,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(_DRAssets.durianFull, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '12 lokasi fresh hari ini',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _DRColors.durianGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Harga serendah RM15/kg',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _DRColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: _DRColors.freshGreen,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Update terbaru: 8 min lepas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _DRColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportFab extends StatelessWidget {
  const _ReportFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 108,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: _DRColors.durianYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: _DRColors.creamSoft, width: 7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: _DRColors.textDark,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _DRColors.creamSoft.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Laporkan Durian',
                maxLines: 1,
                style: TextStyle(
                  color: _DRColors.textDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({required this.onFreshTap, required this.onProfileTap});

  final VoidCallback onFreshTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 34),
        decoration: BoxDecoration(
          color: _DRColors.creamSoft,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _BottomNavItem(
              icon: Icons.map_rounded,
              label: 'Map',
              selected: true,
            ),
            _BottomNavItem(
              icon: Icons.eco_outlined,
              label: 'Fresh',
              selected: false,
              onTap: onFreshTap,
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Saya',
              selected: false,
              onTap: onProfileTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _DRColors.durianGreen : const Color(0xFF2E302E);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 34 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: _DRColors.durianGreen,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftMapPainter extends CustomPainter {
  const _SoftMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _DRColors.mapBase);

    final greenPaint = Paint()
      ..color = _DRColors.mapGreen.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.80, size.height * 0.20, 130, 170),
      greenPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.52, 90, 140),
      greenPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.66, size.height * 0.63, 150, 120),
      greenPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.25, 86, 70),
      greenPaint,
    );

    final riverPaint = Paint()
      ..color = _DRColors.mapRiver
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverLeft = Path()
      ..moveTo(-20, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.10,
        size.height * 0.46,
        size.width * 0.03,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.00,
        size.height * 0.84,
        size.width * 0.12,
        size.height + 30,
      );

    final riverBottom = Path()
      ..moveTo(size.width * 0.10, size.height * 0.86)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.77,
        size.width * 0.58,
        size.height * 0.90,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height,
        size.width + 30,
        size.height * 0.84,
      );

    canvas.drawPath(riverLeft, riverPaint);
    canvas.drawPath(riverBottom, riverPaint);

    _drawMajorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.02, size.height * 0.31)
        ..quadraticBezierTo(
          size.width * 0.36,
          size.height * 0.20,
          size.width * 0.74,
          size.height * 0.36,
        )
        ..quadraticBezierTo(
          size.width * 0.90,
          size.height * 0.42,
          size.width * 1.06,
          size.height * 0.39,
        ),
    );

    _drawMajorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.46, -20)
        ..quadraticBezierTo(
          size.width * 0.48,
          size.height * 0.28,
          size.width * 0.43,
          size.height * 0.50,
        )
        ..quadraticBezierTo(
          size.width * 0.39,
          size.height * 0.70,
          size.width * 0.50,
          size.height + 30,
        ),
    );

    _drawMajorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.18, size.height * 1.02)
        ..quadraticBezierTo(
          size.width * 0.42,
          size.height * 0.74,
          size.width * 0.60,
          size.height * 0.58,
        )
        ..quadraticBezierTo(
          size.width * 0.77,
          size.height * 0.42,
          size.width * 0.88,
          size.height * 0.06,
        ),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.05, size.height * 0.44)
        ..lineTo(size.width * 0.92, size.height * 0.30),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.12, size.height * 0.58)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.48,
          size.width * 0.90,
          size.height * 0.55,
        ),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.20, size.height * 0.25)
        ..quadraticBezierTo(
          size.width * 0.38,
          size.height * 0.43,
          size.width * 0.70,
          size.height * 0.70,
        ),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.14, size.height * 0.70)
        ..lineTo(size.width * 0.86, size.height * 0.72),
    );

    _drawMinorRoad(
      canvas,
      Path()
        ..moveTo(size.width * 0.70, size.height * 0.18)
        ..lineTo(size.width * 0.55, size.height * 0.82),
    );

    _drawText(
      canvas,
      'KUALA\nSELANGOR',
      Offset(size.width * 0.27, size.height * 0.28),
      size: 15,
      weight: FontWeight.w800,
    );

    _drawText(
      canvas,
      'Taman\nMelawati',
      Offset(size.width * 0.54, size.height * 0.26),
      size: 11,
    );

    _drawText(
      canvas,
      'Kampung\nBukit Rotan',
      Offset(size.width * 0.45, size.height * 0.46),
      size: 11,
    );

    _drawText(
      canvas,
      'Bestari\nJaya',
      Offset(size.width * 0.83, size.height * 0.59),
      size: 11,
    );

    _drawText(
      canvas,
      'Sungai\nSelangor',
      Offset(size.width * 0.08, size.height * 0.66),
      size: 10,
      color: const Color(0xFF438BA0),
    );

    _drawRouteLabel(
      canvas,
      'B18',
      Offset(size.width * 0.46, size.height * 0.22),
    );

    _drawRouteLabel(
      canvas,
      'AH2',
      Offset(size.width * 0.76, size.height * 0.36),
      blue: true,
    );
  }

  void _drawMajorRoad(Canvas canvas, Path path) {
    final outerPaint = Paint()
      ..color = _DRColors.mapRoadYellow
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final innerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, innerPaint);
  }

  void _drawMinorRoad(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.62)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double size = 12,
    Color color = const Color(0xFF7B817B),
    FontWeight weight = FontWeight.w600,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          height: 1.1,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    textPainter.paint(canvas, offset);
  }

  void _drawRouteLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    bool blue = false,
  }) {
    final rect = Rect.fromLTWH(offset.dx, offset.dy, 28, 16);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    final paint = Paint()
      ..color = blue ? const Color(0xFF3D8ADB) : const Color(0xFFFFD34F);

    canvas.drawRRect(rrect, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        offset.dx + (28 - textPainter.width) / 2,
        offset.dy + (16 - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
