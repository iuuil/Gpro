// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  static const Color primaryColor = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF101922);

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedDepartment;
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;

  final List<DropdownMenuItem<String>> _departments = const [
    DropdownMenuItem(
      value: 'legal',
      child: Text('الدائرة القانونية'),
    ),
    DropdownMenuItem(
      value: 'it',
      child: Text('قسم تكنولوجيا المعلومات'),
    ),
    DropdownMenuItem(
      value: 'public_relations',
      child: Text('العلاقات العامة'),
    ),
    DropdownMenuItem(
      value: 'monitoring',
      child: Text('قسم المتابعة والرقابة'),
    ),
  ];

  Color? get backgroundLight => AdminRegisterScreen.backgroundLight;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على شروط الاستخدام وسياسة الخصوصية'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final employeeId = _employeeIdController.text.trim();
    final password = _passwordController.text.trim();
    final department = _selectedDepartment;

    // تحقق من قوة كلمة المرور: 8 أحرف على الأقل + حروف + أرقام + رموز
    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~^%\-_+=<>?]).{8,}$');

    if (!passwordRegex.hasMatch(password)) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمة المرور يجب أن تكون قوية (8 أحرف على الأقل وتحتوي على حروف وأرقام ورموز).',
          ),
        ),
      );
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // 1) التحقق أن هذا البريد + الرقم الوظيفي موجودين في allowed_admins
      final allowedQuery = await firestore
          .collection('allowed_admins')
          .where('email', isEqualTo: email)
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (allowedQuery.docs.isEmpty) {
        // ليس ضمن قائمة المسؤولين المعتمدين
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا يمكنك التسجيل لأنك لست مسؤولاً معتمداً (تحقق من البريد والرقم الوظيفي).',
            ),
          ),
        );
        return;
      }

      // 2) إنشاء حساب في FirebaseAuth (مسؤول فقط إذا كان في allowed_admins)
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;

      if (user == null) {
        throw Exception('تعذر إنشاء حساب المسؤول، الرجاء المحاولة مرة أخرى.');
      }

      await user.updateDisplayName(fullName);

      // 3) حفظ بيانات المسؤول في Firestore داخل collection admins
      await firestore.collection('admins').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'employeeId': employeeId,
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'admin',
      });

      // 4) رسالة نجاح + تحويل مباشرة لصفحة لوحة تحكم المسؤول
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء حساب المسؤول بنجاح.'),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-dashboard',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء إنشاء الحساب.';
      if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة، يرجى اختيار كلمة مرور أقوى.';
      } else if (e.code == 'email-already-in-use') {
        message = 'يوجد حساب مسؤول مسجل بهذا البريد الإلكتروني.';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صالحة.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundLight,
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // الهيدر العلوي
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: backgroundLight?.withOpacity(0.9),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: Color(0xFF020617),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'تسجيل حساب مسؤول',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF020617),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF020617),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'يرجى إدخال البيانات المطلوبة لتسجيل حساب مسؤول في تطبيق "صوت المواطن".',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // الاسم الكامل
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 18,
                                      color: AdminRegisterScreen.primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'الاسم الكامل',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _fullNameController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'أدخل الاسم الثلاثي كما في الهوية الرسمية',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'يرجى إدخال الاسم الكامل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // البريد الإلكتروني الوزاري
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 18,
                                      color: AdminRegisterScreen.primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'البريد الإلكتروني الوزاري',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textDirection: TextDirection.ltr,
                                  decoration: InputDecoration(
                                    hintText: 'example@ministry.gov.iq',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'يرجى إدخال البريد الإلكتروني';
                                    }
                                    if (!value.contains('@')) {
                                      return 'بريد إلكتروني غير صالح';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // الرقم الوظيفي
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.badge_outlined,
                                      size: 18,
                                      color: AdminRegisterScreen.primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'الرقم الوظيفي',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _employeeIdController,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل رقم الهوية الوظيفية',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'يرجى إدخال الرقم الوظيفي';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // القسم / الدائرة
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.account_tree_outlined,
                                      size: 18,
                                      color: AdminRegisterScreen.primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'القسم / الدائرة',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedDepartment,
                                  items: _departments,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDepartment = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'اختر القسم المعني',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى اختيار القسم';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // كلمة المرور
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 18,
                                      color: AdminRegisterScreen.primaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'كلمة المرور',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'أدخل كلمة مرور قوية',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFF64748B),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'يرجى إدخال كلمة المرور';
                                    }
                                    if (value.length < 8) {
                                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // الشروط والأحكام
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                      activeColor:
                                          AdminRegisterScreen.primaryColor,
                                    ),
                                    const Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'أوافق على ',
                                            ),
                                            TextSpan(
                                              text: 'شروط الاستخدام',
                                              style: TextStyle(
                                                color: AdminRegisterScreen
                                                    .primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' و ',
                                            ),
                                            TextSpan(
                                              text: 'سياسة الخصوصية',
                                              style: TextStyle(
                                                color: AdminRegisterScreen
                                                    .primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' الخاصة بالبوابة الحكومية.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // زر التسجيل
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isSubmitting ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AdminRegisterScreen.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'تسجيل حساب مسؤول',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // رابط تسجيل الدخول
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/admin-login');
                              },
                              child: const Text(
                                'لديك حساب بالفعل؟ تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AdminRegisterScreen.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // خط زخرفي سفلي
                  Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AdminRegisterScreen.primaryColor,
                          Color(0x80137FEC),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
