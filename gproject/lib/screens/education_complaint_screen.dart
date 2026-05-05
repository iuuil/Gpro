// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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
      EducationComplaintScreenState();
}

class EducationComplaintScreenState extends State<EducationComplaintScreen> {
  // ===== الوزارات بعد التعديل =====
  final List<String> ministries = [
    'وزارة التربية',
    'وزارة الصحة',
    'وزارة الداخلية',
    'وزارة الخارجية',
    'وزارة المالية',
    'وزارة النفط',
    'وزارة الدفاع',
  ];

  String? selectedMinistry;

  // أنواع الشكاوى لكل وزارة بعد التعديل
  final Map<String, List<String>> complaintTypesByMinistry = {
    'وزارة التربية': [
      'سوء إدارة في المدارس أو المديريات',
      'مشاكل في المناهج أو طريقة التدريس',
      'تقصير الكوادر التدريسية أو الإدارية',
      'مشاكل في الخدمات (النقل، النظافة، المرافق)',
      'مشاكل في الامتحانات أو الدرجات',
      'الفساد الإداري / المالي',
      'أخرى',
    ],
    'وزارة الصحة': [
      'سوء معاملة من الكوادر الصحية',
      'تقصير في تقديم الخدمات الطبية',
      'نقص الأدوية أو المستلزمات',
      'تأخير في المواعيد أو العمليات',
      'الفساد الإداري / المالي في المؤسسات الصحية',
      'مخالفات صحية أو بيئية',
      'أخرى',
    ],
    'وزارة الداخلية': [
      'سوء معاملة من المنتسبين أو الضباط',
      'تجاوزات على حقوق المواطنين',
      'تأخير أو امتناع عن تنفيذ الواجبات',
      'استغلال السلطة أو النفوذ',
      'الفساد الإداري / المالي',
      'مخالفات في مراكز الشرطة أو المرور',
      'أخرى',
    ],
    'وزارة الخارجية': [
      'سوء معاملة في السفارات أو القنصليات',
      'تأخير في إصدار الجوازات أو التأشيرات',
      'عدم الاستجابة للشكاوى أو الاستفسارات',
      'مشاكل في المعاملات القنصلية',
      'إهمال شؤون الجالية في الخارج',
      'أخرى',
    ],
    'وزارة المالية': [
      'تأخير في صرف الرواتب أو المستحقات',
      'مشاكل في الضرائب أو الرسوم',
      'الفساد الإداري / المالي',
      'سوء معاملة في الدوائر المالية',
      'أخطاء في البيانات أو الاستقطاعات',
      'أخرى',
    ],
    'وزارة النفط': [
      'تلوث بيئي ناتج عن النشاط النفطي',
      'تجاوزات في توزيع المشتقات النفطية',
      'الفساد الإداري / المالي',
      'مشاكل تتعلق بمحطات الوقود',
      'تقصير في الاستجابة للأعطال والانسكابات',
      'أخرى',
    ],
    'وزارة الدفاع': [
      'سوء معاملة من المنتسبين',
      'تجاوزات على المواطنين أو الممتلكات',
      'استغلال النفوذ أو الصلاحيات',
      'الفساد الإداري / المالي',
      'مخالفات في السيطرات أو نقاط التفتيش',
      'أخرى',
    ],
  };

  String? selectedComplaintType;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isSubmitting = false;

  final ImagePicker picker = ImagePicker();
  final List<XFile> pickedImages = [];

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  List<String> get currentComplaintTypes {
    final String? ministry = selectedMinistry;
    if (ministry == null) return [];
    return complaintTypesByMinistry[ministry] ?? [];
  }

