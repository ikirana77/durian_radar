import 'package:flutter/material.dart';

import 'features/home/screens/home_map_screen.dart';

class DurianRadarApp extends StatelessWidget {
  const DurianRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Durian Radar',
      debugShowCheckedModeBanner: false,
      home: HomeMapScreen(),
    );
  }
}
