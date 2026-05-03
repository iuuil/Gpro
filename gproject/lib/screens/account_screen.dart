// ignore_for_file: unused_local_variable, deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// باكدجات حفظ الملف واختيار الصورة من المعرض
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'user_complaints_list_screen.dart';

class UserComplaintStats {
  final int activeCount;
  final int resolvedCount;

  const UserComplaintStats({
    required this.activeCount,
    required this.resolvedCount,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color primary = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();

  // حقول تغيير كلمة المرور
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Map<String, dynamic> _userData = {};
  UserComplaintStats? _stats;

  // مسار الصورة المخزنة محليًا
  String _avatarPath = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Alert منسق بزر "حسنًا"
  Future<void> _showAlert(String message) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'حسنًا',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // تحقق من قوة كلمة المرور (حروف + أرقام + رموز، على الأقل 6)
  bool _isStrongPassword(String password) {
    if (password.length < 6) return false;
    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'));
    return hasLetter && hasDigit && hasSpecial;
  }

  Future<UserComplaintStats> _loadUserStats(String uid) async {
    final complaintsRef =
        FirebaseFirestore.instance.collection('complaints');

    final activeSnap = await complaintsRef
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final resolvedSnap = await complaintsRef
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'resolved')
        .get();

    return UserComplaintStats(
      activeCount: activeSnap.size,
      resolvedCount: resolvedSnap.size,
    );
  }

  Future<Map<String, dynamic>> _loadProfileData(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final stats = await _loadUserStats(uid);
    final data = userDoc.data() ?? <String, dynamic>{};

    _userData = data;
    _stats = stats;

    final authUser = FirebaseAuth.instance.currentUser;

    // الاسم: من users.fullName ثم displayName ثم جزء الإيميل
    _fullNameController.text =
        (data['fullName'] as String?) ??
            (authUser?.displayName) ??
            (authUser?.email?.split('@').first ?? '');

    _emailController.text =
        (data['email'] as String? ?? authUser?.email ?? '').toString();
    _phoneController.text =
        (data['phone'] as String? ?? '').toString();
    _nationalIdController.text =
        (data['nationalId'] as String? ?? '').toString();

    // تحميل مسار الصورة من Firestore إذا موجود
    _avatarPath =
        (data['avatarPath'] as String? ?? '').toString();

    return {
      'userData': data,
      'stats': stats,
    };
  }

  Future<void> _saveProfileAndPassword(String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final nationalId = _nationalIdController.text.trim();

      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (fullName.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          nationalId.isEmpty) {
        await _showAlert('يرجى ملء جميع الحقول قبل الحفظ');
        return;
      }

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

      // تحديث Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
        {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'nationalId': nationalId,
          // نخزن مسار الصورة المحلية
          'avatarPath': _avatarPath,
        },
        SetOptions(merge: true),
      );

      // تحديث FirebaseAuth (الاسم + كلمة المرور إن لزم)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (fullName.isNotEmpty && fullName != user.displayName) {
          await user.updateDisplayName(fullName);
        }

        if (wantsToChangePassword) {
          final credential = EmailAuthProvider.credential(
            email: user.email ?? email,
            password: currentPassword,
          );

          try {
            await user.reauthenticateWithCredential(credential);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'wrong-password' ||
                e.code == 'invalid-credential') {
              await _showAlert(
                'كلمة المرور الحالية غير صحيحة، يرجى المحاولة مرة أخرى',
              );
              return;
            } else {
              await _showAlert(
                'خطأ في التحقق من كلمة المرور: ${e.message}',
              );
              return;
            }
          }

