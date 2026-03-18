import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  static const Color primary = Color(0xFF137FEC);
  static const Color bgLight = Color(0xFFF6F7F8);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _selectedTabIndex = 0; // 0: المواطنون، 1: المسؤولون، 2: الحسابات المعلقة

  List<Widget> _buildCardsForTab(int index) {
    // هنا تقدر تعدل التوزيع الحقيقي لاحقاً من الداتا
    switch (index) {
      case 0: // المواطنون
        return const [
          _CitizenCardActive(),
          _CitizenCardInactive(),
        ];
      case 1: // المسؤولون
        return const [
          _OfficialCard(),
        ];
      case 2: // الحسابات المعلقة
        // مثال: نفترض أن سارة حسابها معلّق
        return const [
          _CitizenCardInactive(),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = _buildCardsForTab(_selectedTabIndex);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminUsersScreen.bgLight,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر (بدون أيقونة الإشعارات، فقط رجوع والعنوان)
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'إدارة المستخدمين',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF020617),
                        ),
                      ),
                    ),
                    // أيقونة الأدمن (مثل التصميم)
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AdminUsersScreen.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: AdminUsersScreen.primary.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: AdminUsersScreen.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // حقل البحث
                          _SearchField(),

                          const SizedBox(height: 16),

                          // التبويبات (مواطنون / مسؤولون / حسابات معلقة)
                          _UsersTabs(
                            selectedIndex: _selectedTabIndex,
                            onTabSelected: (index) {
                              setState(() {
                                _selectedTabIndex = index;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // شبكة بطاقات المستخدمين (تتغير حسب التب)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 700;
                              final crossAxisCount = isWide ? 2 : 1;
                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: isWide ? 2.3 : 1.95,
                                children: cards,
                              );
                            },
                          ),

                          const SizedBox(height: 80), // مساحة لفوق زر الإضافة
                        ],
                      ),
                    ),

                    // زر عائم لإضافة مستخدم جديد
                    /* Positioned(
                      left: 16,
                      bottom: 16,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminUsersScreen.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 6,
                          // ignore: deprecated_member_use
                          shadowColor:
                              // ignore: deprecated_member_use
                              AdminUsersScreen.primary.withOpacity(0.4),
                        ),
                        onPressed: () {
                          
                        },
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: const Text(
                          'إضافة مستخدم جديد',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ), */
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== حقل البحث ======================

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText:
            'البحث بالاسم، البريد الإلكتروني، أو المعرف...',
        hintStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: AdminUsersScreen.primary, width: 1.8),
        ),
      ),
    );
  }
}

// ====================== التبويبات ======================

