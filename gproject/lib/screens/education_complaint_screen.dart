// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EducationComplaintScreen extends StatefulWidget {
  const EducationComplaintScreen({super.key});

  @override
  State<EducationComplaintScreen> createState() =>
      _EducationComplaintScreenState();
}

class _EducationComplaintScreenState extends State<EducationComplaintScreen> {
  // الجهة المعنية (الوزارة)
  final List<String> _ministries = [
    'وزارة التربية',
    'وزارة الصحة',
    'وزارة الكهرباء',
    'وزارة الداخلية',
    'وزارة التعليم العالي',
    'وزارة البلديات',
    'وزارة الموارد المائية',
    'أخرى',
  ];
  String? _selectedMinistry;

  // تصنيفات الشكوى لكل وزارة
  final Map<String, List<String>> _complaintTypesByMinistry = {
    'وزارة التربية': [
      'مشكلة إدارية',
      'المناهج الدراسية',
      'أبنية مدرسية / خدمات',
      'الكوادر التدريسية',
      'أخرى',
    ],
    'وزارة الصحة': [
      'سوء معاملة',
      'نقص أدوية',
      'نظافة المستشفى',
      'تأخير المواعيد',
      'أخرى',
    ],
    'وزارة الكهرباء': [
      'انقطاع التيار',
      'ضعف الفولتية',
      'توصيل جديد',
      'فاتورة غير صحيحة',
      'أخرى',
    ],
    'وزارة الداخلية': [
      'مخالفة مرورية',
      'سوء معاملة',
      'تأخير في الإنجاز',
      'البلاغات الأمنية',
      'أخرى',
    ],
    'وزارة التعليم العالي': [
      'قبول جامعي',
      'سكن طلابي',
      'الرسوم الدراسية',
      'مناهج / أساتذة',
      'أخرى',
    ],
    'وزارة البلديات': [
      'النفايات والخدمات',
      'المجاري',
      'الطرق والممرات',
      'الإنارة',
      'أخرى',
    ],
    'وزارة الموارد المائية': [
      'انقطاع المياه',
      'تلوث المياه',
      'كسر / تسريب أنابيب',
      'أخرى',
    ],
    'أخرى': [
      'مشكلة عامة',
      'خدمة غير مكتملة',
      'سلوك موظف',
      'أخرى',
    ],
  };

  String? _selectedComplaintType;

  // فقط الوصف
  final _descController = TextEditingController();

  // معلومات التواصل
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ترجّع قائمة التصنيفات بحسب الوزارة المختارة
  List<String> _currentComplaintTypes(String? ministry) {
    if (ministry == null) return [];
    return _complaintTypesByMinistry[ministry] ?? [];
  }

  Future<void> _submitComplaint() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى تسجيل الدخول أولاً قبل إرسال الشكوى')),
      );
      return;
    }

    if (_selectedMinistry == null ||
        _selectedComplaintType == null ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('يرجى اختيار الجهة والتصنيف وكتابة وصف الشكوى')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('complaints').add({
        'userId': user.uid,
        'ministry': _selectedMinistry,
        'complaintType': _selectedComplaintType,
        'title': null,
        'description': _descController.text.trim(),
        'contactName': _nameController.text.trim(),
        'contactPhone': _phoneController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'attachments': [], // باقي الحقل فاضي بس بدون رفع
      });

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
      );

      setState(() {
        _selectedMinistry = null;
        _selectedComplaintType = null;
        _descController.clear();
        _nameController.clear();
        _phoneController.clear();
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الشكوى: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF137FEC);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F8),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تقديم شكوى جديدة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 90,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // الجهة المعنية
                          const Text(
                            'الجهة المعنية',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedMinistry,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF6B7280),
                                ),
                                hint: const Row(
                                  children: [
                                    Icon(Icons.account_balance,
                                        color: primaryColor, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'اختر الجهة المعنية',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                items: _ministries
                                    .map(
                                      (m) => DropdownMenuItem<String>(
                                        value: m,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.account_balance,
                                                color: primaryColor,
                                                size: 20),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                m,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMinistry = value;
                                    _selectedComplaintType = null;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // تصنيف الشكوى
                          const Text(
                            'تصنيف الشكوى',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedComplaintType,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF6B7280),
                                ),
                                hint: Row(
                                  children: [
                                    const Icon(Icons.category_outlined,
                                        color: Color(0xFF6B7280), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedMinistry == null
                                          ? 'اختر الجهة أولاً'
                                          : 'اختر تصنيف الشكوى',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                items:
                                    _currentComplaintTypes(_selectedMinistry)
                                        .map(
                                          (t) => DropdownMenuItem<String>(
                                            value: t,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _iconForComplaintType(t),
                                                  color:
                                                      const Color(0xFF4B5563),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    t,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Color(0xFF111827),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: _selectedMinistry == null
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedComplaintType = value;
                                        });
                                      },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // تفاصيل الشكوى
                          const Text(
                            'تفاصيل الشكوى',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            'وصف تفصيلي',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: TextField(
                              controller: _descController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                hintText:
                                    'يرجى ذكر كافة التفاصيل المتعلقة بالمشكلة...',
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // معلومات التواصل
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'معلومات التواصل الخاصة بك',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _editableField(
                                        label: 'الاسم الكامل',
                                        icon: Icons.person_outline,
                                        controller: _nameController,
                                        keyboardType: TextInputType.name,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _editableField(
                                        label: 'رقم الهاتف',
                                        icon: Icons.phone_outlined,
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // زر إرسال الشكوى ثابت أسفل الشاشة
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F7F8),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isSubmitting ? null : _submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send, size: 18),
                            label: Text(
                              _isSubmitting
                                  ? 'جاري الإرسال...'
                                  : 'إرسال الشكوى',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForComplaintType(String? type) {
    switch (type) {
      case 'مشكلة إدارية':
        return Icons.description;
      case 'المناهج الدراسية':
        return Icons.menu_book;
      case 'أبنية مدرسية / خدمات':
        return Icons.school;
      case 'خدمات بلدية':
        return Icons.place_outlined;
      case 'خدمات صحية':
        return Icons.local_hospital_outlined;
      case 'خدمات كهرباء':
        return Icons.bolt_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget _editableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }
}