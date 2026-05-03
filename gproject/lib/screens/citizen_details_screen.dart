// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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
        FirebaseFirestore.instance.collection('complaints');

    if (userDocId.isNotEmpty) {
      q = q.where('userId', isEqualTo: userDocId);
    }

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
      return 'الشكاوى المعلّقة';
    }
    return 'تفاصيل الشكاوى';
  }

  @override
  Widget build(BuildContext context) {
    final query = _buildQuery();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      theme.appBarTheme.backgroundColor ?? theme.cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
                          color:
                              theme.appBarTheme.foregroundColor ??
                                  theme.iconTheme.color ??
                                  const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _titleText(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              theme.appBarTheme.foregroundColor ??
                                  theme.textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'خطأ في تحميل بيانات الشكاوى: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      final msg = filterStatus == 'resolved'
                          ? 'لا توجد شكاوى معالجة حالياً.'
                          : filterStatus == 'pending'
                              ? 'لا توجد شكاوى معلّقة حالياً.'
                              : (userDocId.isNotEmpty
                                  ? 'لا توجد شكاوى لهذا المواطن.'
                                  : 'لا توجد شكاوى حالياً في النظام.');
                      return Center(
                        child: Text(
                          msg,
                          style:
                              theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.hintColor,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Container(
                        constraints:
                            const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قائمة الشكاوى',
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ListView.separated(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data();
                                final title = (data['title'] ??
                                        'شكوى بدون عنوان')
                                    .toString();
                                final description =
                                    (data['description'] ?? '')
                                        .toString();
                                final status =
                                    (data['status'] ?? 'pending')
                                        .toString();
                                final citizenName =
                                    (data['citizenName'] ??
                                            'مواطن غير معروف')
                                        .toString();
                                final ministry =
                                    (data['ministry'] ??
                                            'غير محدد')
                                        .toString();
                                final createdAt =
                                    (data['createdAt']
                                                as Timestamp?)
                                            ?.toDate()
                                            .toString()
                                            .split(' ')
                                            .first ??
                                        '';

                                final bool isResolved =
                                    status == 'resolved' ||
                                        status == 'closed';
                                final bool isPending =
                                    status == 'pending' ||
                                        status == 'suspended';

                                final Color statusColor =
                                    isResolved
                                        ? const Color(0xFF16A34A)
                                        : isPending
                                            ? const Color(
                                                0xFFF59E0B)
                                            : theme.hintColor;

                                final Color statusBg =
                                    isResolved
                                        ? const Color(0xFFEFFDF3)
                                        : isPending
                                            ? const Color(
                                                0xFFFFF7E6)
                                            : theme.dividerColor
                                                .withOpacity(
                                                    0.3);

                                final String statusText =
                                    isResolved
                                        ? 'معالجة'
                                        : isPending
                                            ? 'معلقة'
                                            : status;

                                return Container(
                                  padding:
                                      const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius:
                                        BorderRadius.circular(
                                            14),
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(
                                                  0.03),
                                          blurRadius: 4,
                                          offset:
                                              const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration:
                                                BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .surfaceVariant,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          12),
                                            ),
                                            child: Icon(
                                              Icons
                                                  .description_outlined,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(
                                              width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                    fontSize:
                                                        14,
                                                    fontWeight:
                                                        FontWeight
                                                            .w700,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 2),
                                                if (description
                                                    .isNotEmpty)
                                                  Text(
                                                    description,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                      fontSize:
                                                          12,
                                                      color: theme
                                                          .hintColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              width: 6),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          999),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color:
                                                    statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .person_outline,
                                                size: 14,
                                                color: theme
                                                    .iconTheme
                                                    .color
                                                    ?.withOpacity(
                                                        0.6) ??
                                                    const Color(
                                                        0xFF9CA3AF),
                                              ),
                                              const SizedBox(
                                                  width: 4),
                                              Text(
                                                citizenName,
                                                style: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                  fontSize: 11,
                                                  color: theme
                                                      .hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .account_balance_outlined,
                                                size: 14,
                                                color: theme
                                                    .iconTheme
                                                    .color
                                                    ?.withOpacity(
                                                        0.6) ??
                                                    const Color(
                                                        0xFF9CA3AF),
                                              ),
                                              const SizedBox(
                                                  width: 4),
                                              Text(
                                                ministry,
                                                style: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                  fontSize: 11,
                                                  color: theme
                                                      .hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: theme
                                                    .iconTheme
                                                    .color
                                                    ?.withOpacity(
                                                        0.6) ??
                                                    const Color(
                                                        0xFF9CA3AF),
                                              ),
                                              const SizedBox(
                                                  width: 4),
                                              Text(
                                                createdAt,
                                                style: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                  fontSize: 11,
                                                  color: theme
                                                      .hintColor,
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
                            ),
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
}