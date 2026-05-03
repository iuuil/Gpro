// ignore_for_file: deprecated_member_use, non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminComplaintDetailsScreen extends StatelessWidget {
  final String complaintDocId;

  const AdminComplaintDetailsScreen({
    super.key,
    required this.complaintDocId,
  });

  Color _statusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    switch (status) {
      case 'pending':
        return Colors.amber.shade700;
      case 'resolved':
        return Colors.green.shade700;
      case 'rejected':
        return theme.colorScheme.error;
      case 'new':
      case 'neww':
        return primary;
      default:
        return theme.hintColor;
    }
  }

  Color _statusBg(BuildContext context, String status) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    switch (status) {
      case 'pending':
        return Colors.amber.shade100;
      case 'resolved':
        return Colors.green.shade50;
      case 'rejected':
        return theme.colorScheme.errorContainer;
      case 'new':
      case 'neww':
        return primary.withOpacity(0.12);
      default:
        return theme.cardColor;
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
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
                    color: primary,
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

      await FirebaseFirestore.instance
          .collection('notifications')
          .add({
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final docRef = FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintDocId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ?? theme.cardColor,
          elevation: 0.5,
          iconTheme: theme.appBarTheme.iconTheme ??
              IconThemeData(color: theme.iconTheme.color),
          title: Text(
            'تفاصيل الشكوى',
            style: theme.textTheme.titleMedium?.copyWith(
              color:
                  theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body:
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            final theme = Theme.of(context);
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'لم يتم العثور على الشكوى.',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.hintColor,
                  ),
                ),
              );
            }

            final data = snapshot.data!.data()!;
            final id = (data['id'] ?? '').toString();
            final title = (data['title'] ?? '').toString();
            final text = (data['text'] ?? '').toString();
            final citizen =
                (data['citizenName'] ?? '').toString();
            final ministry =
                (data['ministry'] ?? '').toString();
            final status = (data['status'] ?? '').toString();
            final location =
                (data['location'] ?? '').toString();
            final createdAt = data['createdAt'];
            String dateText = '';

            if (createdAt is Timestamp) {
              final dt = createdAt.toDate();
              dateText =
                  '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            } else {
              dateText = (data['date'] ?? '').toString();
            }

            final statusColor =
                _statusColor(context, status);
            final statusBg =
                _statusBg(context, status);
            final statusLabel = _statusLabel(status);

            final cardColor = theme.cardColor;
            final borderColor = theme.dividerColor;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // كرت رئيسي لمعلومات الشكوى
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                          ),
                          boxShadow: [
                            if (theme.brightness ==
                                Brightness.light)
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 4,
                                offset:
                                    const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // العنوان + البادج
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        '$title - ID $id',
                                        style: theme
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                          color: theme
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  8,
                                              vertical:
                                                  3,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color:
                                                  statusBg,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          999),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    11,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color:
                                                    statusColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: 6),
                                          if (ministry
                                              .isNotEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                horizontal:
                                                    8,
                                                vertical:
                                                    3,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    primary.withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                ministry,
                                                style: TextStyle(
                                                  fontSize:
                                                      11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color:
                                                      primary,
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
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    citizen.isEmpty
                                        ? 'غير معروف'
                                        : citizen,
                                    style: theme
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      fontSize: 13,
                                      color: theme
                                          .hintColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // التاريخ
                            Row(
                              children: [
                                Icon(
                                  Icons
                                      .calendar_today_outlined,
                                  size: 16,
                                  color:
                                      theme.hintColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateText.isEmpty
                                      ? 'تاريخ غير متوفر'
                                      : 'تاريخ التقديم: $dateText',
                                  style: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 12,
                                    color: theme
                                        .hintColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // الموقع (اختياري)
                            if (location.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons
                                        .location_on_outlined,
                                    size: 18,
                                    color: theme
                                        .colorScheme
                                        .error,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: theme
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        fontSize: 12,
                                        color: theme
                                            .hintColor,
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
                          color: cardColor,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نص الشكوى',
                              style: theme
                                  .textTheme.titleSmall
                                  ?.copyWith(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w700,
                                color: theme
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              text.isEmpty
                                  ? 'لا يوجد نص مرفق لهذه الشكوى.'
                                  : text,
                              style: theme
                                  .textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 13,
                                color: theme
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // أزرار تغيير الحالة
                      Text(
                        'تحديث حالة الشكوى',
                        style: theme
                            .textTheme.titleSmall
                            ?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: status ==
                                      'pending'
                                  ? null
                                  : () =>
                                      _updateStatus(
                                    context,
                                    newStatus:
                                        'pending',
                                  ),
                              icon: Icon(
                                Icons
                                    .schedule_outlined,
                                size: 18,
                                color: Colors
                                    .amber.shade700,
                              ),
                              label: const Text(
                                'قيد المراجعة',
                                style: TextStyle(
                                    fontSize: 12),
                              ),
                              style:
                                  OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 10,
                                ),
                                side: BorderSide(
                                  color: Colors
                                      .amber.shade400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: status ==
                                      'resolved'
                                  ? null
                                  : () =>
                                      _updateStatus(
                                    context,
                                    newStatus:
                                        'resolved',
                                  ),
                              icon: Icon(
                                Icons
                                    .check_circle_outline,
                                size: 18,
                                color: Colors
                                    .green.shade700,
                              ),
                              label: const Text(
                                'تم الحل',
                                style: TextStyle(
                                    fontSize: 12),
                              ),
                              style:
                                  OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 10,
                                ),
                                side: BorderSide(
                                  color: Colors
                                      .green.shade600,
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
                          onPressed: status ==
                                  'rejected'
                              ? null
                              : () => _updateStatus(
                                    context,
                                    newStatus:
                                        'rejected',
                                  ),
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: theme
                                .colorScheme.error,
                          ),
                          label: const Text(
                            'رفض الشكوى',
                            style:
                                TextStyle(fontSize: 12),
                          ),
                          style:
                              OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            side: BorderSide(
                              color: theme
                                  .colorScheme.error,
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