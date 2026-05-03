import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'ministries_screen.dart';
import 'complaints_center_screen.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  // حتى نقدر نغيّر التاب من أي صفحة داخلية
  // ignore: library_private_types_in_public_api
  static _MainShellScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainShellScreenState>();
  }

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),              // 0: الرئيسية
    const MinistriesScreen(),        // 1: الوزارات
    const ComplaintsCenterScreen(),  // 2: الشكاوى
    const SettingsScreen(),          // 3: الإعدادات
    const ProfileScreen(),           // 4: الحساب
  ];

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  // نستخدمها من الصفحات الداخلية لتغيير التبويب
  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SafeArea(
          child: _pages[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
          selectedItemColor: HomeScreen.primaryColor,
          unselectedItemColor: const Color(0xFF9CA3AF),
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