import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DurianBottomNav extends StatelessWidget {
  const DurianBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.softCardWhite,
      indicatorColor: AppColors.paleGreen,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Map',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_fire_department_outlined),
          selectedIcon: Icon(Icons.local_fire_department),
          label: 'Fresh',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Saya',
        ),
      ],
    );
  }
}
