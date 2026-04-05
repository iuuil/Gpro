// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _submitComplaint() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان ووصف الشكوى')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الشكوى: $e')),
      );
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
    const primaryColor = Color(0xFF137FEC);

    final hotline = _hotlineFor(widget.ministry);
    final website = _websiteFor(widget.ministry);
    final address = _addressFor(widget.ministry);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // AppBar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F7F8),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
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
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.ministry,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 90,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // بلوك معلومات الوزارة
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 72,
                                  width: 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: const Color(0xFFE5E7EB),
                                    image: widget.logoUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              widget.logoUrl!,
                                            ),
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
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.ministry,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'الموقع الرسمي: $website',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'الخط الساخن: $hotline',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.language,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        website,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
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
                                    const Icon(
                                      Icons.location_on,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'تقديم شكوى جديدة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // عنوان الشكوى
                          const Text(
                            'عنوان الشكوى',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: TextField(
                              controller: _titleController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 14,
                                ),
                                hintText: 'أدخل عنوان شكواك',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // وصف تفصيلي
                          const Text(
                            'وصف تفصيلي',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: TextField(
                              controller: _descriptionController,
                              textAlign: TextAlign.right,
                              maxLines: 5,
                              minLines: 4,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 14,
                                ),
                                hintText:
                                    'يرجى تقديم أكبر قدر ممكن من التفاصيل.',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // زر الإرسال
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFFF6F7F8).withOpacity(0.96),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _isSubmitting ? 'جاري الإرسال...' : 'إرسال الشكوى',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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