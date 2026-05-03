// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _saveAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء كل الحقول')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور وتأكيدها غير متطابقتين')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ); // [web:133]

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': name, // توحيد الاسم مع شاشة البروفايل
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      }); // [web:4]

      setState(() => _isSaving = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() => _isSaving = false);

      // ignore: avoid_print
      print('🔥 FirebaseAuthException code: ${e.code}');
      // ignore: avoid_print
      print('🔥 FirebaseAuthException message: ${e.message}');

      String message = 'حدث خطأ غير متوقع، حاول مرة أخرى';
      if (e.code == 'email-already-in-use') {
        message = 'هذا البريد مستخدم مسبقاً';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صحيحة';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة، جرب كلمة أقوى';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // AppBar مخصص
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      theme.appBarTheme.backgroundColor ?? theme.cardColor,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            textDirection: TextDirection.ltr,
                            size: 20,
                            color:
                                theme.appBarTheme.foregroundColor ??
                                    theme.iconTheme.color ??
                                    const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          'إنشاء حساب جديد',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            color:
                                theme.appBarTheme.foregroundColor ??
                                    theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // الاسم الكامل
                      Text(
                        'الاسم الكامل',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 16),
                            hintText: 'مثال، علي حسن',
                            hintStyle:
                                theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // البريد الإلكتروني
                      Text(
                        'البريد الإلكتروني',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 16),
                            hintText: 'مثال، example@email.com',
                            hintStyle:
                                theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // رقم الهاتف
                      Text(
                        'رقم الهاتف',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+964',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: 14,
                                  color: theme.hintColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 16),
                                  hintText: '770 123 4567',
                                  hintStyle: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // كلمة المرور
                      Text(
                        'كلمة المرور',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 16),
                                  hintText: 'أدخل كلمة مرور آمنة',
                                  hintStyle: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: theme.iconTheme.color
                                        ?.withOpacity(0.7) ??
                                    const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // تأكيد كلمة المرور
                      Text(
                        'تأكيد كلمة المرور',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 16),
                                  hintText: 'أعد إدخال كلمة المرور',
                                  hintStyle: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: theme.iconTheme.color
                                        ?.withOpacity(0.7) ??
                                    const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Text(
                          'من خلال التسجيل، فإنك توافق على شروط الخدمة وسياسة الخصوصية.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveAccount,
                          child: _isSaving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'تسجيل',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          // الألوان من ElevatedButtonTheme في AppTheme
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'هل أنت مسؤول؟',
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/admin-login');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(
                              'تسجيل الدخول كمسؤول',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
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