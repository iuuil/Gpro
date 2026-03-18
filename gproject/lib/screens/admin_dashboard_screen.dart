import 'package:flutter/material.dart';
import 'package:gproject/screens/admin_complaints_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';
import 'admin_account_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const Color primary = Color(0xFF0070D2);
  static const Color secondary = Color(0xFFF4F7FE);
  static const Color accent = Color(0xFFEE4B5E);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _AdminHomeContent();
      case 1:
        return AdminSettingsScreen(
          onBackToDashboard: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 2:
        return const Center(
          child: Text('صفحة مؤقتة ١'),
        );
      case 3:
        return const Center(
          child: Text('صفحة مؤقتة ٢'),
        );
      case 4:
        return AdminProfileScreen(
          onBackToDashboard: () {
            setState(() {
              _currentIndex = 0; // يرجع للوحة التحكم
            });
          },
        );
      default:
        return const _AdminHomeContent();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: _buildBody(),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: AdminDashboardScreen.primary,
            unselectedItemColor: const Color(0xFF9CA3AF),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              // RTL: أول عنصر من اليمين = index 0
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'الإعدادات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_border),
                label: 'مؤقت ١',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pending_actions_outlined),
                label: 'مؤقت ٢',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== محتوى لوحة التحكم (الرئيسية) ===================

class _AdminHomeContent extends StatelessWidget {
  const _AdminHomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الهيدر العلوي
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
          ),
          child: const Center(
            child: Text(
              'لوحة تحكم الأدمن',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2933),
              ),
            ),
          ),
        ),

        // بانر التنبيه ثابت
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AdminDashboardScreen.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'وصلت ١٢ شكوى جديدة!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AdminDashboardScreen.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminComplaintsScreen(
                              initialFilter: ComplaintStatus.neww,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'عرض',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // باقي المحتوى قابل للتمرير
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان إحصائيات الشكاوى
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'إحصائيات الشكاوى',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // صناديق الإحصائيات
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth =
                            (constraints.maxWidth - 8) / 2;

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // شكاوى جديدة
                            SizedBox(
                              width: cardWidth,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminComplaintsScreen(
                                        initialFilter:
                                            ComplaintStatus.neww,
                                      ),
                                    ),
                                  );
                                },
                                child: const _StatCard(
                                  titleLines: ['شكاوى', 'جديدة'],
                                  value: '١٢',
                                  badgeText: 'عاجل',
                                  badgeColor:
                                      AdminDashboardScreen.primary,
                                  badgeTextColor: Colors.white,
                                  icon: Icons.mail_outline,
                                  iconColor:
                                      AdminDashboardScreen.primary,
                                ),
                              ),
                            ),

                            // قيد المراجعة
                            SizedBox(
                              width: cardWidth,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminComplaintsScreen(
                                        initialFilter:
                                            ComplaintStatus.underReview,
                                      ),
                                    ),
                                  );
                                },
                                child: const _StatCard(
                                  titleLines: ['قيد', 'المراجعة'],
                                  value: '٥٦',
                                  badgeText: 'قيد الانتظار',
                                  badgeColor: Color(0xFFF3F4F6),
                                  badgeTextColor: Color(0xFF4B5563),
                                  icon: Icons
                                      .schedule_outlined,
                                  iconColor: Colors.green,
                                ),
                              ),
                            ),

                            // تمت المعالجة
                            SizedBox(
                              width: cardWidth,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminComplaintsScreen(
                                        initialFilter:
                                            ComplaintStatus.resolved,
                                      ),
                                    ),
                                  );
                                },
                                child: const _StatCard(
                                  titleLines: ['تمت', 'المعالجة'],
                                  value: '٣٤٥',
                                  badgeText: 'مكتمل',
                                  badgeColor: Color(0xFFF9FAFB),
                                  badgeTextColor: Color(0xFF6B7280),
                                  icon: Icons
                                      .check_circle_outline,
                                  iconColor: Colors.green,
                                ),
                              ),
                            ),

                            // مرفوضة
                            SizedBox(
                              width: cardWidth,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AdminComplaintsScreen(
                                        initialFilter:
                                            ComplaintStatus.rejected,
                                      ),
                                    ),
                                  );
                                },
                                child: const _StatCard(
                                  titleLines: ['شكاوى', 'مرفوضة'],
                                  value: '٨',
                                  badgeText: 'ملغي',
                                  badgeColor: Color(0xFFFEE2E2),
                                  badgeTextColor: Colors.red,
                                  icon: Icons.cancel_outlined,
                                  iconColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // عنوان الوصول السريع
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'الوصول السريع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // شبكة الوصول السريع
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: [
                        _QuickAccessCard(
                          icon: Icons.group_outlined,
                          iconBg: const Color(0xFFE0ECFF),
                          title: 'إدارة المستخدمين',
                          subtitle:
                              'عرض وإدارة حسابات المواطنين.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminUsersScreen(),
                              ),
                            );
                          },
                        ),
                        _QuickAccessCard(
                          icon: Icons.bar_chart_outlined,
                          iconBg: const Color(0xFFE0ECFF),
                          title: 'التقارير والتحليلات',
                          subtitle: 'الوصول لتقارير الشكاوى.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminReportsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// بطاقة الإحصائيات
class _StatCard extends StatelessWidget {
  final List<String> titleLines;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.titleLines,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleLines.join('\n'),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius:
                  BorderRadius.circular(999),
              border: badgeColor.computeLuminance() > 0.9
                  ? Border.all(
                      color: const Color(0xFFE5E7EB))
                  : null,
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة "الوصول السريع"
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AdminDashboardScreen.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
