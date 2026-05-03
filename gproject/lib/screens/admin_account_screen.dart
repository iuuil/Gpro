// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// باكدجات حفظ الملف واختيار الصورة من المعرض
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'citizen_details_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({
    super.key,
    this.onBackToDashboard,
  });

  static const Color primary = Color(0xFF137FEC);
  static const Color bgLight = Color(0xFFF6F7F8);

  final VoidCallback? onBackToDashboard;

  @override
  State<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState
    extends State<AdminProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;

  // بيانات المسؤول
  String _fullName = '';
  String _email = '';
  String _employeeId = '';
  String _department = '';
  DateTime? _createdAt;

  // مسار الصورة المخزَّنة محليًا (نفس فكرة المستخدم)
  String _avatarPath = '';

  // Controllers للتحرير
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();

  // حقول تغيير كلمة المرور
  final _currentPasswordController =
      TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  // إحصائيات الشكاوى
  int _resolvedComplaintsCount = 0;
  int _pendingComplaintsCount = 0;
  bool _isStatsLoading = true;

  // لا نستخدم getter bgLight (كان مسبب لبس)
  Color? get bgLight => null;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
    _loadComplaintsStats();
  }

  // تحقق من قوة كلمة المرور (حروف + أرقام + رموز، على الأقل 6)
  bool _isStrongPassword(String password) {
    if (password.length < 6) return false;

    final hasLetter =
        password.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\\-]'));

    return hasLetter && hasDigit && hasSpecial;
  }

  // دالة إظهار تنبيه منسق بزر "حسنًا"
  Future<void> _showAlert(String message) async {
    final theme = Theme.of(context);
    final dialogTheme = theme.dialogTheme;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: dialogTheme.shape ??
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
            content: Text(
              message,
              style: dialogTheme.contentTextStyle ??
                  theme.textTheme.bodyMedium
                      ?.copyWith(fontSize: 14),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(),
                child: Text(
                  'حسنًا',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadAdminProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main-shell',
          (route) => false,
        );
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main-shell',
          (route) => false,
        );
        return;
      }

      final data = doc.data() ?? {};

      setState(() {
        _fullName =
            (data['fullName'] ?? '') as String;
        _email = (data['email'] ?? '') as String;
        _employeeId =
            (data['employeeId'] ?? '') as String;
        _department =
            (data['department'] ?? '') as String;
        final ts = data['createdAt'];
        if (ts != null && ts is Timestamp) {
          _createdAt = ts.toDate();
        }

        // تحميل مسار الصورة إذا موجود
        _avatarPath =
            (data['avatarPath'] as String? ?? '')
                .toString();

        _nameController.text = _fullName;
        _emailController.text = _email;
        _employeeIdController.text = _employeeId;
        _departmentController.text = _department;

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      await _showAlert(
          'فشل تحميل بيانات المسؤول: $e');
    }
  }

  Future<void> _loadComplaintsStats() async {
    try {
      // الشكاوى المعالجة (resolved أو closed)
      final resolvedSnap =
          await FirebaseFirestore.instance
              .collection('complaints')
              .where('status', whereIn: [
        'resolved',
        'closed'
      ]).get();

      // الشكاوى المعلقة
      final pendingSnap =
          await FirebaseFirestore.instance
              .collection('complaints')
              .where('status', whereIn: [
        'pending',
        'suspended'
      ]).get();

      setState(() {
        _resolvedComplaintsCount =
            resolvedSnap.docs.length;
        _pendingComplaintsCount =
            pendingSnap.docs.length;
        _isStatsLoading = false;
      });
    } catch (e) {
      setState(() => _isStatsLoading = false);
      await _showAlert(
          'فشل تحميل إحصائيات الشكاوى: $e');
    }
  }

  /// اختيار صورة من المعرض، حفظها في مجلد التطبيق، وتحديث admins.avatarPath
  Future<void> _pickAndSaveAvatar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final XFile? picked =
          await _picker.pickImage(
              source: ImageSource.gallery);
      if (picked == null) return;

      final dir =
          await getApplicationDocumentsDirectory();
      final ext = p.extension(picked.path);
      final fileName = 'admin_avatar_${user.uid}$ext';
      final savedFile = await File(picked.path)
          .copy(p.join(dir.path, fileName));

      setState(() {
        _avatarPath = savedFile.path;
      });

      await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .set(
        {
          'avatarPath': _avatarPath,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      await _showAlert(
          'حدث خطأ أثناء اختيار الصورة: $e');
    }
  }

  Future<void> _toggleEditOrSave() async {
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newEmployeeId =
        _employeeIdController.text.trim();
    final newDepartment =
        _departmentController.text.trim();

    final currentPassword =
        _currentPasswordController.text.trim();
    final newPassword =
        _newPasswordController.text.trim();
    final confirmPassword =
        _confirmPasswordController.text.trim();

    if (newName.isEmpty ||
        newEmail.isEmpty ||
        newEmployeeId.isEmpty ||
        newDepartment.isEmpty) {
      await _showAlert(
          'يرجى ملء جميع الحقول قبل الحفظ');
      return;
    }

    // هل يريد تغيير كلمة المرور؟
    final wantsToChangePassword =
        currentPassword.isNotEmpty ||
            newPassword.isNotEmpty ||
            confirmPassword.isNotEmpty;

    if (wantsToChangePassword) {
      if (currentPassword.isEmpty ||
          newPassword.isEmpty ||
          confirmPassword.isEmpty) {
        await _showAlert(
          'يرجى ملء حقول كلمة المرور الثلاثة لتغيير كلمة المرور',
        );
        return;
      }

      if (newPassword != confirmPassword) {
        await _showAlert(
          'كلمة المرور الجديدة وتأكيدها غير متطابقتين',
        );
        return;
      }

      if (!_isStrongPassword(newPassword)) {
        await _showAlert(
          'يجب أن تتكون كلمة المرور الجديدة من حروف وأرقام ورموز، وألا تقل عن 6 أحرف.',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // تحديث بيانات Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .update({
        'fullName': newName,
        'email': newEmail,
        'employeeId': newEmployeeId,
        'department': newDepartment,
        // نخزن أيضًا avatarPath (لو تغيّر)
        'avatarPath': _avatarPath,
      });

      // تحديث بيانات حساب Firebase Auth
      await user.updateDisplayName(newName);
      if (user.email != newEmail) {
        await user.updateEmail(newEmail);
      }

      // تغيير كلمة المرور إذا مطلوب
      if (wantsToChangePassword) {
        final credential =
            EmailAuthProvider.credential(
          email: newEmail,
          password: currentPassword,
        );

        try {
          await user
              .reauthenticateWithCredential(
                  credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password' ||
              e.code == 'invalid-credential') {
            await _showAlert(
              'كلمة المرور الحالية غير صحيحة يرجى المحاولة مرة اخرى',
            );
            setState(() => _isLoading = false);
            return;
          } else {
            await _showAlert(
              'خطأ في التحقق من كلمة المرور: ${e.message}',
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        await user.updatePassword(newPassword);

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }

      setState(() {
        _fullName = newName;
        _email = newEmail;
        _employeeId = newEmployeeId;
        _department = newDepartment;
        _isEditing = false;
        _isLoading = false;
      });

      await _showAlert(
        wantsToChangePassword
            ? 'تم حفظ الملف الشخصي وتغيير كلمة المرور بنجاح'
            : 'تم حفظ الملف الشخصي بنجاح',
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      await _showAlert(
          'خطأ في تحديث بيانات الحساب: ${e.message}');
    } catch (e) {
      setState(() => _isLoading = false);
      await _showAlert(
          'حدث خطأ أثناء حفظ البيانات: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main-shell',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;

    if (_isLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              theme.scaffoldBackgroundColor,
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.appBarTheme
                          .backgroundColor ??
                      cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.07),
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
                        color: theme
                                .appBarTheme
                                .iconTheme
                                ?.color ??
                            primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الملف الشخصي',
                        textAlign: TextAlign.center,
                        style: theme
                            .textTheme.bodyLarge
                            ?.copyWith(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w700,
                          color: theme
                                  .appBarTheme
                                  .foregroundColor ??
                              theme.textTheme
                                  .bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // معلومات البروفايل + الصورة
                      Padding(
                        padding:
                            const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior:
                                  Clip.none,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,
                                    border: Border.all(
                                      color: theme
                                          .scaffoldBackgroundColor,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                                0.08),
                                        blurRadius: 6,
                                        offset:
                                            const Offset(
                                                0, 3),
                                      ),
                                    ],
                                    color: theme
                                        .colorScheme
                                        .surfaceVariant,
                                    image: _avatarPath
                                            .isNotEmpty
                                        ? DecorationImage(
                                            image:
                                                FileImage(
                                              File(
                                                  _avatarPath),
                                            ),
                                            fit: BoxFit
                                                .cover,
                                          )
                                        : null,
                                  ),
                                  child: _avatarPath
                                          .isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 60,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap:
                                        _pickAndSaveAvatar,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                24),
                                    child: Container(
                                      padding:
                                          const EdgeInsets
                                              .all(6),
                                      decoration:
                                          BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .primary,
                                        shape:
                                            BoxShape.circle,
                                        border:
                                            Border.all(
                                          color: theme
                                              .cardColor,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors
                                                .black
                                                .withOpacity(
                                                    0.15),
                                            blurRadius:
                                                4,
                                            offset:
                                                const Offset(
                                                    0,
                                                    2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons
                                            .photo_camera,
                                        size: 16,
                                        color: theme
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _fullName.isEmpty
                                  ? 'مسؤول النظام'
                                  : _fullName,
                              style: theme
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                              textAlign:
                                  TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'مسؤول النظام',
                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600,
                                color: primary,
                              ),
                              textAlign:
                                  TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 16,
                                  color:
                                      theme.hintColor,
                                ),
                                const SizedBox(
                                    width: 4),
                                Text(
                                  _employeeId.isEmpty
                                      ? 'رقم الهوية غير محدد'
                                      : 'رقم الهوية: $_employeeId',
                                  style: theme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    fontSize: 12,
                                    color: theme
                                        .hintColor,
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
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                'ملخص الإحصائيات',
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  letterSpacing:
                                      0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_isStatsLoading)
                              const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(
                                          12.0),
                                  child:
                                      CircularProgressIndicator(),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        MouseRegion(
                                      cursor:
                                          SystemMouseCursors
                                              .click,
                                      child:
                                          GestureDetector(
                                        onTap: () {
                                          Navigator
                                              .push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CitizenDetailsScreen(
                                                filterStatus:
                                                    'resolved',
                                                userDocId:
                                                    '',
                                              ),
                                            ),
                                          );
                                        },
                                        child:
                                            _StatCardProfile(
                                          icon: Icons
                                              .fact_check_outlined,
                                          iconColor:
                                              primary,
                                          iconBg: primary
                                              .withOpacity(
                                                  0.1),
                                          trendText:
                                              '',
                                          trendColor:
                                              const Color(
                                                  0xFF059669),
                                          title:
                                              'الشكاوى المعالجة',
                                          value: _resolvedComplaintsCount
                                              .toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 12),
                                  Expanded(
                                    child:
                                        MouseRegion(
                                      cursor:
                                          SystemMouseCursors
                                              .click,
                                      child:
                                          GestureDetector(
                                        onTap: () {
                                          Navigator
                                              .push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CitizenDetailsScreen(
                                                filterStatus:
                                                    'pending',
                                                userDocId:
                                                    '',
                                              ),
                                            ),
                                          );
                                        },
                                        child:
                                            _StatCardProfile(
                                          icon: Icons
                                              .pending_actions_outlined,
                                          iconColor:
                                              const Color(
                                                  0xFFF59E0B),
                                          iconBg:
                                              const Color(
                                                      0xFFF59E0B)
                                                  .withOpacity(
                                                      0.1),
                                          trendText:
                                              '',
                                          trendColor:
                                              const Color(
                                                  0xFF059669),
                                          title:
                                              'الشكاوى المعلقة',
                                          value: _pendingComplaintsCount
                                              .toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // المعلومات الشخصية + حقول كلمة المرور
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .all(16),
                                child: Text(
                                  'المعلومات الشخصية',
                                  style: theme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize: 14,
                                    color: theme
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: borderColor,
                              ),
                              if (!_isEditing) ...[
                                _InfoRow(
                                  label: 'الاسم الكامل',
                                  value: _fullName,
                                  icon: Icons
                                      .person_outline,
                                ),
                                _InfoRow(
                                  label:
                                      'البريد الإلكتروني الرسمي',
                                  value: _email,
                                  icon: Icons
                                      .mail_outline,
                                ),
                                _InfoRow(
                                  label:
                                      'الوزارة / القسم',
                                  value:
                                      _department,
                                  icon: Icons
                                      .account_balance_outlined,
                                ),
                                _InfoRow(
                                  label:
                                      'الرقم الوظيفي',
                                  value:
                                      _employeeId,
                                  icon: Icons
                                      .badge_outlined,
                                ),
                                _InfoRow(
                                  label:
                                      'تاريخ الانضمام',
                                  value: _createdAt ==
                                          null
                                      ? 'غير متوفر'
                                      : '${_createdAt!.day}/${_createdAt!.month}/${_createdAt!.year}',
                                  icon: Icons
                                      .calendar_today_outlined,
                                ),
                              ] else ...[
                                _EditableField(
                                  label: 'الاسم الكامل',
                                  icon: Icons
                                      .person_outline,
                                  controller:
                                      _nameController,
                                ),
                                _EditableField(
                                  label:
                                      'البريد الإلكتروني الرسمي',
                                  icon: Icons
                                      .mail_outline,
                                  controller:
                                      _emailController,
                                  textDirection:
                                      TextDirection
                                          .ltr,
                                ),
                                _EditableField(
                                  label:
                                      'الوزارة / القسم',
                                  icon: Icons
                                      .account_balance_outlined,
                                  controller:
                                      _departmentController,
                                ),
                                _EditableField(
                                  label:
                                      'الرقم الوظيفي',
                                  icon: Icons
                                      .badge_outlined,
                                  controller:
                                      _employeeIdController,
                                ),
                                _PasswordField(
                                  label:
                                      'كلمة المرور الحالية',
                                  icon: Icons
                                      .lock_outline,
                                  controller:
                                      _currentPasswordController,
                                ),
                                _PasswordField(
                                  label:
                                      'كلمة المرور الجديدة',
                                  icon: Icons
                                      .lock_reset_outlined,
                                  controller:
                                      _newPasswordController,
                                ),
                                _PasswordField(
                                  label:
                                      'تأكيد كلمة المرور الجديدة',
                                  icon: Icons
                                      .lock_outline,
                                  controller:
                                      _confirmPasswordController,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // الأزرار
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton
                                  .icon(
                                style: ElevatedButton
                                    .styleFrom(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 14,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                16),
                                  ),
                                  elevation: 4,
                                ),
                                icon: Icon(
                                  _isEditing
                                      ? Icons
                                          .save_outlined
                                      : Icons
                                          .edit_outlined,
                                ),
                                label: Text(
                                  _isEditing
                                      ? 'حفظ الملف الشخصي'
                                      : 'تعديل الملف الشخصي',
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize: 14,
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _toggleEditOrSave,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: _logout,
                              icon: Icon(
                                Icons.logout,
                                color: theme
                                    .colorScheme
                                    .error,
                              ),
                              label: Text(
                                'تسجيل الخروج',
                                style: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  fontSize: 14,
                                  color: theme
                                      .colorScheme
                                      .error,
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

extension on User {
  Future<void> updateEmail(String newEmail) async {}
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
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                padding:
                    const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              if (trendText.isNotEmpty)
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
                        fontWeight:
                            FontWeight.w700,
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
            style: theme.textTheme.bodySmall
                ?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// صف معلومات read-only
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
    final theme = Theme.of(context);
    return Column(
      children: [
        Divider(
          height: 1,
          color: theme.dividerColor,
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(
                  fontSize: 11,
                  color: theme.hintColor,
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
                      style: theme
                          .textTheme.bodyMedium
                          ?.copyWith(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w500,
                        color: theme
                            .colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: theme.hintColor,
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

// صف قابل للتحرير (نص عادي)
class _EditableField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextDirection? textDirection;

  const _EditableField({
    required this.label,
    required this.icon,
    required this.controller,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Divider(
          height: 1,
          color: theme.dividerColor,
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(
                  fontSize: 11,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textDirection: textDirection,
                      decoration:
                          const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: theme.hintColor,
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

// حقل كلمة مرور (مع إخفاء/إظهار)
class _PasswordField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;

  const _PasswordField({
    required this.label,
    required this.icon,
    required this.controller,
  });

  @override
  State<_PasswordField> createState() =>
      _PasswordFieldState();
}

class _PasswordFieldState
    extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Column(
      children: [
        Divider(
          height: 1,
          color: theme.dividerColor,
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(
                  fontSize: 11,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          widget.controller,
                      obscureText: _obscure,
                      textDirection:
                          TextDirection.ltr,
                      decoration:
                          InputDecoration(
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
                            color: theme
                                .colorScheme
                                .primary,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? theme.colorScheme
                                .surfaceVariant
                            : const Color(
                                0xFFF9FAFB),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons
                                    .visibility_off
                                : Icons.visibility,
                            size: 18,
                            color: theme.iconTheme
                                    .color
                                    ?.withOpacity(
                                        0.6) ??
                                const Color(
                                    0xFF9CA3AF),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.icon,
                    size: 18,
                    color: theme.iconTheme.color
                            ?.withOpacity(0.6) ??
                        const Color(0xFF9CA3AF),
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