import 'package:flutter/material.dart';

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

  // نوع الشكوى السابق (لو حاب تستخدمه داخلياً)
  // String _selectedType = 'administrative';

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // معلومات التواصل
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
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

                          // الجهة المعنية (قائمة منسدلة)
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
                                  color: Colors.black.withValues(alpha: 0.03),
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
                                    // إعادة تعيين التصنيف عند تغيير الوزارة
                                    _selectedComplaintType = null;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // تصنيف الشكوى (قائمة منسدلة)
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
                                items: _currentComplaintTypes(_selectedMinistry)
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

                          // عنوان الشكوى
                          const Text(
                            'عنوان الشكوى',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                hintText: 'مثال: نقص في الكتب المدرسية',
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // وصف تفصيلي
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

                          const SizedBox(height: 12),

                          // المرفقات
                          const Text(
                            'المرفقات (صور أو مستندات)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.image_outlined,
                                    color: Color(0xFF9CA3AF)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'screenshot_issue.jpg',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.delete_outline,
                                    color: Colors.red, size: 22),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('إضافة مرفق غير متاح حالياً'),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                style: BorderStyle.solid,
                              ),
                              backgroundColor:
                                  const Color(0xFFF3F4F6),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                            ),
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text(
                              'إضافة مرفق جديد',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // الموقع الجغرافي
                          const Text(
                            'الموقع الجغرافي (اختياري)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton(
                            onPressed: () {
                              
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: Color(0xFF6B7280)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'تحديد الموقع على الخريطة',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_left,
                                    color: Color(0xFF9CA3AF), size: 20),
                              ],
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
                            onPressed: () {
                              
                              // _selectedMinistry
                              // _selectedComplaintType
                              // _selectedType (الكود الداخلي)
                              // _titleController.text
                              // _descController.text
                              // _nameController.text
                              // _phoneController.text
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text(
                              'إرسال الشكوى',
                              style: TextStyle(
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

  // ignore: unused_element
  String _mapTypeToCode(String? type) {
    switch (type) {
      case 'مشكلة إدارية':
        return 'administrative';
      case 'المناهج الدراسية':
        return 'curriculum';
      case 'أبنية مدرسية / خدمات':
        return 'infrastructure';
      default:
        return 'other';
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
