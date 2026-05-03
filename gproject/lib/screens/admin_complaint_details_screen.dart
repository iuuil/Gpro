// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminComplaintDetailsScreen extends StatelessWidget {
  final String complaintDocId;

  const AdminComplaintDetailsScreen({
    super.key,
    required this.complaintDocId,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B); // برتقالي
      case 'resolved':
        return const Color(0xFF16A34A); // أخضر
      case 'rejected':
        return const Color(0xFFDC2626); // أحمر
      case 'new':
      case 'neww':
        return const Color(0xFF2563EB); // أزرق
      default:
        return const Color(0xFF6B7280); // رمادي
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'resolved':
        return const Color(0xFFEFFDF3);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      case 'new':
      case 'neww':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'resolved':
        return 'تم الحل';
      case 'rejected':
        return 'مرفوضة';
      case 'new':
      case 'neww':
        return 'جديدة';
      default:
        return 'غير محدد';
    }
  }

  Future<void> _showAlert(
    BuildContext context, {
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'حسنًا',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(
    BuildContext context, {
    required String newStatus,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintDocId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await _showAlert(
        context,
        message: 'الشكوى غير موجودة.',
      );
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final oldStatus = (data['status'] ?? '').toString();
    final userId = (data['userId'] ?? '').toString();
    final title = (data['title'] ?? '').toString();

    if (oldStatus == newStatus) {
      await _showAlert(
        context,
        message:
            'الحالة الحالية للشكوى هي بالفعل: ${_statusLabel(newStatus)}',
      );
      return;
    }

    await docRef.update({'status': newStatus});

    if (userId.isNotEmpty && oldStatus.isNotEmpty) {
      String statusLabelLocal(String status) {
        switch (status) {
          case 'pending':
            return 'قيد المراجعة';
          case 'resolved':
            return 'تم الحل';
          case 'rejected':
            return 'مرفوضة';
          case 'new':
          case 'neww':
            return 'جديدة';
          default:
            return 'غير محدد';
        }
      }

      final notifTitle = 'تحديث حالة الشكوى';
      final notifBody =
          'تم تحديث حالة الشكوى "${title.isEmpty ? 'بدون عنوان' : title}" '
          'من ${statusLabelLocal(oldStatus)} إلى ${statusLabelLocal(newStatus)}.';

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': notifTitle,
        'body': notifBody,
        'type': 'complaint_status',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await _showAlert(
      context,
      message: 'تم تحديث حالة الشكوى إلى: ${_statusLabel(newStatus)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('complaints').doc(complaintDocId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Color(0xFF020617)),
          title: const Text(
            'تفاصيل الشكوى',
            style: TextStyle(
              color: Color(0xFF020617),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'لم يتم العثور على الشكوى.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              );
            }

            final data = snapshot.data!.data()!;
            final id = (data['id'] ?? '').toString();
            final title = (data['title'] ?? '').toString();
            final text = (data['text'] ?? '').toString();
            final citizen = (data['citizenName'] ?? '').toString();
            final ministry = (data['ministry'] ?? '').toString();
            final status = (data['status'] ?? '').toString();
            final location = (data['location'] ?? '').toString();
            final createdAt = data['createdAt'];
            String dateText = '';

            if (createdAt is Timestamp) {
              final dt = createdAt.toDate();
              dateText =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            } else {
              dateText = (data['date'] ?? '').toString();
            }

            final statusColor = _statusColor(status);
            final statusBg = _statusBg(status);
            final statusLabel = _statusLabel(status);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // كرت رئيسي لمعلومات الشكوى
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // العنوان + البادج
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$title - ID $id',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(999),
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
                                          const SizedBox(width: 6),
                                          if (ministry.isNotEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE0ECFF),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                ministry,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1D4ED8),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // المواطن
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    citizen.isEmpty ? 'غير معروف' : citizen,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // التاريخ
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateText.isEmpty
                                      ? 'تاريخ غير متوفر'
                                      : 'تاريخ التقديم: $dateText',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // الموقع (اختياري)
                            if (location.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // نص الشكوى
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'نص الشكوى',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              text.isEmpty
                                  ? 'لا يوجد نص مرفق لهذه الشكوى.'
                                  : text,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // أزرار تغيير الحالة
                      const Text(
                        'تحديث حالة الشكوى',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: status == 'pending'
                                  ? null
                                  : () => _updateStatus(
                                        context,
                                        newStatus: 'pending',
                                      ),
                              icon: const Icon(
                                Icons.schedule_outlined,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                              label: const Text(
                                'قيد المراجعة',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                side: const BorderSide(
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: status == 'resolved'
                                  ? null
                                  : () => _updateStatus(
                                        context,
                                        newStatus: 'resolved',
                                      ),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: Color(0xFF16A34A),
                              ),
                              label: const Text(
                                'تم الحل',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                side: const BorderSide(
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: status == 'rejected'
                              ? null
                              : () => _updateStatus(
                                    context,
                                    newStatus: 'rejected',
                                  ),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: Color(0xFFDC2626),
                          ),
                          label: const Text(
                            'رفض الشكوى',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}