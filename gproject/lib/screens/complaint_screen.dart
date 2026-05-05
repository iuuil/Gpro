// ignore_for_file: duplicate_ignore, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gproject/screens/main_shell_screen.dart';

class ComplaintScreen extends StatefulWidget {
  final String ministry;
  final IconData icon;
  final String? logoUrl;

  const ComplaintScreen({
    super.key,
    required this.ministry,
    required this.icon,
    this.logoUrl,
  });

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  String _hotlineFor(String ministry) {
    switch (ministry) {
      case 'وزارة الصحة':
        return '123';
      case 'وزارة التربية':
        return '104';
      case 'وزارة الداخلية':
        return '104';
      case 'وزارة الخارجية':
        return '0770 000 0000';
      case 'وزارة المالية':
        return '0780 000 0000';
      case 'وزارة النفط':
        return '0790 000 0000';
      case 'وزارة الدفاع':
        return '130';
      default:
        return '123';
    }
  }

  String _websiteFor(String ministry) {
    switch (ministry) {
      case 'وزارة الصحة':
        return 'moh.gov.iq';
      case 'وزارة التربية':
        return 'moedu.gov.iq';
      case 'وزارة الداخلية':
        return 'moi.gov.iq';
      case 'وزارة الخارجية':
        return 'mofa.gov.iq';
      case 'وزارة المالية':
        return 'mof.gov.iq';
      case 'وزارة النفط':
        return 'oil.gov.iq';
      case 'وزارة الدفاع':
        return 'mod.gov.iq';
      default:
        return 'gov.iq';
    }
  }

  String _addressFor(String ministry) {
    switch (ministry) {
      case 'وزارة الصحة':
        return 'مجمع مدينة الطب، باب المعظم، بغداد، العراق';
      case 'وزارة التربية':
        return 'شارع 52، بغداد، العراق';
      case 'وزارة الداخلية':
        return 'شارع فلسطين، بغداد، العراق';
      case 'وزارة الخارجية':
        return 'حي المنصور، بغداد، العراق';
      case 'وزارة المالية':
        return 'شارع الرشيد، بغداد، العراق';
      case 'وزارة النفط':
        return 'الكرادة داخل، بغداد، العراق';
      case 'وزارة الدفاع':
        return 'المنطقة الخضراء، بغداد، العراق';
      default:
        return 'بغداد، العراق';
    }
  }

  Future<void> _showAlert(String message) async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx).dialogTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: dialogTheme.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
            content: Text(
              message,
              style: dialogTheme.contentTextStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'حسنًا',
                  style: theme.textTheme.bodyMedium?.copyWith(
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

  Future<void> _submitComplaint() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      await _showAlert('يرجى إدخال عنوان ووصف الشكوى');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await _showAlert('يرجى تسجيل الدخول أولاً');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('complaints').add({
        'userId': user.uid,
        'ministry': widget.ministry,
        'complaintType': null,
        'title': title,
        'description': desc,
        'contactName': null,
        'contactPhone': null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'attachments': [],
        'source': 'ministries_screen',
      });

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      await _showAlert('تم إرسال الشكوى بنجاح');

      Navigator.of(context).pop();

      final shell = MainShellScreen.of(context);
      shell?.setTab(1);
    } catch (e) {
      setState(() => _isSubmitting = false);
      await _showAlert('حدث خطأ أثناء إرسال الشكوى: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final hotline = _hotlineFor(widget.ministry);
    final website = _websiteFor(widget.ministry);
    final address = _addressFor(widget.ministry);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // هيدر مع رجوع لصفحة الوزارات
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.appBarTheme.backgroundColor ??
                          theme.cardColor,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.12)
                              : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      boxShadow: const [
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
                              Navigator.of(context).pop();
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: theme.appBarTheme.foregroundColor ??
                                  theme.iconTheme.color ??
                                  const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.ministry,
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
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 90,
                      ),
                      child: Container(
                        constraints:
                            const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // بلوك معلومات الوزارة
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 72,
                                    width: 72,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                              16),
                                      color: primaryColor
                                          .withOpacity(0.08),
                                      image: widget.logoUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  widget.logoUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: widget.logoUrl == null
                                        ? Icon(
                                            widget.icon,
                                            color: primaryColor,
                                            size: 36,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          widget.ministry,
                                          style: theme.textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                            fontSize: 20,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'الموقع الرسمي: $website',
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // معلومات الاتصال
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'الخط الساخن: $hotline',
                                          style: theme.textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          website,
                                          style: theme.textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          address,
                                          style: theme.textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'تقديم شكوى جديدة',
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'عنوان الشكوى',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor,
                                ),
                              ),
                              child: TextField(
                                controller: _titleController,
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                  hintText: 'أدخل عنوان شكواك',
                                  hintStyle: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Text(
                              'وصف تفصيلي',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor,
                                ),
                              ),
                              child: TextField(
                                controller: _descriptionController,
                                textAlign: TextAlign.right,
                                maxLines: 5,
                                minLines: 4,
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                  hintText:
                                      'يرجى تقديم أكبر قدر ممكن من التفاصيل.',
                                  hintStyle: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // زر الإرسال أسفل
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.96),
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor:
                            theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _isSubmitting
                            ? 'جاري الإرسال...'
                            : 'إرسال الشكوى',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimary,
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