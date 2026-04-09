// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CitizenDetailsScreen extends StatelessWidget {
  final String? filterStatus;
  final String userDocId;

  const CitizenDetailsScreen({
    super.key,
    this.filterStatus,
    required this.userDocId,
  });

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> q =
        FirebaseFirestore.instance.collection('complaints')
            .where('userId', isEqualTo: userDocId);

    if (filterStatus == 'resolved') {
      q = q.where('status', whereIn: ['resolved', 'closed']);
    } else if (filterStatus == 'pending') {
      q = q.where('status', whereIn: ['pending', 'suspended']);
    }

    return q.orderBy('createdAt', descending: true);
  }

  String _titleText() {
    if (filterStatus == 'resolved') {
      return 'الشكاوى المعالجة';
    } else if (filterStatus == 'pending') {
      return 'الشكاوى المعلقة';
    }
    return 'تفاصيل الشكاوى';
  }

  @override
  Widget build(BuildContext context) {
    final query = _buildQuery();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Color(0xFF020617)),
          title: Text(
            _titleText(),
            style: const TextStyle(
              color: Color(0xFF020617),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: query.snapshots(),
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
                  'خطأ في تحميل بيانات الشكاوى: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Text(
                  filterStatus == 'resolved'
                      ? 'لا توجد شكاوى معالجة حالياً.'
                      : filterStatus == 'pending'
                          ? 'لا توجد شكاوى معلّقة حالياً.'
                          : 'لا توجد شكاوى.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final data = docs[index].data();
                final title =
                    (data['title'] ?? 'شكوى بدون عنوان').toString();
                final description =
                    (data['description'] ?? '').toString();
                final status =
                    (data['status'] ?? 'pending').toString();
                final citizenName =
                    (data['citizenName'] ?? 'مواطن غير معروف').toString();
                final ministry =
                    (data['ministry'] ?? 'غير محدد').toString();
                final createdAt = (data['createdAt'] as Timestamp?)
                        ?.toDate()
                        .toString()
                        .split(' ')
                        .first ??
                    '';

                final statusColor =
                    status == 'resolved' || status == 'closed'
                        ? const Color(0xFF16A34A)
                        : status == 'pending' || status == 'suspended'
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF6B7280);

                final statusBg =
                    status == 'resolved' || status == 'closed'
                        ? const Color(0xFFEFFDF3)
                        : status == 'pending' || status == 'suspended'
                            ? const Color(0xFFFFF7E6)
                            : const Color(0xFFE5E7EB);

                return Container(
                  padding: const EdgeInsets.all(12),
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: Color(0xFF0F172A),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: Color(0xFF020617),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius:
                                  BorderRadius.circular(999),
                            ),
                            child: Text(
                              status == 'resolved' || status == 'closed'
                                  ? 'معالجة'
                                  : status == 'pending' || status == 'suspended'
                                      ? 'معلقة'
                                      : status,
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                citizenName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_outlined,
                                size: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ministry,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                createdAt,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
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
    );
  }
}