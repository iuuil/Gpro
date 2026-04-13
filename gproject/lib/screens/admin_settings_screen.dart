import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({
    super.key,
    this.onBackToDashboard,
  });

  static const Color primary = Color(0xFF137FEC);
  static const Color bgLight = Color(0xFFF6F7F8);

  final VoidCallback? onBackToDashboard;

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isSearching = false;
  String _searchQuery = '';

  String _appName = 'صوت المواطن';
  String _logoDescription = 'تعديل الشعار الرسمي والهوية';

  final List<Map<String, String>> _ministries = [
    {'name': 'وزارة الداخلية', 'info': 'مسؤولة عن الأمن الداخلي'},
    {'name': 'وزارة الصحة', 'info': 'مسؤولة عن الخدمات الصحية'},
    {'name': 'وزارة التربية', 'info': 'مسؤولة عن التعليم المدرسي'},
    {'name': 'وزارة التعليم العالي', 'info': 'مسؤولة عن الجامعات'},
    {'name': 'وزارة الكهرباء', 'info': 'مسؤولة عن الطاقة الكهربائية'},
  ];

  Future<void> _showAppNameDialog() async {
    final controller = TextEditingController(text: _appName);
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'تعديل اسم التطبيق',
            textDirection: TextDirection.rtl,
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
    final controller = TextEditingController(text: _logoDescription);
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'تعديل الشعار والهوية',
            textDirection: TextDirection.rtl,
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
                  setState(() => _logoDescription = text);
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
        builder: (_) => MinistriesScreen(ministries: _ministries),
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
    final primary = AdminSettingsScreen.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminSettingsScreen.bgLight,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر + البحث
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
                        if (widget.onBackToDashboard != null) {
                          widget.onBackToDashboard!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF137FEC),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_isSearching)
                      const Expanded(
                        child: Text(
                          'إعدادات النظام',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF020617),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            autofocus: true,
                            textDirection: TextDirection.rtl,
                            decoration: InputDecoration(
                              hintText: 'بحث في الإعدادات...',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF137FEC),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {
                                _searchQuery = v.trim();
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
                        _isSearching ? Icons.close : Icons.search,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        const _SectionTitle('إعدادات عامة'),
                        if (_matchesSearch('اسم التطبيق', _appName))
                          _SettingsTile(
                            icon: Icons.settings_applications_outlined,
                            iconBg: primary,
                            title: 'اسم التطبيق',
                            subtitle: _appName,
                            onTap: _showAppNameDialog,
                          ),
                        if (_matchesSearch(
                            'شعار النظام', _logoDescription))
                          _SettingsTile(
                            icon: Icons.image_outlined,
                            iconBg: primary,
                            title: 'شعار النظام',
                            subtitle: _logoDescription,
                            onTap: _showLogoDialog,
                          ),

                        const Divider(height: 24),

                        const _SectionTitle('إدارة الوزارات'),
                        if (_matchesSearch(
                            'قائمة الوزارات',
                            'إضافة أو تعديل بيانات الجهات الحكومية'))
                          _SettingsTile(
                            icon: Icons.account_balance_outlined,
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
                            icon: Icons.contact_phone_outlined,
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
          fontWeight: FontWeight.w700,
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
    // ignore: unused_element_parameter
    super.key,
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
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
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

  const MinistriesScreen({super.key, required this.ministries});

  @override
  State<MinistriesScreen> createState() => _MinistriesScreenState();

  // ignore: body_might_complete_normally_nullable
  static Object? of(BuildContext context) {}
}

class _MinistriesScreenState extends State<MinistriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Color(0xFF020617)),
          title: const Text(
            'قائمة الوزارات',
            style: TextStyle(
              color: Color(0xFF020617),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFFF6F7F8),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.ministries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final m = widget.ministries[index];
            final name = m['name'] ?? '';
            final info = m['info'] ?? '';

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                info,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
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

  const MinistryEditScreen({super.key, required this.ministry});

  @override
  State<MinistryEditScreen> createState() => _MinistryEditScreenState();
}

class _MinistryEditScreenState extends State<MinistryEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _infoController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.ministry['name'] ?? '');
    _infoController =
        TextEditingController(text: widget.ministry['info'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Color(0xFF020617)),
          title: const Text(
            'تعديل بيانات الوزارة',
            style: TextStyle(
              color: Color(0xFF020617),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFFF6F7F8),
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
                    final newName = _nameController.text.trim();
                    final newInfo = _infoController.text.trim();

                    if (newName.isNotEmpty) {
                      widget.ministry['name'] = newName;
                    }
                    if (newInfo.isNotEmpty) {
                      widget.ministry['info'] = newInfo;
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137FEC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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