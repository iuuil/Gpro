// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  // نتركها لو احتجتها بس ما نستخدمها مباشرة للألوان
  // ignore: unused_field
  static const Color primary = Color(0xFF137FEC);

  final Map<String, String> _lastKnownStatus = {}; // complaintId -> status

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('Current UID (MyComplaintsScreen): $uid');
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

  Color _statusColor(ThemeData theme, String status) {
    // ألوان الحالات تبقى قريبة من اللي كنت تستخدمها
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'new':
      case 'neww':
        return theme.colorScheme.primary;
      default:
        return theme.hintColor;
    }
  }

  Color _statusBg(ThemeData theme, String status) {
    final isDark = theme.brightness == Brightness.dark;
    switch (status) {
      case 'pending':
        return isDark
            ? const Color(0xFF4B3A13)
            : const Color(0xFFFEF3C7);
      case 'resolved':
        return isDark
            ? const Color(0xFF12291A)
            : const Color(0xFFEFFDF3);
      case 'rejected':
        return isDark
            ? const Color(0xFF3C1212)
            : const Color(0xFFFEE2E2);
      case 'new':
      case 'neww':
        return isDark
            ? const Color(0xFF1D2740)
            : const Color(0xFFDBEAFE);
      default:
        return isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.25)
            : const Color(0xFFF3F4F6);
    }
  }

  Future<void> _showStatusChangedDialog({
    required String complaintTitle,
    required String oldStatus,
    required String newStatus,
  }) async {
    final theme = Theme.of(context);
    final oldLabel = _statusLabel(oldStatus);
    final newLabel = _statusLabel(newStatus);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx).dialogTheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: dialogTheme.shape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
            title: Text(
              'تحديث حالة الشكوى',
              style: dialogTheme.titleTextStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            content: Text(
              'تم تحديث حالة الشكوى "$complaintTitle" من $oldLabel إلى $newLabel.',
              style: dialogTheme.contentTextStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
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
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _complaintsStream() {
    final user = _currentUser;
    if (user == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('complaints')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor ??
                      theme.cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color:
                              theme.appBarTheme.foregroundColor ??
                                  theme.iconTheme.color ??
                                  const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'شكاواي',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.appBarTheme.foregroundColor ??
                                  theme.textTheme.titleMedium?.color,
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
                child: StreamBuilder<
                    QuerySnapshot<Map<String, dynamic>>>(
                  stream: _complaintsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد شكاوى حتى الآن.',
                          style:
                              theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    // مراقبة تغيّر الحالة
                    for (final doc in docs) {
                      final id = doc.id;
                      final data = doc.data();
                      final status =
                          (data['status'] ?? '').toString();
                      final title =
                          (data['title'] ?? '').toString();

                      if (_lastKnownStatus.containsKey(id)) {
                        final prev = _lastKnownStatus[id];
                        if (prev != null &&
                            prev != status &&
                            prev.isNotEmpty &&
                            status.isNotEmpty) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) {
                            _showStatusChangedDialog(
                              complaintTitle:
                                  title.isEmpty ? 'بدون عنوان' : title,
                              oldStatus: prev,
                              newStatus: status,
                            );
                          });
                        }
                      }

                      _lastKnownStatus[id] = status;
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();

                        final title =
                            (data['title'] ?? '').toString();
                        final ministry =
                            (data['ministry'] ?? 'غير محددة')
                                .toString();
                        final status =
                            (data['status'] ?? 'pending')
                                .toString();
                        final createdAt = data['createdAt'];
                        String dateText = '';

                        if (createdAt is Timestamp) {
                          final dt = createdAt.toDate();
                          dateText =
                              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                        }

                        final statusLabel =
                            _statusLabel(status);
                        final statusColor =
                            _statusColor(theme, status);
                        final statusBg =
                            _statusBg(theme, status);

                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // العنوان + الحالة
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
                                          title.isEmpty
                                              ? 'شكوى بدون عنوان'
                                              : title,
                                          style: theme
                                              .textTheme.bodyLarge
                                              ?.copyWith(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 4),
                                        Text(
                                          ministry,
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius:
                                          BorderRadius.circular(
                                              999),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (dateText.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .calendar_today_outlined,
                                      size: 14,
                                      color: theme.iconTheme.color
                                              ?.withOpacity(
                                                  0.6) ??
                                          const Color(
                                              0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'تاريخ التقديم: $dateText',
                                      style: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        fontSize: 11,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
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
}