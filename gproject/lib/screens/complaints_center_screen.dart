// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'complaint_details_screen.dart';

class ComplaintsCenterScreen extends StatefulWidget {
  const ComplaintsCenterScreen({super.key});

  @override
  State<ComplaintsCenterScreen> createState() =>
      _ComplaintsCenterScreenState();
}

class _ComplaintsCenterScreenState extends State<ComplaintsCenterScreen> {
  static const Color primaryColor = Color(0xFF137FEC);

  // 'الكل' / 'pending' / 'resolved' / 'rejected'
  String _selectedFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // هيدر موحد
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/main-shell',
                            (route) => false,
                          );
                        },
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
                        'حالة الشكاوى',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.appBarTheme.foregroundColor ??
                              theme.textTheme.bodyLarge?.color,
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

              // فلاتر الحالة
              SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(context, 'الكل'),
                    _buildFilterChip(context, 'pending'),
                    _buildFilterChip(context, 'resolved'),
                    _buildFilterChip(context, 'rejected'),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: user == null
                    ? Center(
                        child: Text(
                          'يرجى تسجيل الدخول لعرض الشكاوى.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('complaints')
                            .where('userId', isEqualTo: user.uid)
                            .orderBy('createdAt', descending: true)
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'حدث خطأ أثناء جلب الشكاوى: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          // تحويل الوثائق إلى _ComplaintItem
                          final complaints = docs.map((doc) {
                            final data = doc.data()
                                    as Map<String, dynamic>? ??
                                {};

                            final status = (data['status'] ?? 'pending')
                                .toString()
                                .trim();

                            final createdAt =
                                (data['createdAt'] as Timestamp?)
                                    ?.toDate()
                                    .toString()
                                    .split(' ')
                                    .first;

                            return _ComplaintItem(
                              id: doc.id,
                              title: (data['title'] as String?)
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                  ? data['title'] as String
                                  : (data['description'] as String? ??
                                          'بدون عنوان')
                                      .toString(),
                              statusLabel: _statusLabelFromStatus(status),
                              statusCode: status,
                              statusType:
                                  _statusFromStatusField(status),
                              date: createdAt ?? '',
                              lastUpdate:
                                  (data['lastUpdate'] as String? ??
                                          'لا توجد تحديثات متاحة حالياً.')
                                      .toString(),
                            );
                          }).toList();

                          // تطبيق الفلتر محلياً
                          final List<_ComplaintItem> filtered;
                          if (_selectedFilter == 'الكل') {
                            filtered = complaints;
                          } else {
                            filtered = complaints
                                .where((c) =>
                                    c.statusCode == _selectedFilter)
                                .toList();
                          }

                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                'لا توجد شكاوى لعرضها.',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: 14,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 100),
                            child: Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 520),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'نظرة عامة على شكواك',
                                    style: theme
                                        .textTheme.bodyLarge
                                        ?.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  for (final c in filtered) ...[
                                    _StatusCard(
                                      complaintId: c.id,
                                      title: c.title,
                                      statusLabel: c.statusLabel,
                                      statusType: c.statusType,
                                      date: c.date,
                                      lastUpdate: c.lastUpdate,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
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

  Widget _buildFilterChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final bool isSelected = _selectedFilter == label;
    String displayLabel;

    switch (label) {
      case 'pending':
        displayLabel = 'قيد المراجعة';
        break;
      case 'resolved':
        displayLabel = 'تم حلها';
        break;
      case 'rejected':
        displayLabel = 'مرفوضة';
        break;
      default:
        displayLabel = 'الكل';
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? primaryColor.withOpacity(0.6)
                : theme.dividerColor,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? primaryColor
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  // helpers لتحويل القيم النصية للحالة
  ComplaintStatus _statusFromStatusField(String status) {
    switch (status) {
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'rejected':
        return ComplaintStatus.rejected;
      case 'pending':
      default:
        return ComplaintStatus.review;
    }
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
}

enum ComplaintStatus { review, resolved, rejected, newStatus }

class _ComplaintItem {
  final String id;
  final String title;
  final String statusLabel;
  final String statusCode; // كود الحالة من Firestore
  final ComplaintStatus statusType;
  final String date;
  final String lastUpdate;

  const _ComplaintItem({
    required this.id,
    required this.title,
    required this.statusLabel,
    required this.statusCode,
    required this.statusType,
    required this.date,
    required this.lastUpdate,
  });
}

class _StatusCard extends StatelessWidget {
  final String complaintId;
  final String title;
  final String statusLabel;
  final ComplaintStatus statusType;
  final String date;
  final String lastUpdate;

  const _StatusCard({
    required this.complaintId,
    required this.title,
    required this.statusLabel,
    required this.statusType,
    required this.date,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _statusColors(statusType);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + شارة الحالة
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors['bg'],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors['text'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // التاريخ
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.iconTheme.color?.withOpacity(0.6) ??
                    const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                'التاريخ: $date',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // آخر تحديث
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.update,
                  size: 14,
                  color: theme.iconTheme.color?.withOpacity(0.6) ??
                      const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lastUpdate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // زر عرض التفاصيل
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ComplaintDetailsScreen(complaintId: complaintId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.dividerColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, Color> _statusColors(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.review:
        return {
          'bg': const Color(0xFFE0F2FE),
          'text': const Color(0xFF0369A1),
        };
      case ComplaintStatus.resolved:
        return {
          'bg': const Color(0xFFDCFCE7),
          'text': const Color(0xFF15803D),
        };
      case ComplaintStatus.rejected:
        return {
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFFB91C1C),
        };
      case ComplaintStatus.newStatus:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF374151),
        };
    }
  }
}