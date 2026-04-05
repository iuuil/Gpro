// ignore_for_file: duplicate_ignore, deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color primary = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
        ),
      );
    }
  }

  /// تحميل بيانات المستخدم الحالية من Firestore + Auth
  Future<Map<String, dynamic>?> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    await user.reload();
    final refreshed = FirebaseAuth.instance.currentUser;

    // قراءة وثيقة المستخدم من Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(refreshed!.uid)
        .get();

    final data = userDoc.data() ?? <String, dynamic>{};

    final fullName = (data['fullName'] as String?) ??
        (refreshed.displayName) ??
        (refreshed.email?.split('@').first ?? 'مستخدم التطبيق');

    final email = (data['email'] as String?) ??
        (refreshed.email ?? 'no-email@example.com');

    final photoUrl = (data['avatarUrl'] as String?) ?? refreshed.photoURL ?? '';

    return {
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadUserProfile(),
      builder: (context, snapshot) {
        final data = snapshot.data;

        final displayName = (data?['fullName'] as String?)?.trim().isNotEmpty == true
            ? data!['fullName'] as String
            : 'مستخدم التطبيق';

        final email = (data?['email'] as String?)?.trim().isNotEmpty == true
            ? data!['email'] as String
            : 'no-email@example.com';

        final photoUrl = (data?['photoUrl'] as String?) ?? '';

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: backgroundLight,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/main-shell',
                                (route) => false,
                              );
                            },
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'الإعدادات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                          width: 40,
                        ),
                      ],
                    ),
                  ),

                  // المحتوى
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Profile Quick View
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primary.withOpacity(0.08),
                                        border: Border.all(
                                          color: primary.withOpacity(0.2),
                                          width: 2,
                                        ),
                                        image: photoUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(photoUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: photoUrl.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: primary,
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // إعدادات الحساب
                          const _SectionHeader(title: 'إعدادات الحساب'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _SettingsTile(
                                    icon: Icons.notifications_outlined,
                                    iconBgColor: const Color(0x1F137FEC),
                                    title: 'تفضيلات الإشعارات',
                                    showDivider: true,
                                    onTap: () {},
                                  ),
                                  _SettingsTile(
                                    icon: Icons.lock_outline,
                                    iconBgColor: const Color(0x1F137FEC),
                                    title: 'تغيير كلمة المرور',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ChangePasswordScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // const SizedBox(height: 24),

                          // إعدادات التطبيق
                          /* const _SectionHeader(title: 'إعدادات التطبيق'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // هنا كان كود اللغة + الديفيدر + كود الوضع الليلي
                                  // كله نحذفه ونخلي العمود فاضي أو تضيف إعدادات ثانية لاحقاً
                                ],
                              ),
                            ),
                          ), */

                          const SizedBox(height: 24),

                          // معلومات
                          const _SectionHeader(title: 'معلومات'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  _SettingsTile(
                                    icon: Icons.info_outline,
                                    iconBgColor: Color(0x1F137FEC),
                                    title: 'حول التطبيق',
                                    showDivider: true,
                                  ),
                                  _SettingsTile(
                                    icon: Icons.verified_user_outlined,
                                    iconBgColor: Color(0x1F137FEC),
                                    title: 'سياسة الخصوصية',
                                    showDivider: true,
                                  ),
                                  _SettingsTile(
                                    icon: Icons.description_outlined,
                                    iconBgColor: Color(0x1F137FEC),
                                    title: 'شروط الخدمة',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // زر تسجيل الخروج
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _signOut(context),
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFFCA5A5),
                                  ),
                                  backgroundColor:
                                      const Color(0xFFFFF1F2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'صوت المواطن - الإصدار 2.4.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _IconBox({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.showDivider = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _IconBox(
              icon: icon,
              bgColor: iconBgColor,
              iconColor: SettingsScreen.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );

    if (!showDivider) return tile;

    return Column(
      children: [
        tile,
        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),
      ],
    );
  }
}