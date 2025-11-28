import 'package:flutter/material.dart';
import 'package:grinder/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.items,
    this.backgroundColor = AppColors.background,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showUnselectedLabels = true,
    this.type = BottomNavigationBarType.fixed,
    this.elevation = 0,
  });

  static const List<BottomNavigationBarItem> defaultItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.show_chart_rounded),
      label: 'Progress',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
  ];

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavigationBarItem>? items;
  final Color backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showUnselectedLabels;
  final BottomNavigationBarType type;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final Color fallbackSelected = AppColors.primary;
    final Color fallbackUnselected = AppColors.navUnselected;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 2, color: AppColors.navSeparator),
        BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: backgroundColor,
          elevation: elevation,
          selectedItemColor: selectedItemColor ?? fallbackSelected,
          unselectedItemColor: unselectedItemColor ?? fallbackUnselected,
          showUnselectedLabels: showUnselectedLabels,
          type: type,
          items: items ?? defaultItems,
          onTap: onTap,
        ),
      ],
    );
  }
}
