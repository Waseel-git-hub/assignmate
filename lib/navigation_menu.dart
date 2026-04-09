import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import your Home Screen
import 'screens/settings_screen.dart'; // Import your Settings Screen

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  // 1. This variable tracks which tab is selected (0 = Home, 1 = Settings)
  int _selectedIndex = 0;

  // 2. This list holds the actual screens
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0
    const SettingsScreen(), // Index 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. The body changes automatically based on the index
      body: _screens[_selectedIndex],

      // 4. The Bottom Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: _selectedIndex, // Tells the bar which icon to highlight
        onTap: (index) {
          // 5. When a user taps a tab, we update the index and REBUILD
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
