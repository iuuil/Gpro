// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final inputEmail = _emailOrUsernameController.text.trim();
    final inputPassword = _passwordController.text.trim();

    if (inputEmail.isEmpty || inputPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: inputEmail,
        password: inputPassword,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
      );

      Navigator.pushReplacementNamed(context, '/main-shell');
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      // ignore: avoid_print
      print('🔥 FirebaseAuthException (login) code: ${e.code}');

      String message = 'حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى';

      if (e.code == 'user-not-found') {
        message = 'لا يوجد حساب مسجل بهذا البريد';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صحيحة';
      } else if (e.code == 'user-disabled') {
        message = 'هذا الحساب معطّل، يرجى مراجعة الدعم';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ غير متوقع: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // AppBar مخصص مع سهم رجوع
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                          'تسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // الشعار
                          Container(
                            height: 80,
                            width: 80,
                            margin: const EdgeInsets.only(
                                bottom: 24, top: 16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(999),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.account_balance,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),

                          Text(
                            'بوابة شكاوى المواطنين',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'يرجى تسجيل الدخول للمتابعة',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // حقل البريد الإلكتروني
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'البريد الإلكتروني',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
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
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.dividerColor
                                    .withOpacity(0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.person_outline,
                                  color: theme.iconTheme.color
                                          ?.withOpacity(0.7) ??
                                      const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _emailOrUsernameController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'أدخل البريد الإلكتروني المسجل',
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

                          // حقل كلمة المرور
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'كلمة المرور',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
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
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.dividerColor
                                    .withOpacity(0.6),
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

                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                // لاحقاً: صفحة استعادة كلمة المرور
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: Text(
                                'هل نسيت كلمة المرور؟',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // زر تسجيل الدخول
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme
                                            .onPrimary,
                                      ),
                                    )
                                  : Text(
                                      'تسجيل الدخول',
                                      style: theme
                                          .textTheme.bodyLarge
                                          ?.copyWith(
                                        fontSize: 16,
                                        color: theme.colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                              // الألوان من ElevatedButtonTheme / colorScheme
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ليس لديك حساب
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                'ليس لديك حساب؟',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 13,
                                  color: theme.hintColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/signup');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: Text(
                                  'إنشاء حساب',
                                  style: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 13,
                                    color: theme
                                        .colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // تسجيل الدخول كمسؤول
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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