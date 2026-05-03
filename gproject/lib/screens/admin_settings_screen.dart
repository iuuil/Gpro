// ignore_for_file: unused_element_parameter, use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';

// مهم: استورد main حتى نقدر نستخدم MyApp.of(context)
import '../main.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({
    Key? key,
    this.onBackToDashboard,
  }) : super(key: key);

  final VoidCallback? onBackToDashboard;

  @override
  State<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState
    extends State<AdminSettingsScreen> {
  bool _isSearching = false;
  String _searchQuery = '';

  // حالة الوضع الليلي
  bool _isDarkMode = false;
  bool _themeInitializedFromApp = false;

  String _appName = 'صوت المواطن';
  String _logoDescription = 'تعديل الشعار الرسمي والهوية';

  final List<Map<String, String>> _ministries = [
    {'name': 'وزارة الداخلية', 'info': 'مسؤولة عن الأمن الداخلي'},
    {'name': 'وزارة الصحة', 'info': 'مسؤولة عن الخدمات الصحية'},
    {'name': 'وزارة التربية', 'info': 'مسؤولة عن التعليم المدرسي'},
    {
      'name': 'وزارة التعليم العالي',
      'info': 'مسؤولة عن الجامعات'
    },
    {
      'name': 'وزارة الكهرباء',
      'info': 'مسؤولة عن الطاقة الكهربائية'
    },
  ];

  Future<void> _showAppNameDialog() async {
    final controller = TextEditingController(text: _appName);
    await showDialog(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'تعديل اسم التطبيق',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.titleMedium,
          ),
          content: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'الاسم الجديد',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() => _appName = text);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoDialog() async {
    final controller =
        TextEditingController(text: _logoDescription);
    await showDialog(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'تعديل الشعار والهوية',
            textDirection: TextDirection.rtl,
            style: dialogTheme.textTheme.titleMedium,
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'وصف الشعار / ملاحظات',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(
                      () => _logoDescription = text);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMinistriesList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MinistriesScreen(
          ministries: _ministries,
        ),
      ),
    );
    setState(() {});
  }

  bool _matchesSearch(String title, String subtitle) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return title.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    // نزامن حالة السويتش مرة واحدة مع الثيم الحالي
    if (!_themeInitializedFromApp) {
      _isDarkMode = isDark;
      _themeInitializedFromApp = true;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر + البحث
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.07),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.onBackToDashboard !=
                            null) {
                          widget.onBackToDashboard!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 20,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_isSearching)
                      Expanded(
                        child: Text(
                          'إعدادات النظام',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            autofocus: true,
                            textDirection:
                                TextDirection.rtl,
                            decoration: InputDecoration(
                              hintText:
                                  'بحث في الإعدادات...',
                              filled: true,
                              fillColor: theme.cardColor,
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                                borderSide: BorderSide(
                                  color:
                                      theme.dividerColor,
                                ),
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                                borderSide: BorderSide(
                                  color:
                                      theme.dividerColor,
                                ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                                borderSide: BorderSide(
                                  color: primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {
                                _searchQuery =
                                    v.trim();
                              });
                            },
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isSearching) {
                            _isSearching = false;
                            _searchQuery = '';
                          } else {
                            _isSearching = true;
                          }
                        });
                      },
                      icon: Icon(
                        _isSearching
                            ? Icons.close
                            : Icons.search,
                        color: theme.iconTheme.color
                                ?.withOpacity(0.6) ??
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 480),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        const _SectionTitle('إعدادات عامة'),
                        if (_matchesSearch(
                            'اسم التطبيق', _appName))
                          _SettingsTile(
                            icon: Icons
                                .settings_applications_outlined,
                            iconBg: primary,
                            title: 'اسم التطبيق',
                            subtitle: _appName,
                            onTap: _showAppNameDialog,
                          ),
                        if (_matchesSearch(
                            'شعار النظام',
                            _logoDescription))
                          _SettingsTile(
                            icon: Icons.image_outlined,
                            iconBg: primary,
                            title: 'شعار النظام',
                            subtitle: _logoDescription,
                            onTap: _showLogoDialog,
                          ),

                        // زر الوضع الليلي
                        if (_matchesSearch(
                            'الوضع الليلي',
                            'تفعيل / تعطيل الوضع الداكن'))
                          _SettingsTile.switchTile(
                            icon: Icons.dark_mode_outlined,
                            iconBg: primary,
                            title: 'الوضع الليلي',
                            subtitle: _isDarkMode
                                ? 'مفعل (الوضع الداكن)'
                                : 'مغلق (الوضع الفاتح)',
                            value: _isDarkMode,
                            onChanged: (val) {
                              setState(() {
                                _isDarkMode = val;
                              });
                              final appState =
                                  MyApp.of(context);
                              if (appState != null) {
                                appState.setThemeMode(
                                  val
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                );
                              }
                            },
                          ),

                        const Divider(height: 24),

                        const _SectionTitle('إدارة الوزارات'),
                        if (_matchesSearch(
                            'قائمة الوزارات',
                            'إضافة أو تعديل بيانات الجهات الحكومية'))
                          _SettingsTile(
                            icon: Icons
                                .account_balance_outlined,
                            iconBg: primary,
                            title: 'قائمة الوزارات',
                            subtitle:
                                'إضافة أو تعديل بيانات الجهات الحكومية',
                            onTap: _showMinistriesList,
                          ),
                        if (_matchesSearch(
                            'معلومات التواصل',
                            'تحديث أرقام الطوارئ والبريد لكل وزارة'))
                          _SettingsTile(
                            icon: Icons
                                .contact_phone_outlined,
                            iconBg: primary,
                            title: 'معلومات التواصل',
                            subtitle:
                                'تحديث أرقام الطوارئ والبريد لكل وزارة',
                            onTap: _showMinistriesList,
                          ),

                        const Divider(height: 24),

                        const _SectionTitle('إعدادات التنبيهات'),
                        if (_matchesSearch(
                            'بوابة الرسائل النصية',
                            'ربط مزود خدمة الرسائل (SMS Gateway)'))
                          _SettingsTile(
                            icon: Icons.sms_outlined,
                            iconBg: primary,
                            title: 'بوابة الرسائل النصية',
                            subtitle:
                                'ربط مزود خدمة الرسائل (SMS Gateway)',
                            onTap: () {},
                          ),
                        if (_matchesSearch(
                            'خادم البريد',
                            'إعدادات SMTP لإرسال الإشعارات البريدية'))
                          _SettingsTile(
                            icon: Icons.mail_outline,
                            iconBg: primary,
                            title: 'خادم البريد',
                            subtitle:
                                'إعدادات SMTP لإرسال الإشعارات البريدية',
                            onTap: () {},
                          ),

                        const Divider(height: 24),

                        const _SectionTitle('الأمان'),
                        if (_matchesSearch(
                            'سجلات الوصول',
                            'مراقبة عمليات دخول المشرفين'))
                          _SettingsTile(
                            icon: Icons
                                .history_edu_outlined,
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
  const _SectionTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
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

  // خصائص السويتش (لما نستخدمه كـ switchTile)
  final bool? value;
  final ValueChanged<bool>? onChanged;

  const _SettingsTile({
    Key? key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.value,
    this.onChanged,
  }) : super(key: key);

  const _SettingsTile.switchTile({
    Key? key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  })  : onTap = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasSwitch = value != null && onChanged != null;

    return InkWell(
      onTap: hasSwitch ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
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
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            if (hasSwitch)
              Switch(
                value: value!,
                onChanged: onChanged,
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.iconTheme.color
                        ?.withOpacity(0.4) ??
                    Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}

// ===== شاشات الوزارات =====

class MinistriesScreen extends StatefulWidget {
  final List<Map<String, String>> ministries;

  const MinistriesScreen({
    Key? key,
    required this.ministries,
  }) : super(key: key);

  @override
  State<MinistriesScreen> createState() =>
      _MinistriesScreenState();
}

class _MinistriesScreenState
    extends State<MinistriesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ??
                  theme.cardColor,
          elevation: 0.5,
          iconTheme: theme.appBarTheme.iconTheme ??
              IconThemeData(color: theme.iconTheme.color),
          title: Text(
            'قائمة الوزارات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.ministries.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final m = widget.ministries[index];
            final name = m['name'] ?? '';
            final info = m['info'] ?? '';

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: theme.cardColor,
              title: Text(
                name,
                style:
                    theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                info,
                style:
                    theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.hintColor,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.iconTheme.color
                        ?.withOpacity(0.4) ??
                    Colors.grey,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MinistryEditScreen(
                      ministry: m,
                    ),
                  ),
                );
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}

class MinistryEditScreen extends StatefulWidget {
  final Map<String, String> ministry;

  const MinistryEditScreen({
    Key? key,
    required this.ministry,
  }) : super(key: key);

  @override
  State<MinistryEditScreen> createState() =>
      _MinistryEditScreenState();
}

class _MinistryEditScreenState
    extends State<MinistryEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _infoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.ministry['name'] ?? '',
    );
    _infoController = TextEditingController(
      text: widget.ministry['info'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ??
                  theme.cardColor,
          elevation: 0.5,
          iconTheme: theme.appBarTheme.iconTheme ??
              IconThemeData(color: theme.iconTheme.color),
          title: Text(
            'تعديل بيانات الوزارة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم الوزارة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _infoController,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'وصف / معلومات الوزارة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newName =
                        _nameController.text.trim();
                    final newInfo =
                        _infoController.text.trim();

                    if (newName.isNotEmpty) {
                      widget.ministry['name'] = newName;
                    }
                    if (newInfo.isNotEmpty) {
                      widget.ministry['info'] = newInfo;
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor:
                        theme.colorScheme.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حفظ التعديلات',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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