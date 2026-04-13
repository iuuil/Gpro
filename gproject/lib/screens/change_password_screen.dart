// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static const Color primary = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  bool _currentObscured = true;
  bool _newObscured = true;
  bool _confirmObscured = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _errorText = 'لا يوجد مستخدم مسجّل حالياً.';
      });
      return;
    }

    final currentPassword = _currentController.text.trim();
    final newPassword = _newController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorText = 'الرجاء ملء جميع الحقول.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorText = 'كلمة المرور الجديدة وتأكيدها غير متطابقين.';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorText = 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح.'),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'حدث خطأ أثناء تغيير كلمة المرور.';
      if (e.code == 'wrong-password') {
        msg = 'كلمة المرور الحالية غير صحيحة , يرجى المحاولة مرة اخرى';
      } else if (e.code == 'weak-password') {
        msg = 'كلمة المرور الجديدة ضعيفة جداً.';
      } else if (e.code == 'requires-recent-login') {
        msg =
            'لأسباب أمنية، الرجاء تسجيل الدخول من جديد ثم إعادة محاولة تغيير كلمة المرور.';
      }
      setState(() {
        _errorText = msg;
      });
    } catch (e) {
      setState(() {
        _errorText = 'خطأ غير متوقع: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscured,
    required VoidCallback onToggleVisibility,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                prefixIcon,
                size: 18,
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscured,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChangePasswordScreen.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // هيدر موحد
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تغيير كلمة المرور',
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

              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'لأمان حسابك، الرجاء إدخال كلمة المرور الحالية ثم تعيين كلمة مرور جديدة.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildPasswordField(
                          label: 'كلمة المرور الحالية',
                          hint: 'أدخل كلمة المرور الحالية',
                          controller: _currentController,
                          obscured: _currentObscured,
                          onToggleVisibility: () {
                            setState(() {
                              _currentObscured = !_currentObscured;
                            });
                          },
                          prefixIcon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          label: 'كلمة المرور الجديدة',
                          hint: 'أدخل كلمة المرور الجديدة',
                          controller: _newController,
                          obscured: _newObscured,
                          onToggleVisibility: () {
                            setState(() {
                              _newObscured = !_newObscured;
                            });
                          },
                          prefixIcon: Icons.lock_reset_outlined,
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          label: 'تأكيد كلمة المرور الجديدة',
                          hint: 'أعد إدخال كلمة المرور الجديدة',
                          controller: _confirmController,
                          obscured: _confirmObscured,
                          onToggleVisibility: () {
                            setState(() {
                              _confirmObscured = !_confirmObscured;
                            });
                          },
                          prefixIcon: Icons.verified_user_outlined,
                        ),

                        const SizedBox(height: 16),

                        if (_errorText != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),

              // زر ثابت أسفل الشاشة
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ChangePasswordScreen.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'حفظ كلمة المرور الجديدة',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
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