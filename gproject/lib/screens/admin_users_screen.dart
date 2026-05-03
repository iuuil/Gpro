// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'citizen_details_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final usersQuery = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true);

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
            'حسابات المستخدمين',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: usersQuery.snapshots(),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                    'خطأ في تحميل بيانات المستخدمين:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد حسابات مستخدمين حالياً.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.hintColor,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final userId = doc.id;

                final fullName = (data['fullName'] ??
                        'مستخدم بدون اسم')
                    .toString();
                final email =
                    (data['email'] ?? '').toString();
                final status =
                    (data['status'] ?? 'active').toString();
                final createdAt =
                    (data['createdAt'] as Timestamp?)
                            ?.toDate()
                            .toString()
                            .split(' ')
                            .first ??
                        '';

                final isSuspended =
                    status == 'suspended';
                final statusColor = isSuspended
                    ? theme.colorScheme.error
                    : const Color(0xFF16A34A);
                final statusBg = isSuspended
                    ? theme.colorScheme.errorContainer
                        .withOpacity(0.5)
                    : const Color(0xFFEFFDF3);

                return Container(
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
                              .withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: theme
                                  .colorScheme
                                  .surfaceVariant
                                  // ignore: duplicate_ignore
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color:
                                  theme.iconTheme.color,
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
                                  fullName,
                                  style: theme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: theme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    fontSize: 12,
                                    color: theme.hintColor,
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
                                  BorderRadius.circular(
                                      999),
                            ),
                            child: Text(
                              isSuspended
                                  ? 'معلّق'
                                  : 'نشط',
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
                              Icon(
                                Icons
                                    .calendar_today_outlined,
                                size: 14,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                createdAt,
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  fontSize: 11,
                                  color:
                                      theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  // فتح شاشة الشكاوى للمستخدم
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CitizenDetailsScreen(
                                        filterStatus:
                                            'pending',
                                        userDocId:
                                            userId,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons
                                      .report_problem_outlined,
                                  size: 18,
                                  color: primary,
                                ),
                                label: Text(
                                  'عرض الشكاوى',
                                  style: theme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    fontSize: 12,
                                    color: primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: () async {
                                  final newStatus =
                                      isSuspended
                                          ? 'active'
                                          : 'suspended';

                                  await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({
                                    'status': newStatus,
                                  });

                                  if (!mounted) return;

                                  await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      final dialogTheme =
                                          Theme.of(ctx);
                                      return AlertDialog(
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      16),
                                        ),
                                        title: Text(
                                          'تمت العملية',
                                          textDirection:
                                              TextDirection
                                                  .rtl,
                                          style: dialogTheme
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        content: Text(
                                          isSuspended
                                              ? 'تم تفعيل الحساب بنجاح.'
                                              : 'تم تعليق الحساب بنجاح.',
                                          textDirection:
                                              TextDirection
                                                  .rtl,
                                          style: dialogTheme
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment
                                                .center,
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(
                                                        ctx)
                                                    .pop(),
                                            child: const Text(
                                              'حسنًا',
                                              style:
                                                  TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  isSuspended
                                      ? Icons
                                          .lock_open_outlined
                                      : Icons
                                          .lock_outline,
                                  size: 18,
                                  color: isSuspended
                                      ? const Color(
                                          0xFF16A34A,
                                        )
                                      : const Color(
                                          0xFFDC2626,
                                        ),
                                ),
                                label: Text(
                                  isSuspended
                                      ? 'فك التعليق'
                                      : 'تعليق الحساب',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSuspended
                                        ? const Color(
                                            0xFF16A34A,
                                          )
                                        : const Color(
                                            0xFFDC2626,
                                          ),
                                  ),
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