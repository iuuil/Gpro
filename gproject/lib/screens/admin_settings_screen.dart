import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({
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
                    IconButton(
                      onPressed: () {
                        if (onBackToDashboard != null) {
                          onBackToDashboard!(); // يرجع للـDashboard
                        } else {
                          Navigator.pop(context); // fallback
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF137FEC),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'إعدادات النظام',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF020617),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // بحث
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // باقي المحتوى
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // === إعدادات عامة ===
                        const _SectionTitle('إعدادات عامة'),
                        _SettingsTile(
                          icon: Icons.settings_applications_outlined,
                          iconBg: primary,
                          title: 'اسم التطبيق',
                          subtitle: 'صوت المواطن',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.image_outlined,
                          iconBg: primary,
                          title: 'شعار النظام',
                          subtitle: 'تعديل الشعار الرسمي والهوية',
                          onTap: () {},
                        ),
                        _SettingsToggleTile(
                          icon: Icons.construction_outlined,
                          iconBg: primary,
                          title: 'وضع الصيانة',
                          subtitle: 'إيقاف النظام مؤقتاً للتحديث',
                          value: false,
                          onChanged: (v) {},
                        ),

                        const Divider(height: 24),

                        // === إدارة الوزارات ===
                        const _SectionTitle('إدارة الوزارات'),
                        _SettingsTile(
                          icon: Icons.account_balance_outlined,
                          iconBg: primary,
                          title: 'قائمة الوزارات',
                          subtitle:
                              'إضافة أو تعديل بيانات الجهات الحكومية',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.contact_phone_outlined,
                          iconBg: primary,
                          title: 'معلومات التواصل',
                          subtitle:
                              'تحديث أرقام الطوارئ والبريد لكل وزارة',
                          onTap: () {},
                        ),

                        const Divider(height: 24),

                        // === قواعد التصنيف ===
                        const _SectionTitle('قواعد التصنيف'),
                        _SettingsTile(
                          icon: Icons.rule_folder_outlined,
                          iconBg: primary,
                          title: 'أنواع البلاغات',
                          subtitle:
                              'تصنيف الشكاوى، الاقتراحات، والطلبات',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.priority_high_outlined,
                          iconBg: primary,
                          title: 'مستويات الأولوية',
                          subtitle:
                              'تحديد الفترات الزمنية لكل مستوى أولوية',
                          onTap: () {},
                        ),

                        const Divider(height: 24),

                        // === إعدادات التنبيهات ===
                        const _SectionTitle('إعدادات التنبيهات'),
                        _SettingsTile(
                          icon: Icons.sms_outlined,
                          iconBg: primary,
                          title: 'بوابة الرسائل النصية',
                          subtitle:
                              'ربط مزود خدمة الرسائل (SMS Gateway)',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.mail_outline,
                          iconBg: primary,
                          title: 'خادم البريد',
                          subtitle:
                              'إعدادات SMTP لإرسال الإشعارات البريدية',
                          onTap: () {},
                        ),

                        const Divider(height: 24),

                        // === الأمان ===
                        const _SectionTitle('الأمان'),
                        _SettingsTile(
                          icon: Icons.timer_outlined,
                          iconBg: primary,
                          title: 'انتهاء الجلسة',
                          subtitle:
                              'تحديد وقت الخروج التلقائي (30 دقيقة)',
                          onTap: () {},
                        ),
                        _SettingsTile(
                          icon: Icons.history_edu_outlined,
                          iconBg: primary,
                          title: 'سجلات الوصول',
                          subtitle:
                              'مراقبة عمليات دخول المشرفين',
                          onTap: () {},
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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

// ===== عناصر مساعدة =====

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF020617),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: iconBg.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF020617),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  Color get primary => const Color(0xFF137FEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconBg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF020617),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
