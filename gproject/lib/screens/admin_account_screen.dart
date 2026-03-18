import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({
    super.key,
    this.onBackToDashboard,
  });

  static const Color primary = Color(0xFF137FEC);
  static const Color bgLight = Color(0xFFF6F7F8);

  final VoidCallback? onBackToDashboard;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // سهم الرجوع (يرجع للوحة التحكم)
                    IconButton(
                      onPressed: () {
                        if (onBackToDashboard != null) {
                          onBackToDashboard!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'الملف الشخصي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF020617),
                        ),
                      ),
                    ),
                    // حذف زر الإعدادات: نحط SizedBox عشان الـRow يبقى متوازن
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // باقي المحتوى قابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // قسم معلومات البروفايل
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            // الصورة
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  // ignore: deprecated_member_use
                                  color: primary.withOpacity(0.2),
                                  width: 4,
                                ),
                                image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCarPLJsoWu53ziAxJpLkMxbVIsvuDaG4lolkuXWOlgC3I7dTbNIQoBKiiliAqS6JnW5zV_2suWan5tB11xmvFuPkpWfqOqtRAfBtEwwueW2pQlgDJTL_LuVdoeiI7w1x_HFmRafxo7r6se1ZmJh8gSx2wa6SjyHB9_r6fywN7VCG8YZw8Fkja6vyxDXIpO4AP1NwclWtLNXG3nvW2VX3ImOIrVaNkH-nq8L-e9lUejx12Buizc15lWSWh5y71qCtKfL9lJSFchf-mE',
                                  ),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'أحمد محمود',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF020617),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'مسؤول النظام',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'رقم الهوية: 1029384756',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ملخص الإحصائيات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                'ملخص الإحصائيات',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF020617),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCardProfile(
                                    icon: Icons.fact_check_outlined,
                                    iconColor: primary,
                                    // ignore: deprecated_member_use
                                    iconBg: primary.withOpacity(0.1),
                                    trendText: '12%',
                                    trendColor: const Color(0xFF059669),
                                    title: 'الشكاوى المعالجة',
                                    value: '1,284',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCardProfile(
                                    icon: Icons.pending_actions_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                    iconBg:
                                        // ignore: deprecated_member_use
                                        const Color(0xFFF59E0B).withOpacity(0.1),
                                    trendText: '5%',
                                    trendColor: const Color(0xFF059669),
                                    title: 'موافقات معلقة',
                                    value: '42',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // المعلومات الشخصية
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'المعلومات الشخصية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF020617),
                                  ),
                                ),
                              ),
                              Divider(height: 1),
                              _InfoRow(
                                label: 'البريد الإلكتروني الرسمي',
                                value: 'ahmed.m@ministry.gov.sa',
                                icon: Icons.mail_outline,
                              ),
                              _InfoRow(
                                label: 'الوزارة / القسم',
                                value: 'وزارة الاتصالات وتقنية المعلومات',
                                icon: Icons.account_balance_outlined,
                              ),
                              _InfoRow(
                                label: 'الرقم الوظيفي',
                                value: 'EMP-77492',
                                icon: Icons.badge_outlined,
                              ),
                              _InfoRow(
                                label: 'تاريخ الانضمام',
                                value: '15 أكتوبر 2021',
                                icon: Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // الأزرار
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  // ignore: deprecated_member_use
                                  shadowColor: primary.withOpacity(0.3),
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text(
                                  'تعديل الملف الشخصي',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF020617),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.security_outlined),
                                label: const Text(
                                  'إعدادات الأمان',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.logout,
                                color: Color(0xFFDC2626),
                              ),
                              label: const Text(
                                'تسجيل الخروج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC2626),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كرت إحصائية في البروفايل
class _StatCardProfile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String trendText;
  final Color trendColor;
  final String title;
  final String value;

  const _StatCardProfile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.trendText,
    required this.trendColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: trendColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trendText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF020617),
            ),
          ),
        ],
      ),
    );
  }
}

// صف معلومات
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF020617),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
