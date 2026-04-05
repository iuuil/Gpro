// ignore_for_file: dead_code, deprecated_member_use, empty_statements, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/account_screen.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
  });

  static const Color brandBlue = Color(0xFF4A76B8);
  static const Color brandLightBlue = Color(0xFFA3BCE0);
  static const Color bgGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر مع سهم رجوع
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
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
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تفاصيل الشكوى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
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
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(complaintId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء جلب بيانات الشكوى: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: Text(
                          'لم يتم العثور على هذه الشكوى.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      );
                    }

                    final data =
                        snapshot.data!.data() as Map<String, dynamic>? ?? {};

                    final title =
                        (data['title'] as String?)?.trim().isNotEmpty == true
                            ? data['title'] as String
                            : (data['description'] as String? ??
                                    'بدون عنوان')
                                .toString();
                    final description =
                        (data['description'] as String? ?? '').toString();
                    final status =
                        (data['status'] as String? ?? 'pending').toString();
                    final ministry =
                        (data['ministry'] as String? ?? 'غير محددة')
                            .toString();
                    final createdAt = (data['createdAt'] as Timestamp?)
                        ?.toDate()
                        .toString()
                        .split(' ')
                        .first;
                    final contactName =
                        (data['contactName'] as String? ?? '').toString();
                    final contactPhone =
                        (data['contactPhone'] as String? ?? '').toString();

                    final statusLabel = _statusLabelFromStatus(status);
                    final statusColor = _statusColorFromStatus(status);

                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // نظرة عامة على الشكوى
                          _buildComplaintOverviewSection(
                            title: title,
                            description: description,
                            statusLabel: statusLabel,
                            statusColor: statusColor,
                            ministry: ministry,
                            createdAt: createdAt,
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 16),

                          // معلومات صاحب الشكوى
                          _buildComplainantInfoSection(
                            context: context,
                            contactName: contactName,
                            contactPhone: contactPhone,
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 16),

                          // ملاحظة (نص ثابت فقط)
                          _buildInternalCommentsSection(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // == Sections ==

  Widget _buildComplaintOverviewSection({
    required String title,
    required String description,
    required String statusLabel,
    required Color statusColor,
    required String ministry,
    required String? createdAt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان + الحالة
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (ministry.isNotEmpty)
          Row(
            children: [
              const Icon(
                Icons.account_balance,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                'الجهة: $ministry',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        if (createdAt != null)
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Text(
                'تاريخ الإرسال: $createdAt',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        const Text(
          'وصف المشكلة',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            description.isNotEmpty
                ? description
                : 'لا يوجد وصف تفصيلي لهذه الشكوى.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'المرفقات',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'لا توجد مرفقات مضافة لهذه الشكوى.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildComplainantInfoSection({
    required BuildContext context,
    required String contactName,
    required String contactPhone,
  }) {
    final hasName = contactName.trim().isNotEmpty;
    final hasPhone = contactPhone.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات صاحب الشكوى',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: brandLightBlue,
              child: Icon(
                Icons.person,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? contactName : 'مستخدم التطبيق',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                if (hasPhone)
                  Row(
                    children: [
                      const Icon(Icons.phone_in_talk_outlined,
                          size: 12, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        contactPhone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'لم يقم المستخدم بإدخال رقم هاتف.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'عرض الملف الشخصي',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInternalCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'ملاحظة',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 8),
        _InternalCommentCard(
          author: 'النظام',
          datetime: '—',
          text: 'تم تسجيل الشكوى في النظام، بانتظار اتخاذ إجراء من الجهة المختصة.',
        ),
      ],
    );
  }

  // == Helpers للحالة ==

  String _statusLabelFromStatus(String status) {
    switch (status) {
      case 'resolved':
        return 'تم حلها';
      case 'rejected':
        return 'مرفوضة';
      case 'pending':
      default:
        return 'قيد المراجعة';
    }
  }

  Color _statusColorFromStatus(String status) {
    switch (status) {
      case 'resolved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFB91C1C);
      case 'pending':
      default:
        return const Color(0xFF0369A1);
    }
  }
}

// == Widgets مساعدة ==

class _InternalCommentCard extends StatelessWidget {
  final String author;
  final String datetime;
  final String text;

  const _InternalCommentCard({
    required this.author,
    required this.datetime,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(right: 10, left: 8, top: 6, bottom: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: ComplaintDetailsScreen.brandBlue, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                datetime,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}