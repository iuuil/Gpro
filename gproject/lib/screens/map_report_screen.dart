// ignore_for_file: duplicate_ignore, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapReportScreen extends StatefulWidget {
  const MapReportScreen({super.key});

  @override
  State<MapReportScreen> createState() => _MapReportScreenState();
}

class _MapReportScreenState extends State<MapReportScreen> {
  static const Color primary = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  final Completer<GoogleMapController> _mapController = Completer();

  // نقطة مبدئية (بغداد)
  static const LatLng _initialPosition = LatLng(33.3152, 44.3661);

  LatLng _cameraTarget = _initialPosition;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  // نوع البلاغ السريع
  String _selectedCategory = 'حادث مروري';
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _categories = const [
    'حادث مروري',
    'صيانة شارع',
    'تجمع مياه',
    'نفايات متراكمة',
    'انقطاع إنارة شارع',
    'ازدحام شديد',
  ];

  // معلومات التواصل
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // المرفقات (صور)
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedImages = [];

  @override
  void dispose() {
    _detailsController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // حوار موحّد لعرض الرسائل للمستخدم
  Future<void> _showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.info_outline,
                color: isError ? const Color(0xFFDC2626) : primary,
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
                      isError ? const Color(0xFFDC2626) : primary,
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

  // اختيار عدة صور
  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) return;

      setState(() {
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
      await _showMessageDialog(
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

    const bucketName = 'complaints';

    for (int i = 0; i < _pickedImages.length; i++) {
      try {
        final XFile img = _pickedImages[i];
        final File file = File(img.path);

        final String path =
            'complaint_attachments/$complaintId/img_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await client.storage.from(bucketName).upload(
              path,
              file,
            ); // [web:539]

        final String publicUrl =
            client.storage.from(bucketName).getPublicUrl(path); // [web:564]

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

  // حفظ البلاغ في Firestore
  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final Map<String, dynamic> data = {
        'lat': _cameraTarget.latitude,
        'lng': _cameraTarget.longitude,
        'location': {
          'lat': _cameraTarget.latitude,
          'lng': _cameraTarget.longitude,
        },
        'category': _selectedCategory, // نوع البلاغ السريع
        'quickType': _selectedCategory,
        'title': 'بلاغ سريع - $_selectedCategory',
        'description': _detailsController.text.trim(),
        'status': 'pending',
        'source': 'map',
        'ministry': 'بلاغ سريع من الموقع',
        'createdAt': FieldValue.serverTimestamp(),
        'contactName': _nameController.text.trim(),
        'contactPhone': _phoneController.text.trim(),
        'attachments': [],
      };

      if (user != null) {
        data['userId'] = user.uid;
        data['citizenName'] = user.displayName ?? '';
        data['citizenEmail'] = user.email ?? '';
      }

      final docRef =
          await FirebaseFirestore.instance.collection('complaints').add(data);

      // رفع المرفقات إن وُجدت
      List<String> attachmentUrls = [];
      if (_pickedImages.isNotEmpty) {
        attachmentUrls = await _uploadImages(docRef.id);
        if (attachmentUrls.isNotEmpty) {
          await docRef.update({'attachments': attachmentUrls});
        }
      }

      if (!mounted) return;

      await _showMessageDialog(
        title: 'تم إرسال البلاغ',
        message: attachmentUrls.isEmpty
            ? 'تم إرسال البلاغ بنجاح وسيتم عرضه للجهة المختصة مع موقعه على الخريطة.'
            : 'تم إرسال البلاغ مع ${attachmentUrls.length} مرفق/مرفقات وسيتم عرضه للجهة المختصة مع موقعه على الخريطة.',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      await _showMessageDialog(
        title: 'خطأ في إرسال البلاغ',
        message: 'فشل في إرسال البلاغ:\n$e',
        isError: true,
      );
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
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
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تحديد الموقع',
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

              // الخريطة
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _initialPosition,
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        if (!_mapController.isCompleted) {
                          _mapController.complete(controller);
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onCameraMove: (position) {
                        _cameraTarget = position.target;
                      },
                    ),

                    // حقل البحث (UI فقط)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.search,
                              color: Color(0xFF9CA3AF),
                            ),
                            hintText: 'ابحث عن عنوان أو معلم...',
                          ),
                        ),
                      ),
                    ),

                    // أزرار التكبير + موقعي
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final controller =
                                        await _mapController.future;
                                    controller.animateCamera(
                                      CameraUpdate.zoomIn(),
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () async {
                                    final controller =
                                        await _mapController.future;
                                    controller.animateCamera(
                                      CameraUpdate.zoomOut(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: _isLoadingLocation
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation(primary),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location,
                                      color: primary,
                                    ),
                              onPressed: _isLoadingLocation
                                  ? null
                                  : () async {
                                      await _goToUserLocation();
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pin في الوسط
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 40,
                            color: primary,
                          ),
                          Container(
                            width: 6,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // الجزء السفلي
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),

                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'الموقع المحدد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // كرت الإحداثيات
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.explore_outlined,
                                  size: 20,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'الإحداثيات',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        'Lat: ${_cameraTarget.latitude.toStringAsFixed(5)}   '
                                        'Lon: ${_cameraTarget.longitude.toStringAsFixed(5)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // نوع البلاغ السريع
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'نوع البلاغ السريع',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.expand_more,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    items: _categories.map((c) {
                                      return DropdownMenuItem<String>(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val == null) return;
                                      setState(() {
                                        _selectedCategory = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // تفاصيل البلاغ
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تفاصيل إضافية',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _detailsController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText:
                                      'اكتب تفاصيل أو ملاحظات تساعد الجهة المختصة (اختياري)...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // المرفقات (صور)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.symmetric(
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
                                                ? 'يمكنك إرفاق حتى 5 صور لدعم البلاغ (اختياري).'
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
                                                      BorderRadius.circular(
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
                                                        _pickedImages
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          BoxDecoration(
                                                        color:
                                                            Colors.black54,
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // معلومات التواصل
                        Align(
                          alignment: Alignment.centerRight,
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

                        const SizedBox(height: 20),

                        // زر تأكيد الموقع وتقديم البلاغ
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'تأكيد الموقع وتقديم البلاغ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
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

  // دالة تجيب موقع المستخدم وتحرك الكاميرا
  Future<void> _goToUserLocation() async {
    try {
      if (!mounted) return;
      setState(() => _isLoadingLocation = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() => _isLoadingLocation = false);
          await _showMessageDialog(
            title: 'صلاحيات الموقع',
            message:
                'لم يتم منح صلاحية الوصول إلى الموقع. يرجى تفعيلها من الإعدادات لاستخدام هذه الميزة.',
            isError: true,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        await _showMessageDialog(
          title: 'صلاحيات الموقع',
          message:
              'تم رفض صلاحية الموقع نهائياً. الرجاء تفعيلها يدوياً من إعدادات النظام.',
          isError: true,
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng userLatLng =
          LatLng(position.latitude, position.longitude);
      _cameraTarget = userLatLng;

      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 16),
        ),
      );

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      await _showMessageDialog(
        title: 'خطأ في الموقع',
        message: 'تعذر الحصول على موقعك الحالي:\n$e',
        isError: true,
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isLoadingLocation = false);
  }
}