// lib/widgets/bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:student_productivity_tracker/themes/app_theme.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.card,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: Colors.white60,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: "Planner",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome),
          label: "AI",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: "Analytics",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}