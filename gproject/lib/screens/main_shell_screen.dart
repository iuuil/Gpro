import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ministries_screen.dart';
import 'complaints_center_screen.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  // ignore: library_private_types_in_public_api
  static _MainShellScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainShellScreenState>();
  }

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  // ignore: prefer_final_fields, unused_field
  bool _isDark = false;

  List<Widget> get _pages => [
        HomeScreen(),              // 0: الرئيسية
        MinistriesScreen(),        // 1: الوزارات
        ComplaintsCenterScreen(),  // 2: الشكاوى
        SettingsScreen(),          // 3: الإعدادات
        ProfileScreen(),           // 4: الحساب
      ];

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: _pages[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
          selectedItemColor:
              theme.bottomNavigationBarTheme.selectedItemColor ??
                  HomeScreen.primaryColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor ??
                  const Color(0xFF9CA3AF),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              label: 'الوزارات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_problem_outlined),
              label: 'الشكاوى',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'الإعدادات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'الحساب',
            ),
          ],
        ),
      ),
    );
  }
}