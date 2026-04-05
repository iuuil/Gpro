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

  String _selectedFilter = 'الكل'; // 'الكل' أو 'pending' أو 'resolved' أو 'rejected'

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 6,
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
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main-shell',
                            (route) => false,
                          );
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'حالة الشكاوى',
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

              // فلاتر الحالة
              SizedBox(
                height: 44,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('الكل'),
                    _buildFilterChip('pending'),
                    _buildFilterChip('resolved'),
                    _buildFilterChip('rejected'),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: user == null
                    ? const Center(
                        child: Text(
                          'يرجى تسجيل الدخول لعرض الشكاوى.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('complaints')
                            .where('userId', isEqualTo: user.uid)
                            .orderBy('createdAt', descending: true)
                            .snapshots(), // [web:404][web:402]
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
                                'حدث خطأ أثناء جلب الشكاوى: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB91C1C),
                                ),
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          // تحويل الوثائق إلى _ComplaintItem
                          final complaints = docs.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};
                            final status =
                                (data['status'] ?? 'pending').toString().trim();

                            return _ComplaintItem(
                              id: doc.id,
                              title:
                                  (data['title'] as String?)?.isNotEmpty ==
                                          true
                                      ? data['title'] as String
                                      : (data['description'] as String? ??
                                              'بدون عنوان')
                                          .toString(),
                              statusLabel: _statusLabelFromStatus(status),
                              statusCode: status, // نخزن كود الحالة كما هو
                              statusType: _statusFromStatusField(status),
                              date: (data['createdAt'] as Timestamp?)
                                      ?.toDate()
                                      .toString()
                                      .split(' ')
                                      .first ??
                                  '',
                              lastUpdate: data['lastUpdate'] as String? ??
                                  'لا توجد تحديثات متاحة حالياً.',
                            );
                          }).toList();

                          // تطبيق الفلتر حسب كود الحالة
                          final List<_ComplaintItem> filtered;
                          if (_selectedFilter == 'الكل') {
                            filtered = complaints;
                          } else {
                            filtered = complaints
                                .where(
                                    (c) => c.statusCode == _selectedFilter)
                                .toList();
                          }

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text(
                                'لا توجد شكاوى لعرضها.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'نظرة عامة على شكواك',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
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

  Widget _buildFilterChip(String label) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color:
                isSelected ? primaryColor : const Color(0xFF374151),
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
  final String statusCode; // ← كود الحالة من Firestore
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
    final colors = _statusColors(statusType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                'التاريخ: $date',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // آخر تحديث
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.update,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lastUpdate,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF6B7280),
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
                side: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF137FEC),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF137FEC),
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