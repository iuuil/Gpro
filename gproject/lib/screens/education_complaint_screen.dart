// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EducationComplaintScreen extends StatefulWidget {
  const EducationComplaintScreen({super.key});

  @override
  State<EducationComplaintScreen> createState() =>
      _EducationComplaintScreenState();
}

class _EducationComplaintScreenState extends State<EducationComplaintScreen> {
  // الوزارات
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

  // الحقول النصية
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;

  // الصور المرفقة
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<String> _currentComplaintTypes(String? ministry) {
    if (ministry == null) return [];
    return _complaintTypesByMinistry[ministry] ?? [];
  }

  // حوار موحّد لعرض الرسائل للمستخدم
  Future<void> _showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) async {
    const primaryColor = Color(0xFF137FEC);

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // المستخدم لازم يضغط "حسنًا"
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.info_outline,
                color: isError ? const Color(0xFFDC2626) : primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isError ? const Color(0xFFDC2626) : primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'حسنًا',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // تحميل بيانات حساب المستخدم من Firestore (users/{uid})
  Future<Map<String, dynamic>> _loadUserInfo(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = userDoc.data() ?? {};
    final authUser = FirebaseAuth.instance.currentUser;

    // fallback إذا بعض البيانات فارغة
    final fullName = (data['fullName'] as String?) ??
        authUser?.displayName ??
        (authUser?.email?.split('@').first ?? '');
    final email = (data['email'] as String?) ?? authUser?.email ?? '';
    final phone = (data['phone'] as String?) ?? '';

    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'uid': uid,
    };
  }

  // اختيار عدة صور من المعرض
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80, // تقليل الحجم قليلاً
      );

      if (images.isEmpty) return;

      setState(() {
        // حد أعلى 5 صور
        const maxImages = 5;
        final combined = [..._pickedImages, ...images];
        if (combined.length <= maxImages) {
          _pickedImages
            ..clear()
            ..addAll(combined);
        } else {
          _pickedImages
            ..clear()
            ..addAll(combined.take(maxImages));
          _showMessageDialog(
            title: 'تنبيه',
            message: 'تم تحديد الحد الأقصى لعدد الصور (5 صور).',
          );
        }
      });
    } catch (e) {
      _showMessageDialog(
        title: 'خطأ في اختيار الصور',
        message: 'تعذر اختيار الصور: $e',
        isError: true,
      );
    }
  }

  // رفع الصور إلى Supabase Storage وإرجاع روابطها
  Future<List<String>> _uploadImages(String complaintId) async {
    final List<String> downloadUrls = [];
    final client = Supabase.instance.client;

    // اسم الـ bucket في Supabase
    const bucketName = 'complaints';

    for (int i = 0; i < _pickedImages.length; i++) {
      try {
        final XFile img = _pickedImages[i];
        final File file = File(img.path);

        final String path =
            'complaint_attachments/$complaintId/img_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // رفع الملف
        await client.storage.from(bucketName).upload(
              path,
              file,
            );

        // الحصول على رابط عام
        final String publicUrl =
            client.storage.from(bucketName).getPublicUrl(path);

        downloadUrls.add(publicUrl);
      } catch (e) {
        debugPrint('Upload error for image $i: $e');
        await _showMessageDialog(
          title: 'خطأ في رفع الصور',
          message: 'فشل رفع صورة رقم ${i + 1}:\n$e',
          isError: true,
        );
      }
    }

    return downloadUrls;
  }

  Future<void> _submitComplaint() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await _showMessageDialog(
        title: 'تسجيل الدخول مطلوب',
        message: 'يرجى تسجيل الدخول أولاً قبل إرسال الشكوى.',
        isError: true,
      );
      return;
    }

    if (_selectedMinistry == null ||
        _selectedComplaintType == null ||
        _descController.text.trim().isEmpty) {
      await _showMessageDialog(
        title: 'بيانات ناقصة',
        message: 'يرجى اختيار الجهة، تصنيف الشكوى، وكتابة وصف الشكوى.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // جلب معلومات المستخدم
      final userInfo = await _loadUserInfo(user.uid);

      final rawTitle = _titleController.text.trim();
      final description = _descController.text.trim();

      // لو العنوان فارغ، نأخذ من الوصف (مقتطع)
      String finalTitle;
      if (rawTitle.isNotEmpty) {
        finalTitle = rawTitle;
      } else {
        finalTitle = description.length > 40
            ? '${description.substring(0, 40)}...'
            : description;
      }

      // 1) إنشاء وثيقة الشكوى أولاً (بدون روابط الصور)
      final docRef =
          await FirebaseFirestore.instance.collection('complaints').add({
        'userId': user.uid,
        'ministry': _selectedMinistry,
        'complaintType': _selectedComplaintType,
        'title': finalTitle,
        'description': description,
        'contactName': _nameController.text.trim(),
        'contactPhone': _phoneController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'attachments': [], // سيتم التحديث لاحقاً
        'userInfo': userInfo,
      });

      // 2) رفع الصور (إن وجدت) وتحديث الوثيقة بالروابط
      List<String> attachmentUrls = [];
      if (_pickedImages.isNotEmpty) {
        attachmentUrls = await _uploadImages(docRef.id);
        await docRef.update({'attachments': attachmentUrls});
      }

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      await _showMessageDialog(
        title: 'تم إرسال الشكوى',
        message: attachmentUrls.isEmpty
            ? 'تم إرسال الشكوى بنجاح، سيتم متابعتها من الجهة المختصة.'
            : 'تم إرسال الشكوى مع ${attachmentUrls.length} مرفق/مرفقات، سيتم متابعتها من الجهة المختصة.',
      );

      setState(() {
        _selectedMinistry = null;
        _selectedComplaintType = null;
        _titleController.clear();
        _descController.clear();
        _nameController.clear();
        _phoneController.clear();
        _pickedImages.clear();
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      await _showMessageDialog(
        title: 'خطأ في الإرسال',
        message: 'حدث خطأ أثناء إرسال الشكوى:\n$e',
        isError: true,
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
              // هيدر
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        'تقديم شكوى جديدة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),

                            // عنوان الشكوى
                            const Text(
                              'عنوان الشكوى',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: TextField(
                                controller: _titleController,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  hintText:
                                      'اكتب عنوانًا مختصرًا للشكوى (مثال: تأخير في إنجاز معاملة)...',
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // الجهة المعنية
                            const Text(
                              'الجهة المعنية',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
                                  // ignore: deprecated_member_use
                                  color: primaryColor.withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.03),
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
                                      Icon(
                                        Icons.account_balance,
                                        color: primaryColor,
                                        size: 22,
                                      ),
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
                                              const Icon(
                                                Icons.account_balance,
                                                color: primaryColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  m,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500,
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
                                fontWeight: FontWeight.w700,
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
                                      const Icon(
                                        Icons.category_outlined,
                                        color: Color(0xFF6B7280),
                                        size: 20,
                                      ),
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
                                  items: _currentComplaintTypes(
                                          _selectedMinistry)
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
                                fontWeight: FontWeight.w700,
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

                            // صندوق إرفاق الصور
                            const Text(
                              'المرفقات (صور المشكلة)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _pickImages,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              const Color(0xFFF1F5F9),
                                          foregroundColor:
                                              const Color(0xFF0F172A),
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.attach_file,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'إرفاق صور',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _pickedImages.isEmpty
                                              ? 'يمكنك إرفاق حتى 5 صور لدعم الشكوى (اختياري).'
                                              : 'تم اختيار ${_pickedImages.length} صورة.',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_pickedImages.isNotEmpty)
                                    SizedBox(
                                      height: 80,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _pickedImages.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final img = _pickedImages[index];
                                          return Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(img.path),
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 2,
                                                left: 2,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _pickedImages
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration:
                                                        BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
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
                                  top: BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'معلومات التواصل الخاصة بك',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
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
                            top: BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
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