          await user.updatePassword(newPassword);

          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }

        await user.reload();
      }

      setState(() {
        _isEditing = false;
      });

      if (!mounted) return;
      await _showAlert(
        'تم حفظ الملف الشخصي'
        '${wantsToChangePassword ? ' وتغيير كلمة المرور بنجاح' : ' بنجاح'}',
      );
    } catch (e) {
      if (!mounted) return;
      await _showAlert('حدث خطأ أثناء الحفظ: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main-shell',
      (route) => false,
    );
  }

  /// اختيار صورة من المعرض وحفظها في مجلد التطبيق وتحديث Firestore
  Future<void> _pickAndSaveAvatar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }

      // مسار مجلد التطبيق
      final dir = await getApplicationDocumentsDirectory(); // [web:297][web:299][web:303]
      final ext = p.extension(picked.path);
      final fileName = 'avatar_${user.uid}$ext';
      final savedFile = await File(picked.path)
          .copy(p.join(dir.path, fileName)); // [web:299][web:302][web:300]

      setState(() {
        _avatarPath = savedFile.path;
      });

      // تحديث Firestore بحقل avatarPath
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'avatarPath': _avatarPath,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      await _showAlert('حدث خطأ أثناء اختيار الصورة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ProfileScreen.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
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
                        'الملف الشخصي',
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

              // المحتوى + الأزرار المثبتة أسفل الصفحة
              Expanded(
                child: user == null
                    ? const Center(
                        child: Text(
                          'يرجى تسجيل الدخول لعرض الملف الشخصي.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      )
                    : FutureBuilder<Map<String, dynamic>>(
                        future: _loadProfileData(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'حدث خطأ أثناء جلب بيانات الحساب: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB91C1C),
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData || _stats == null) {
                            return const Center(
                              child: Text(
                                'لم يتم العثور على بيانات لهذا الحساب.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            );
                          }

                          final data = _userData;
                          final stats = _stats!;

                          final currentUser =
                              FirebaseAuth.instance.currentUser;

                          final fullName =
                              _fullNameController.text.isNotEmpty
                                  ? _fullNameController.text
                                  : (data['fullName'] as String? ??
                                      currentUser?.displayName ??
                                      'مستخدم');

                          final city =
                              (data['city'] as String? ?? 'غير محددة')
                                  .toString();

                          final activeComplaints = stats.activeCount;
                          final resolvedComplaints = stats.resolvedCount;

                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    children: [
                                      // Profile section
                                      Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          children: [
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 4,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.08),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                    color: const Color(
                                                        0xFFD1D5DB),
                                                    image: _avatarPath
                                                            .isNotEmpty
                                                        ? DecorationImage(
                                                            image: FileImage(
                                                              File(_avatarPath),
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child: _avatarPath.isEmpty
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 60,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    onTap: _pickAndSaveAvatar,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: ProfileScreen
                                                            .primary,
                                                        shape:
                                                            BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.15),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Icon(
                                                        Icons.photo_camera,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              fullName,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              city,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ملخص الشكاوى
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: Text(
                                                'ملخص الشكاوى',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                // الشكاوى النشطة
                                                Expanded(
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              const UserComplaintsListScreen(
                                                            status: 'pending',
                                                            title:
                                                                'الشكاوى النشطة',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFE5E7EB),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.03),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .pending_actions,
                                                                color: Color(
                                                                    0xFFF59E0B),
                                                              ),
                                                              SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                'الشكاوى النشطة',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color(
                                                                      0xFF6B7280),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Text(
                                                            activeComplaints
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 26,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Color(
                                                                  0xFF0F172A),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // الشكاوى المكتملة
                                                Expanded(
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              const UserComplaintsListScreen(
                                                            status: 'resolved',
                                                            title:
                                                                'الشكاوى المكتملة',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFE5E7EB),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.03),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.task_alt,
                                                                color: Color(
                                                                    0xFF10B981),
                                                              ),
                                                              SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                'الشكاوى المكتملة',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color(
                                                                      0xFF6B7280),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 6),
                                                          Text(
                                                            resolvedComplaints
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 26,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Color(
                                                                  0xFF0F172A),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // المعلومات الشخصية
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: Text(
                                                'المعلومات الشخصية',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFFE5E7EB),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.03),
                                                    blurRadius: 4,
                                                    offset:
                                                        const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  _ProfileField(
                                                    label: 'الاسم الكامل',
                                                    icon: Icons.person,
                                                    controller:
                                                        _fullNameController,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _ProfileField(
                                                    label: 'البريد الإلكتروني',
                                                    icon: Icons.mail_outline,
                                                    controller:
                                                        _emailController,
                                                    keyboardType:
                                                        TextInputType
                                                            .emailAddress,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _ProfileField(
                                                    label: 'رقم الهاتف',
                                                    icon: Icons.call,
                                                    controller:
                                                        _phoneController,
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    ltr: true,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _ProfileField(
                                                    label:
                                                        'رقم البطاقة الوطنية',
                                                    icon:
                                                        Icons.badge_outlined,
                                                    controller:
                                                        _nationalIdController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    ltr: true,
                                                    enabled: _isEditing,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // حقول كلمة المرور في وضع التعديل فقط
                                      if (_isEditing) ...[
                                        const SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                child: Text(
                                                  'تغيير كلمة المرور',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16),
                                                  border: Border.all(
                                                    color: const Color(
                                                        0xFFE5E7EB),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.03),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: [
                                                    _PasswordField(
                                                      label:
                                                          'كلمة المرور الحالية',
                                                      icon: Icons.lock_outline,
                                                      controller:
                                                          _currentPasswordController,
                                                    ),
                                                    const SizedBox(
                                                        height: 12),
                                                    _PasswordField(
                                                      label:
                                                          'كلمة المرور الجديدة',
                                                      icon: Icons
                                                          .lock_reset_outlined,
                                                      controller:
                                                          _newPasswordController,
                                                    ),
                                                    const SizedBox(
                                                        height: 12),
                                                    _PasswordField(
                                                      label:
                                                          'تأكيد كلمة المرور الجديدة',
                                                      icon: Icons.lock_outline,
                                                      controller:
                                                          _confirmPasswordController,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              // الأزرار المثبتة أسفل الصفحة
                              SafeArea(
                                top: false,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _isSaving
                                              ? null
                                              : () {
                                                  if (_isEditing) {
                                                    _saveProfileAndPassword(
                                                        user.uid);
                                                  } else {
                                                    setState(() {
                                                      _isEditing = true;
                                                    });
                                                  }
                                                },
                                          icon: _isSaving
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Icon(
                                                  _isEditing
                                                      ? Icons.save_outlined
                                                      : Icons.edit_outlined,
                                                ),
                                          label: Text(
                                            _isEditing
                                                ? 'حفظ الملف الشخصي'
                                                : 'تعديل الملف الشخصي',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ProfileScreen.primary,
                                            foregroundColor: Colors.white,
                                            padding:
                                                const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 4,
                                            shadowColor: ProfileScreen.primary
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: _logout,
                                          icon: const Icon(
                                            Icons.logout,
                                            color: Color(0xFFDC2626),
                                          ),
                                          label: const Text(
                                            'تسجيل الخروج',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFDC2626),
                                              fontSize: 14,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFDC2626),
                                            ),
                                            padding:
                                                const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool ltr;
  final bool enabled;

  const _ProfileField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.keyboardType,
    this.ltr = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              textDirection:
                  ltr ? TextDirection.ltr : TextDirection.rtl,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                filled: true,
                fillColor:
                    enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: ProfileScreen.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            TextField(
              controller: widget.controller,
              obscureText: _obscure,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: ProfileScreen.primary,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 18,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Icon(
                widget.icon,
                size: 20,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}