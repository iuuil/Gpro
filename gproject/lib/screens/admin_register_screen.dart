// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  static const Color primaryColor = Color(0xFF137FEC);

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
          content:
              Text('يجب الموافقة على شروط الاستخدام وسياسة الخصوصية'),
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

    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~^%\-_+=<>?]).{8,}$',
    );

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

      final allowedQuery = await firestore
          .collection('allowed_admins')
          .where('email', isEqualTo: email)
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (allowedQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا يمكنك التسجيل لأنك لست مسؤولاً معتمداً (تحقق من البريد والرقم الوظيفي).',
            ),
          ),
        );
        return;
      }

      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;

      if (user == null) {
        throw Exception(
          'تعذر إنشاء حساب المسؤول، الرجاء المحاولة مرة أخرى.',
        );
      }

      await user.updateDisplayName(fullName);

      await firestore.collection('admins').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'employeeId': employeeId,
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'admin',
      });

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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // الهيدر العلوي
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.appBarTheme.backgroundColor ??
                          theme.cardColor.withOpacity(0.9),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color:
                                  theme.appBarTheme.foregroundColor ??
                                      theme.iconTheme.color ??
                                      const Color(0xFF020617),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تسجيل حساب مسؤول',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
                          Text(
                            'إنشاء حساب جديد',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'يرجى إدخال البيانات المطلوبة لتسجيل حساب مسؤول في تطبيق "صوت المواطن".',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // الاسم الكامل
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 18,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'الاسم الكامل',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
                                    fillColor: theme.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'يرجى إدخال الاسم الكامل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // البريد الإلكتروني الوزاري
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 18,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'البريد الإلكتروني الوزاري',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  textDirection: TextDirection.ltr,
                                  decoration: InputDecoration(
                                    hintText:
                                        'example@ministry.gov.iq',
                                    filled: true,
                                    fillColor: theme.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.badge_outlined,
                                      size: 18,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'الرقم الوظيفي',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
                                    hintText:
                                        'أدخل رقم الهوية الوظيفية',
                                    filled: true,
                                    fillColor: theme.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'يرجى إدخال الرقم الوظيفي';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // القسم / الدائرة
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.account_tree_outlined,
                                      size: 18,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'القسم / الدائرة',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedDepartment,
                                  items: _departments,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDepartment = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'اختر القسم المعني',
                                    filled: true,
                                    fillColor: theme.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 18,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'كلمة المرور',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
                                    fillColor: theme.cardColor,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons
                                                .visibility_outlined
                                            : Icons
                                                .visibility_off_outlined,
                                        color: theme.iconTheme.color
                                                ?.withOpacity(0.7) ??
                                            const Color(0xFF64748B),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms =
                                              value ?? false;
                                        });
                                      },
                                      activeColor: primary,
                                    ),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                            fontSize: 13,
                                            color: theme.hintColor,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'أوافق على ',
                                            ),
                                            TextSpan(
                                              text: 'شروط الاستخدام',
                                              style: TextStyle(
                                                color: primary,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ' و ',
                                            ),
                                            TextSpan(
                                              text: 'سياسة الخصوصية',
                                              style: TextStyle(
                                                color: primary,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(
                                              text:
                                                  ' الخاصة بالبوابة الحكومية.',
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
                                    onPressed: _isSubmitting
                                        ? null
                                        : _submit,
                                    child: _isSubmitting
                                        ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child:
                                                CircularProgressIndicator(
                                              color: theme.colorScheme
                                                  .onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'تسجيل حساب مسؤول',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                    // باقي الـ style من ElevatedButtonTheme
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
                              child: Text(
                                'لديك حساب بالفعل؟ تسجيل الدخول',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 13,
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                  decoration:
                                      TextDecoration.underline,
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          primary,
                          primary.withOpacity(0.5),
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