// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _loginAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;

      if (user == null) {
        throw Exception('تعذر تسجيل الدخول، يرجى المحاولة مرة أخرى.');
      }

      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      if (!adminDoc.exists) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'هذا الحساب ليس حساب مسؤول، لا يمكنك الدخول من هنا.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل دخول المسؤول بنجاح')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-dashboard',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'فشل تسجيل الدخول، تحقق من البيانات.';
      if (e.code == 'user-not-found') {
        message = 'لا يوجد حساب بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صحيحة.';
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // شريط علوي مع سهم رجوع
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: theme.appBarTheme.foregroundColor ??
                            theme.iconTheme.color ??
                            const Color(0xFF020617),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'تسجيل دخول المسؤول',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // الأيقونة + اسم النظام
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.fingerprint,
                              size: 36,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'صوت المواطن',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Text(
                            'مرحباً، مسؤول النظام',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'يرجى إدخال بياناتك للوصول إلى لوحة إدارة الشكاوى.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: theme.hintColor,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // البريد الإلكتروني الرسمي
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'البريد الإلكتروني الرسمي',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.email_outlined,
                                  color: theme.iconTheme.color
                                          ?.withOpacity(0.7) ??
                                      const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'admin@ministry.gov',
                                      hintTextDirection:
                                          TextDirection.ltr,
                                      hintStyle: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // كلمة المرور
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'كلمة المرور',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.lock_outline,
                                  color: theme.iconTheme.color
                                          ?.withOpacity(0.7) ??
                                      const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'أدخل كلمة المرور الخاصة بك',
                                      hintStyle: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
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
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // زر تسجيل دخول آمن
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _loginAdmin,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme
                                            .colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Text(
                                      'تسجيل دخول آمن',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              // بقية الـ style يأتي من ElevatedButtonTheme في الثيم العام
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: () {
                              
                            },
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: theme.hintColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // إنشاء حساب مسؤول جديد
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'لا تمتلك حساب مسؤول؟',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: theme.hintColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/admin-register',
                                  );
                                },
                                child: Text(
                                  'إنشاء حساب جديد',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
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