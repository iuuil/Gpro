// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ignore: unused_field
  static const Color primary = Color(0xFF137FEC);

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('Current UID (NotificationsScreen): $uid');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _notificationsStream() {
    final user = _currentUser;
    if (user == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        // .orderBy('createdAt', descending: true)
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
                    bottom: BorderSide(color: theme.dividerColor),
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
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: theme.appBarTheme.foregroundColor ??
                              theme.iconTheme.color ??
                              const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'الإشعارات',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.appBarTheme.foregroundColor ??
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

              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'أحدث الإشعارات',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // قائمة الإشعارات
                      StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: _notificationsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons
                                        .notifications_off_outlined,
                                    size: 48,
                                    color: theme.hintColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد إشعارات حاليًا',
                                    style: theme
                                        .textTheme.bodyMedium
                                        ?.copyWith(
                                      fontSize: 14,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          return ListView.separated(
                            physics:
                                const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final data = docs[index].data();
                              final title =
                                  (data['title'] ?? 'إشعار جديد')
                                      .toString();
                              final body =
                                  (data['body'] ?? '').toString();
                              final type =
                                  (data['type'] ?? '').toString();
                              final isRead =
                                  (data['isRead'] as bool?) ?? false;
                              final createdAt = data['createdAt'];
                              String timeText = '';

                              if (createdAt is Timestamp) {
                                final dt = createdAt.toDate();
                                timeText =
                                    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
                                    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                              }

                              IconData leadingIcon =
                                  Icons.notifications_none;
                              Color iconColor =
                                  theme.colorScheme.primary;

                              if (type == 'complaint_status') {
                                leadingIcon =
                                    Icons.rule_folder_outlined;
                                iconColor =
                                    const Color(0xFF16A34A);
                              }

                              final Color cardColor = isRead
                                  ? theme.cardColor
                                  : (isDark
                                      ? theme.colorScheme.primary
                                          .withOpacity(0.13)
                                      : const Color(0xFFEFF6FF));

                              return Container(
                                padding:
                                    const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
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
                                        offset:
                                            const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: iconColor
                                            .withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                      child: Icon(
                                        leadingIcon,
                                        color: iconColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                          if (body.isNotEmpty) ...[
                                            const SizedBox(
                                                height: 4),
                                            Text(
                                              body,
                                              style: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                fontSize: 12,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(
                                              height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .access_time,
                                                size: 12,
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
                                                timeText
                                                        .isEmpty
                                                    ? 'الآن'
                                                    : timeText,
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
                                    ),
                                    if (!isRead) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration:
                                            BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primary,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}