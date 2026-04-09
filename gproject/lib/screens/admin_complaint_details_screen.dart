// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminComplaintDetailsScreen extends StatefulWidget {
  final String complaintDocId;

  const AdminComplaintDetailsScreen({
    super.key,
    required this.complaintDocId,
  });

  @override
  State<AdminComplaintDetailsScreen> createState() =>
      _AdminComplaintDetailsScreenState();
}

class _AdminComplaintDetailsScreenState
    extends State<AdminComplaintDetailsScreen> {
  bool _updating = false;

  Future<void> _updateStatus(String newStatus) async {
    try {
      setState(() => _updating = true);
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaintDocId)
          .update({'status': newStatus});
      setState(() => _updating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث حالة الشكوى بنجاح.'),
        ),
      );
    } catch (e) {
      setState(() => _updating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تحديث الحالة: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
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
                        'تفاصيل الشكوى (مسؤول)',
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
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(widget.complaintDocId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
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

                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    final title =
                        (data['title'] as String? ?? '').trim().isNotEmpty
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
                    final citizenName =
                        (data['citizenName'] as String? ?? '').toString();
                    final complaintNumber =
                        (data['id'] ?? '').toString();

                    final statusLabel = _statusLabelFromStatus(status);
                    final statusColor = _statusColorFromStatus(status);

                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // رقم الشكوى + المواطن
                          Row(
                            children: [
                              if (complaintNumber.isNotEmpty)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    'رقم الشكوى: $complaintNumber',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              if (citizenName.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    'المواطن: $citizenName',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // نظرة عامة
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
                            contactName: contactName.isNotEmpty
                                ? contactName
                                : citizenName,
                            contactPhone: contactPhone,
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 16),

                          // أزرار تغيير الحالة
                          const Text(
                            'إدارة حالة الشكوى',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusActionChip(
                                label: 'تعيين كقيد المراجعة',
                                color: const Color(0xFF0369A1),
                                selected: status == 'pending',
                                onTap: _updating
                                    ? null
                                    : () => _updateStatus('pending'),
                              ),
                              _StatusActionChip(
                                label: 'تعيين كمحلولة',
                                color: const Color(0xFF15803D),
                                selected: status == 'resolved',
                                onTap: _updating
                                    ? null
                                    : () => _updateStatus('resolved'),
                              ),
                              _StatusActionChip(
                                label: 'تعيين كمرفوضة',
                                color: const Color(0xFFB91C1C),
                                selected: status == 'rejected',
                                onTap: _updating
                                    ? null
                                    : () => _updateStatus('rejected'),
                              ),
                            ],
                          ),

                          if (_updating) ...[
                            const SizedBox(height: 12),
                            const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 16),

                          // ملاحظة ثابتة
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
                // ignore: deprecated_member_use
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
      ],
    );
  }

  Widget _buildComplainantInfoSection({
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
              backgroundColor: Color(0xFFA3BCE0),
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
      ],
    );
  }

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

class _StatusActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const _StatusActionChip({
    required this.label,
    required this.color,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : Colors.white;
    final border = selected ? color : const Color(0xFFE5E7EB);
    final textColor = selected ? Colors.white : color;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                author,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const Spacer(),
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
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}