  Future<void> showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) async {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
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
                    style: theme.textTheme.bodyLarge?.copyWith(
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.5,
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> loadUserInfo(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = userDoc.data() ?? {};
    final authUser = FirebaseAuth.instance.currentUser;

    final fullName = data['fullName'] as String? ??
        authUser?.displayName ??
        authUser?.email?.split('@').first ??
        '';
    final email = data['email'] as String? ?? authUser?.email ?? '';
    final phone = data['phone'] as String? ?? '';

    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'uid': uid,
    };
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) return;

      setState(() {
        const maxImages = 5;
        final combined = [...pickedImages, ...images];
        if (combined.length <= maxImages) {
          pickedImages
            ..clear()
            ..addAll(combined);
        } else {
          pickedImages
            ..clear()
            ..addAll(combined.take(maxImages));
          showMessageDialog(
            title: 'تنبيه',
            message: 'تم اختيار 5 صور كحد أقصى.',
          );
        }
      });
    } catch (e) {
      await showMessageDialog(
        title: 'خطأ',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<List<String>> uploadImages(String complaintId) async {
    final List<String> downloadUrls = [];
    final client = Supabase.instance.client;
    const bucketName = 'complaints';

    for (int i = 0; i < pickedImages.length; i++) {
      try {
        final XFile img = pickedImages[i];
        final File file = File(img.path);
        final String path =
            'complaint_attachments/$complaintId/img_$i${DateTime.now().millisecondsSinceEpoch}.jpg';

        await client.storage.from(bucketName).upload(path, file);
        final String publicUrl =
            client.storage.from(bucketName).getPublicUrl(path);
        downloadUrls.add(publicUrl);
      } catch (e) {
        debugPrint('Upload error for image $i: $e');
        await showMessageDialog(
          title: 'خطأ في رفع الصورة',
          message: 'حدث خطأ أثناء رفع الصورة رقم ${i + 1}.',
          isError: true,
        );
      }
    }

    return downloadUrls;
  }

  Future<void> submitComplaint() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await showMessageDialog(
        title: 'غير مسجل',
        message: 'يجب تسجيل الدخول قبل تقديم الشكوى.',
        isError: true,
      );
      return;
    }

    if (selectedMinistry == null ||
        selectedComplaintType == null ||
        descController.text.trim().isEmpty) {
      await showMessageDialog(
        title: 'حقول ناقصة',
        message: 'يرجى اختيار الوزارة ونوع الشكوى وكتابة وصف للشكوى.',
        isError: true,
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final userInfo = await loadUserInfo(user.uid);

      final rawTitle = titleController.text.trim();
      final description = descController.text.trim();

      String finalTitle;
      if (rawTitle.isNotEmpty) {
        finalTitle = rawTitle;
      } else {
        finalTitle = description.length > 40
            ? '${description.substring(0, 40)}...'
            : description;
      }

      final docRef = await FirebaseFirestore.instance
          .collection('complaints')
          .add({
        'userId': user.uid,
        'ministry': selectedMinistry,
        'complaintType': selectedComplaintType,
        'title': finalTitle,
        'description': description,
        'contactName': nameController.text.trim(),
        'contactPhone': phoneController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'attachments': [],
        'source': 'educationcomplaintscreen',
        ...userInfo,
      });

      List<String> attachmentUrls = [];
      if (pickedImages.isNotEmpty) {
        attachmentUrls = await uploadImages(docRef.id);
        await docRef.update({'attachments': attachmentUrls});
      }

      setState(() {
        isSubmitting = false;
      });

      if (!mounted) return;

      await showMessageDialog(
        title: 'تم إرسال الشكوى',
        message: attachmentUrls.isEmpty
            ? 'تم إرسال الشكوى بنجاح.'
            : 'تم إرسال الشكوى بنجاح مع ${attachmentUrls.length} مرفق/مرفقات.',
      );

      setState(() {
        selectedMinistry = null;
        selectedComplaintType = null;
        titleController.clear();
        descController.clear();
        nameController.clear();
        phoneController.clear();
        pickedImages.clear();
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      await showMessageDialog(
        title: 'خطأ',
        message: e.toString(),
        isError: true,
      );
    }
  }

  IconData iconForComplaintType(String? type) {
    switch (type) {
      case 'مشاكل في المناهج أو طريقة التدريس':
      case 'تقصير الكوادر التدريسية أو الإدارية':
        return Icons.menu_book;
      case 'مشاكل في الخدمات (النقل، النظافة، المرافق)':
      case 'تقصير في تقديم الخدمات الطبية':
        return Icons.place_outlined;
      case 'الفساد الإداري / المالي':
        return Icons.warning_amber_rounded;
      case 'سوء معاملة من الكوادر الصحية':
      case 'سوء معاملة من المنتسبين أو الضباط':
        return Icons.report_gmailerrorred_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget editableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 18,
                color: theme.iconTheme.color?.withOpacity(0.7) ??
                    const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: theme.textTheme.bodyMedium,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: theme.appBarTheme.foregroundColor ??
                              const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'تقديم شكوى للوزارة',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.appBarTheme.foregroundColor ??
                              theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // المحتوى
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
                      child: Center(
                        child: Container(
                          constraints:
                              const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'عنوان الشكوى (اختياري)',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                  ),
                                ),
                                child: TextField(
                                  controller: titleController,
                                  maxLines: 1,
                                  style:
                                      theme.textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    hintText:
                                        'اكتب عنواناً موجزاً للشكوى (مثال: تأخير صرف الراتب)',
                                    hintStyle:
                                        theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // اختيار الوزارة
                              Text(
                                'الوزارة المعنية',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedMinistry,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons
                                          .keyboard_arrow_down_rounded,
                                      color: Color(0xFF6B7280),
                                    ),
                                    hint: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance,
                                          color: primaryColor,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'اختر الوزارة',
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: ministries
                                        .map(
                                          (m) =>
                                              DropdownMenuItem<String>(
                                            value: m,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .account_balance,
                                                  color: primaryColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                    width: 8),
                                                Flexible(
                                                  child: Text(
                                                    m,
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight
                                                              .w500,
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
                                        selectedMinistry = value;
                                        selectedComplaintType = null;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // نوع الشكوى
                              Text(
                                'نوع الشكوى',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedComplaintType,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons
                                          .keyboard_arrow_down_rounded,
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
                                          selectedMinistry == null
                                              ? 'اختر الوزارة أولاً'
                                              : 'اختر نوع الشكوى',
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: currentComplaintTypes
                                        .map(
                                          (t) =>
                                              DropdownMenuItem<String>(
                                            value: t,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  iconForComplaintType(
                                                      t),
                                                  color: const Color(
                                                      0xFF4B5563),
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                    width: 8),
                                                Flexible(
                                                  child: Text(
                                                    t,
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight
                                                              .w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: selectedMinistry ==
                                            null
                                        ? null
                                        : (value) {
                                            setState(() {
                                              selectedComplaintType =
                                                  value;
                                            });
                                          },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // وصف الشكوى
                              Text(
                                'تفاصيل الشكوى',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'يرجى كتابة تفاصيل واضحة عن الشكوى، مثل المكان والزمان وأي معلومات تساعد في المعالجة.',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                  ),
                                ),
                                child: TextField(
                                  controller: descController,
                                  maxLines: 5,
                                  style:
                                      theme.textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    hintText:
                                        'اكتب وصف الشكوى بالتفصيل...',
                                    hintStyle:
                                        theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // المرفقات
                              Text(
                                'المرفقات (اختياري)',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: pickImages,
                                          style: ElevatedButton
                                              .styleFrom(
                                            elevation: 0,
                                            backgroundColor: theme
                                                .colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.4),
                                            foregroundColor: theme
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                const Color(
                                                    0xFF0F172A),
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.attach_file,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'إضافة صور داعمة',
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            pickedImages.isEmpty
                                                ? 'يمكنك إضافة حتى 5 صور كدليل على الشكوى.'
                                                : 'تم اختيار ${pickedImages.length} / 5 صورة.',
                                            style: theme.textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (pickedImages.isNotEmpty)
                                      SizedBox(
                                        height: 80,
                                        child: ListView.separated(
                                          scrollDirection:
                                              Axis.horizontal,
                                          itemCount:
                                              pickedImages.length,
                                          separatorBuilder:
                                              (c, i) =>
                                                  const SizedBox(
                                                      width: 8),
                                          itemBuilder:
                                              (context, index) {
                                            final img =
                                                pickedImages[index];
                                            return Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              8),
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
                                                        pickedImages
                                                            .removeAt(
                                                                index);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors
                                                            .black54,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    12),
                                                      ),
                                                      padding:
                                                          const EdgeInsets
                                                              .all(2),
                                                      child:
                                                          const Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color: Colors
                                                            .white,
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
                                margin:
                                    const EdgeInsets.only(top: 8),
                                padding:
                                    const EdgeInsets.only(top: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معلومات التواصل (اختياري)',
                                      style: theme.textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: editableField(
                                            label: 'الاسم الكامل',
                                            icon: Icons
                                                .person_outline,
                                            controller:
                                                nameController,
                                            keyboardType:
                                                TextInputType.name,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: editableField(
                                            label: 'رقم الهاتف',
                                            icon: Icons
                                                .phone_outlined,
                                            controller:
                                                phoneController,
                                            keyboardType:
                                                TextInputType.phone,
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
                    ),

                    // زر الإرسال أسفل الشاشة
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.cardColor.withOpacity(0.96),
                          border: Border(
                            top: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                isSubmitting ? null : submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    size: 18,
                                  ),
                            label: Text(
                              isSubmitting
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
}