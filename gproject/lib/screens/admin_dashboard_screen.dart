// ignore_for_file: unused_local_variable, deprecated_member_use, unused_import, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gproject/screens/admin_complaints_screen.dart';

import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart' as users; // إعطاء prefix
import 'admin_account_screen.dart';       // يحتوي AdminProfileScreen فقط

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
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
        return AdminProfileScreen(
          onBackToDashboard: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      default:
        return const _AdminHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: _buildBody(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme
                    .bottomNavigationBarTheme.backgroundColor ??
                theme.cardColor,
            border: Border(
              top: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: theme.bottomNavigationBarTheme
                    .selectedItemColor ??
                primary,
            unselectedItemColor: theme
                    .bottomNavigationBarTheme
                    .unselectedItemColor ??
                theme.hintColor,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'الإعدادات',
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
    final complaintsRef =
        FirebaseFirestore.instance.collection('complaints');
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: complaintsRef.snapshots(),
      builder: (context, snapshot) {
        int totalNew = 0;
        int pending = 0;
        int resolved = 0;
        int rejected = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          for (final doc in docs) {
            final data =
                doc.data() as Map<String, dynamic>;
            final status =
                (data['status'] ?? 'pending').toString();
            final createdAt = data['createdAt'];

            // "شكاوى جديدة" = pending خلال آخر 24 ساعة
            if (createdAt is Timestamp) {
              final dt = createdAt.toDate();
              final isLast24h =
                  DateTime.now().difference(dt).inHours <= 24;
              if (status == 'pending' && isLast24h) {
                totalNew++;
              }
            }

            switch (status) {
              case 'pending':
                pending++;
                break;
              case 'resolved':
                resolved++;
                break;
              case 'rejected':
                rejected++;
                break;
              default:
                break;
            }
          }
        }

        final isLoading =
            snapshot.connectionState ==
                ConnectionState.waiting;

        return Column(
          children: [
            // الهيدر العلوي
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: theme.appBarTheme.backgroundColor ??
                    theme.cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'لوحة تحكم الأدمن',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // بانر التنبيه
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Center(
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius:
                          BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(
                                    10),
                          ),
                          child: const Icon(
                            Icons
                                .notifications_active_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isLoading
                                ? 'جاري تحميل الشكاوى...'
                                : totalNew == 0
                                    ? 'لا توجد شكاوى جديدة خلال آخر ٢٤ ساعة.'
                                    : 'وصلت $totalNew شكوى جديدة خلال آخر ٢٤ ساعة!',
                            style: theme
                                .textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.white,
                            foregroundColor: primary,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),
                          ),
                          onPressed: () {
                            // افتح صفحة الشكاوى على فلتر "جديدة"
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminComplaintsScreen(
                                  initialFilter:
                                      ComplaintStatus
                                          .neww,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'عرض',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w700,
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
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: Container(
                    constraints:
                        const BoxConstraints(
                            maxWidth: 480),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // عنوان إحصائيات الشكاوى
                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          4),
                          child: Text(
                            'إحصائيات الشكاوى',
                            style: theme.textTheme
                                .bodyLarge
                                ?.copyWith(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // صناديق الإحصائيات
                        LayoutBuilder(
                          builder: (context,
                              constraints) {
                            final cardWidth =
                                (constraints
                                            .maxWidth -
                                        8) /
                                    2;

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // شكاوى جديدة
                                SizedBox(
                                  width: cardWidth,
                                  child: SizedBox(
                                    height: 110,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminComplaintsScreen(
                                              initialFilter:
                                                  ComplaintStatus
                                                      .neww,
                                            ),
                                          ),
                                        );
                                      },
                                      child:
                                          _StatCard(
                                        titleLines:
                                            const [
                                          'شكاوى',
                                          'جديدة'
                                        ],
                                        value: isLoading
                                            ? '—'
                                            : totalNew
                                                .toString(),
                                        badgeText: '',
                                        badgeColor:
                                            primary.withOpacity(
                                                0.08),
                                        badgeTextColor:
                                            primary,
                                        icon: Icons
                                            .mail_outline,
                                        iconColor:
                                            primary,
                                      ),
                                    ),
                                  ),
                                ),

                                // قيد المراجعة
                                SizedBox(
                                  width: cardWidth,
                                  child: SizedBox(
                                    height: 110,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminComplaintsScreen(
                                              initialFilter:
                                                  ComplaintStatus
                                                      .pending,
                                            ),
                                          ),
                                        );
                                      },
                                      child:
                                          _StatCard(
                                        titleLines:
                                            const [
                                          'قيد',
                                          'المراجعة'
                                        ],
                                        value: isLoading
                                            ? '—'
                                            : pending
                                                .toString(),
                                        badgeText:
                                            'قيد الانتظار',
                                        badgeColor:
                                            theme.cardColor,
                                        badgeTextColor:
                                            theme
                                                .hintColor,
                                        icon: Icons
                                            .schedule_outlined,
                                        iconColor: Colors
                                            .orangeAccent,
                                      ),
                                    ),
                                  ),
                                ),

                                // تمت المعالجة
                                SizedBox(
                                  width: cardWidth,
                                  child: SizedBox(
                                    height: 110,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminComplaintsScreen(
                                              initialFilter:
                                                  ComplaintStatus
                                                      .resolved,
                                            ),
                                          ),
                                        );
                                      },
                                      child:
                                          _StatCard(
                                        titleLines:
                                            const [
                                          'تمت',
                                          'المعالجة'
                                        ],
                                        value: isLoading
                                            ? '—'
                                            : resolved
                                                .toString(),
                                        badgeText:
                                            'مكتمل',
                                        badgeColor:
                                            theme.cardColor,
                                        badgeTextColor:
                                            theme
                                                .hintColor,
                                        icon: Icons
                                            .check_circle_outline,
                                        iconColor:
                                            Colors.green,
                                      ),
                                    ),
                                  ),
                                ),

                                // مرفوضة
                                SizedBox(
                                  width: cardWidth,
                                  child: SizedBox(
                                    height: 110,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminComplaintsScreen(
                                              initialFilter:
                                                  ComplaintStatus
                                                      .rejected,
                                            ),
                                          ),
                                        );
                                      },
                                      child:
                                          _StatCard(
                                        titleLines:
                                            const [
                                          'شكاوى',
                                          'مرفوضة'
                                        ],
                                        value: isLoading
                                            ? '—'
                                            : rejected
                                                .toString(),
                                        badgeText:
                                            'ملغي',
                                        badgeColor: theme
                                            .colorScheme
                                            .errorContainer
                                            .withOpacity(
                                                0.5),
                                        badgeTextColor:
                                            theme
                                                .colorScheme
                                                .error,
                                        icon: Icons
                                            .cancel_outlined,
                                        iconColor: theme
                                            .colorScheme
                                            .error,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // عنوان الوصول السريع
                        Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      horizontal:
                                          4),
                          child: Text(
                            'الوصول السريع',
                            style: theme.textTheme
                                .bodyLarge
                                ?.copyWith(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
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
                              icon: Icons
                                  .group_outlined,
                              iconBg: primary
                                  .withOpacity(0.08),
                              title:
                                  'إدارة المستخدمين',
                              subtitle:
                                  'عرض وإدارة حسابات المواطنين.',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const users
                                                .AdminUsersScreen(),
                                  ),
                                );
                              },
                            ),
                            _QuickAccessCard(
                              icon: Icons
                                  .bar_chart_outlined,
                              iconBg: primary
                                  .withOpacity(0.08),
                              title:
                                  'التقارير والتحليلات',
                              subtitle:
                                  'الوصول لتقارير الشكاوى.',
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
      },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleLines.join('\n'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(
                  fontSize: 11,
                  color: theme.hintColor,
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
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (badgeText.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius:
                    BorderRadius.circular(999),
                border: badgeColor
                            .computeLuminance() >
                        0.9
                    ? Border.all(
                        color: theme.dividerColor,
                      )
                    : null,
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 3),
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
                color: primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(
                fontSize: 10,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}