import 'package:flutter/material.dart';

import '../../../shared/widgets/durian_bottom_nav.dart';
import '../../fresh/screens/fresh_list_screen.dart';
import '../../home/screens/home_map_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../data/navigation_store.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeMapScreen(showBottomNavigationBar: false),
    FreshListScreen(showBottomNavigationBar: false),
    ProfileScreen(showBottomNavigationBar: false),
  ];

  @override
  void initState() {
    super.initState();
    navigationStore.addListener(_handleExternalNavigation);
  }

  @override
  void dispose() {
    navigationStore.removeListener(_handleExternalNavigation);
    super.dispose();
  }

  void _handleExternalNavigation() {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = navigationStore.value;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    navigationStore.goToIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: DurianBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