class _UsersTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _UsersTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onTabSelected(0),
            child: _TabChip(
              label: 'المواطنون (١,٢٤٠)',
              selected: selectedIndex == 0,
            ),
          ),
          GestureDetector(
            onTap: () => onTabSelected(1),
            child: _TabChip(
              label: 'المسؤولون (٨٥)',
              selected: selectedIndex == 1,
            ),
          ),
          GestureDetector(
            onTap: () => onTabSelected(2),
            child: _TabChip(
              label: 'الحسابات المعلقة',
              selected: selectedIndex == 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabChip({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(left: 8, right: 0, bottom: 2),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected
                ? AdminUsersScreen.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color:
              selected ? AdminUsersScreen.primary : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// ====================== بطاقات المستخدمين ======================

// مواطن نشط
class _CitizenCardActive extends StatelessWidget {
  const _CitizenCardActive();

  @override
  Widget build(BuildContext context) {
    return _UserCard(
      name: 'أحمد محمود',
      id: '#USR-9842',
      statusLabel: 'نشط',
      statusColorBg: const Color(0xFFEFFDF3),
      statusColorText: const Color(0xFF16A34A),
      avatarType: _AvatarType.image,
      avatarImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAiWMtA7k_neitHXXnigGg1LziCvutcygHCjPoEPy49AFieylFsFiJ6rouNBn3oZfBchGt2uiLLWt40-PncHlvKFoy6yHsq4_yUoBi4XiaRG0A1AYdYy2EHMBY-lgt-r8hwUzDPFyUrvcwEh0ftKCMj-FUumjGtWz2b_JhHvkeaIaM1vzluz7mwTpn8JEWCiMzUNbnr7zitEKP5jArJocWbJD0eG8WfEa1p6YJPegJpRgUr3-jXYtctBFvQXGZzYSIRTyJiLKh9Bgi',
      role: 'الدور: مواطن',
      dateLabel: 'تاريخ التسجيل: ٢٠٢٣/١٠/٠١',
      email: 'ahmed.m@email.com',
      primaryButtonLabel: 'تعديل',
      // ignore: deprecated_member_use
      primaryButtonColorBg:
          // ignore: deprecated_member_use
          AdminUsersScreen.primary.withOpacity(0.08),
      primaryButtonColorText: AdminUsersScreen.primary,
      secondaryButtonLabel: 'تعليق',
      secondaryButtonColorBg: const Color(0xFFFFEDD5),
      secondaryButtonColorText: const Color(0xFFEA580C),
      showDelete: true,
    );
  }
}

// مواطن غير نشط
class _CitizenCardInactive extends StatelessWidget {
  const _CitizenCardInactive();

  @override
  Widget build(BuildContext context) {
    return _UserCard(
      name: 'سارة العامري',
      id: '#USR-7721',
      statusLabel: 'غير نشط',
      statusColorBg: const Color(0xFFF1F5F9),
      statusColorText: const Color(0xFF6B7280),
      avatarType: _AvatarType.image,
      avatarImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAkts0Kjq92S5yowFh-mPlVz3Fh5_70MG8GzqbKaUEWmnYOKieLQmhSkL1sHmSpuKim5nzld74h379mIfpd5lX0LTGAj4ygXc08Vvo6XuxsZPW-Nv1quRNCu-LnU1kDouhYtQAftUeBY_-HT9fFGSwKCPoiVa0nP303NFBoOTpS1U6KUQ7yC3gCQ8_toauOloiWIf0wBv2FjQgNFIEhy7a1wpBibMK7gEtInN71wB2fHLQePtAkuWQG_c5IxyzZPcuFwPSkZRlX4a_a',
      role: 'الدور: مواطن',
      dateLabel: 'تاريخ التسجيل: ٢٠٢٣/٠٩/١٥',
      email: 'sara.a@email.com',
      primaryButtonLabel: 'تعديل',
      // ignore: deprecated_member_use
      primaryButtonColorBg:
          // ignore: deprecated_member_use
          AdminUsersScreen.primary.withOpacity(0.08),
      primaryButtonColorText: AdminUsersScreen.primary,
      secondaryButtonLabel: 'تنشيط',
      secondaryButtonColorBg: const Color(0xFFDCFCE7),
      secondaryButtonColorText: const Color(0xFF16A34A),
      showDelete: true,
    );
  }
}

// مسؤول رسمي
class _OfficialCard extends StatelessWidget {
  const _OfficialCard();

  @override
  Widget build(BuildContext context) {
    return _UserCard(
      name: 'م. خالد العتيبي',
      id: '#OFF-3329',
      statusLabel: 'مسؤول',
      // ignore: deprecated_member_use
      statusColorBg: AdminUsersScreen.primary.withOpacity(0.08),
      statusColorText: AdminUsersScreen.primary,
      avatarType: _AvatarType.icon,
      avatarIcon: Icons.account_balance,
      role: 'الجهة: بلدية المنطقة الوسطى',
      dateLabel: 'تاريخ التعيين: ٢٠٢٣/٠١/١٠',
      email: 'khalid.o@municipality.gov.sa',
      primaryButtonLabel: 'إدارة الصلاحيات',
      primaryButtonColorBg: AdminUsersScreen.primary,
      primaryButtonColorText: Colors.white,
      secondaryIcon: Icons.more_horiz,
      showDelete: false,
    );
  }
}

enum _AvatarType { image, icon }

class _UserCard extends StatelessWidget {
  final String name;
  final String id;
  final String statusLabel;
  final Color statusColorBg;
  final Color statusColorText;

  final _AvatarType avatarType;
  final String? avatarImageUrl;
  final IconData? avatarIcon;

  final String role;
  final String dateLabel;
  final String email;

  final String primaryButtonLabel;
  final Color primaryButtonColorBg;
  final Color primaryButtonColorText;

  final String? secondaryButtonLabel;
  final Color? secondaryButtonColorBg;
  final Color? secondaryButtonColorText;

  final bool showDelete;
  final IconData? secondaryIcon;

  const _UserCard({
    required this.name,
    required this.id,
    required this.statusLabel,
    required this.statusColorBg,
    required this.statusColorText,
    required this.avatarType,
    this.avatarImageUrl,
    this.avatarIcon,
    required this.role,
    required this.dateLabel,
    required this.email,
    required this.primaryButtonLabel,
    required this.primaryButtonColorBg,
    required this.primaryButtonColorText,
    this.secondaryButtonLabel,
    this.secondaryButtonColorBg,
    this.secondaryButtonColorText,
    this.showDelete = false,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // الأعلى: الاسم + الحالة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة / الأيقونة
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF020617),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: $id',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColorBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColorText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // معلومات إضافية
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                text: role,
              ),
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: dateLabel,
              ),
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.mail_outline,
                text: email,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // الأزرار
          Row(
            children: [
              Expanded(
                child: _RoundedButton(
                  label: primaryButtonLabel,
                  bgColor: primaryButtonColorBg,
                  textColor: primaryButtonColorText,
                  filled: primaryButtonColorText == Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              if (secondaryButtonLabel != null)
                Expanded(
                  child: _RoundedButton(
                    label: secondaryButtonLabel!,
                    bgColor: secondaryButtonColorBg!,
                    textColor: secondaryButtonColorText!,
                  ),
                ),
              if (secondaryIcon != null) ...[
                const SizedBox(width: 6),
                _IconSquareButton(icon: secondaryIcon!),
              ],
              if (showDelete) ...[
                const SizedBox(width: 6),
                const _IconSquareButton(
                  icon: Icons.delete_outline,
                  bgColor: Color(0xFFFEE2E2),
                  iconColor: Color(0xFFDC2626),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarType == _AvatarType.image && avatarImageUrl != null) {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          avatarImageUrl!,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AdminUsersScreen.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AdminUsersScreen.primary.withOpacity(0.2),
        ),
      ),
      child: Icon(
        avatarIcon ?? Icons.person,
        color: AdminUsersScreen.primary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundedButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool filled;

  const _RoundedButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _IconSquareButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _IconSquareButton({
    required this.icon,
    this.bgColor = const Color(0xFFF1F5F9),
    this.iconColor = const Color(0xFF64748B),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 34,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          
        },
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }
}
