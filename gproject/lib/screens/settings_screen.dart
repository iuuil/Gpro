// ignore_for_file: duplicate_ignore, deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // مهم: حتى نستخدم MyApp.of(context)
import 'change_password_screen.dart';
import 'notifications_screen.dart';

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

  Future<void> _showAboutDialog(BuildContext context) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'حول التطبيق',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.titleMedium,
          ),
          content: Text(
            'تطبيق صوت المواطن يسهّل على المواطنين تقديم الشكاوى والمتابعة مع الجهات الحكومية المختصة بطريقة منظمة وآمنة، مع عرض حالة الشكوى وتحديثاتها بشكل مستمر.',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'حسنًا',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPrivacyDialog(BuildContext context) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'سياسة الخصوصية',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.titleMedium,
          ),
          content: Text(
            'نقوم باستخدام بياناتك لتقديم خدمة تقديم الشكاوى فقط، ولا نشارك معلوماتك الشخصية مع أي جهة غير مخوّلة. قد نستخدم بعض البيانات الإحصائية لتحسين أداء التطبيق وتجربة المستخدم دون الكشف عن هويتك.',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'حسنًا',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTermsDialog(BuildContext context) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'شروط الخدمة',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.titleMedium,
          ),
          content: Text(
            'باستخدامك لتطبيق صوت المواطن، فإنك تتعهد بإدخال بيانات صحيحة وتجنّب تقديم بلاغات كيدية أو مضللة. يحتفظ فريق التطبيق بحق مراجعة أو إلغاء أي شكوى مخالفة والقيام بالتعديلات اللازمة على الخدمة متى ما دعت الحاجة.',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.bodyMedium,
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'حسنًا',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // نحدد إذا الوضع الحالي Dark أو لا من الـ Theme
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadUserProfile(),
      builder: (context, snapshot) {
        final data = snapshot.data;

        final displayName =
            (data?['fullName'] as String?)?.trim().isNotEmpty == true
                ? data!['fullName'] as String
                : 'مستخدم التطبيق';

        final email =
            (data?['email'] as String?)?.trim().isNotEmpty == true
                ? data!['email'] as String
                : 'no-email@example.com';

        final photoUrl = (data?['photoUrl'] as String?) ?? '';

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor,
                        ),
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
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: theme.iconTheme.color ??
                                  const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'الإعدادات',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
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
                                                image:
                                                    NetworkImage(photoUrl),
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
                                  style:
                                      theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // إعدادات الحساب
                          const _SectionHeader(title: 'إعدادات الحساب'),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor,
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const NotificationsScreen(),
                                        ),
                                      );
                                    },
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

                          const SizedBox(height: 24),

                          // إعدادات التطبيق
                          const _SectionHeader(title: 'إعدادات التطبيق'),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor,
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
                                  // اللغة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        const _IconBox(
                                          icon: Icons.language,
                                          bgColor: Color(0x1F137FEC),
                                          iconColor: SettingsScreen.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'اللغة',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'العربية',
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const _LanguageDropdown(),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: theme.dividerColor,
                                  ),
                                  // الوضع الليلي
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        const _IconBox(
                                          icon: Icons.dark_mode_outlined,
                                          bgColor: Color(0x1F137FEC),
                                          iconColor: SettingsScreen.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'الوضع الليلي',
                                            style: theme
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: isDarkTheme,
                                          activeColor: primary,
                                          onChanged: (val) {
                                            final appState =
                                                MyApp.of(context);
                                            if (appState == null) return;

                                            appState.setThemeMode(
                                              val
                                                  ? ThemeMode.dark
                                                  : ThemeMode.light,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // معلومات
                          const _SectionHeader(title: 'معلومات'),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor,
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
                                    icon: Icons.info_outline,
                                    iconBgColor: const Color(0x1F137FEC),
                                    title: 'حول التطبيق',
                                    showDivider: true,
                                    onTap: () => _showAboutDialog(context),
                                  ),
                                  _SettingsTile(
                                    icon:
                                        Icons.verified_user_outlined,
                                    iconBgColor: const Color(0x1F137FEC),
                                    title: 'سياسة الخصوصية',
                                    showDivider: true,
                                    onTap: () =>
                                        _showPrivacyDialog(context),
                                  ),
                                  _SettingsTile(
                                    icon: Icons.description_outlined,
                                    iconBgColor: const Color(0x1F137FEC),
                                    title: 'شروط الخدمة',
                                    onTap: () => _showTermsDialog(context),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // زر تسجيل الخروج
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
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
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'صوت المواطن - الإصدار 2.4.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);

    final tile = InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color?.withOpacity(0.4) ??
                  const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );

    if (!showDivider) return tile;

    return Column(
      children: [
        tile,
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}

class _LanguageDropdown extends StatefulWidget {
  // ignore: use_super_parameters
  const _LanguageDropdown({Key? key}) : super(key: key);

  @override
  State<_LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<_LanguageDropdown> {
  String _selected = 'العربية';

  final List<String> _items = [
    'العربية',
    'English',
    'Español',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selected,
        icon: Icon(
          Icons.expand_more,
          color: theme.iconTheme.color?.withOpacity(0.6) ??
              const Color(0xFF9CA3AF),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13,
        ),
        borderRadius: BorderRadius.circular(12),
        dropdownColor: theme.cardColor,
        items: _items.map((lang) {
          return DropdownMenuItem<String>(
            value: lang,
            child: Text(lang),
          );
        }).toList(),
        onChanged: (value) async {
          if (value == null) return;

          setState(() {
            _selected = value;
          });

          if (value == 'English' || value == 'Español') {
            await showDialog(
              context: context,
              builder: (ctx) {
                final dialogTheme = Theme.of(ctx);
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'اللغة غير متوفرة',
                    textDirection: TextDirection.rtl,
                    style: dialogTheme.textTheme.titleMedium,
                  ),
                  content: Text(
                    'سيتم إضافة هذه اللغة قريبًا في التحديثات القادمة.',
                    textDirection: TextDirection.rtl,
                    style: dialogTheme.textTheme.bodyMedium,
                  ),
                  actionsAlignment: MainAxisAlignment.end,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'حسنًا',
                        style: dialogTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            );

            // نرجّع الاختيار إلى العربية بعد إغلاق التنبيه
            setState(() {
              _selected = 'العربية';
            });
          }
        },
      ),
    );
  }
}