import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/map/screens/home_map_screen.dart';

class DurianRadarApp extends StatelessWidget {
  const DurianRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Durian Radar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeMapScreen(),
    );
  }
}
