// ignore_for_file: duplicate_ignore, unused_local_variable, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPermissionsScreen extends StatelessWidget {
  final String adminDocId;

  const AdminPermissionsScreen({
    super.key,
    required this.adminDocId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final adminDoc =
        FirebaseFirestore.instance.collection('admins').doc(adminDocId);

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
            'إدارة صلاحيات المسؤول',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: adminDoc.snapshots(),
          builder: (context, snapshot) {
            final theme = Theme.of(context);
            final primary = theme.colorScheme.primary;

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'خطأ في تحميل بيانات المسؤول: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'لم يتم العثور على هذا المسؤول.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.hintColor,
                  ),
                ),
              );
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>;

            final name =
                (data['name'] ?? 'مسؤول النظام').toString();
            final email =
                (data['email'] ?? 'لا يوجد بريد إلكتروني')
                    .toString();
            final ministry =
                (data['ministry'] ?? 'غير محدد').toString();
            final createdAt =
                (data['createdAt'] as Timestamp?)
                        ?.toDate()
                        .toString()
                        .split(' ')
                        .first ??
                    '';

            bool canManageComplaints =
                (data['canManageComplaints'] ?? true) == true;
            bool canManageUsers =
                (data['canManageUsers'] ?? false) == true;
            bool canViewStats =
                (data['canViewStats'] ?? true) == true;

            final cardColor = theme.cardColor;
            final borderColor = theme.dividerColor;

            return StatefulBuilder(
              builder: (context, setStateLocal) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // كرت معلومات المسؤول
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
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 54,
                              width: 54,
                              decoration: BoxDecoration(
                                color: theme
                                    .colorScheme.surfaceVariant
                                    .withOpacity(0.7),
                                borderRadius:
                                    BorderRadius.circular(
                                        999),
                                border: Border.all(
                                  color: borderColor,
                                ),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: theme
                                    .colorScheme.onSurface,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    name,
                                    style: theme
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: theme
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: theme
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      fontSize: 13,
                                      color:
                                          theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'الجهة: $ministry',
                                    style: theme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      fontSize: 12,
                                      color:
                                          theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'مسؤول منذ: $createdAt',
                                    style: theme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      fontSize: 11,
                                      color: theme
                                          .hintColor
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'الصلاحيات الممنوحة',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _PermissionTile(
                        title: 'إدارة الشكاوى',
                        subtitle:
                            'يمكنه مراجعة الشكاوى وتغيير حالتها.',
                        value: canManageComplaints,
                        onChanged: (v) async {
                          setStateLocal(() {
                            canManageComplaints = v;
                          });
                          await adminDoc.update({
                            'canManageComplaints': v,
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _PermissionTile(
                        title: 'إدارة المستخدمين',
                        subtitle:
                            'يمكنه تعليق/تنشيط المستخدمين وحذفهم.',
                        value: canManageUsers,
                        onChanged: (v) async {
                          setStateLocal(() {
                            canManageUsers = v;
                          });
                          await adminDoc.update({
                            'canManageUsers': v,
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _PermissionTile(
                        title: 'عرض لوحة الإحصائيات',
                        subtitle:
                            'يمكنه الدخول لصفحة الإحصائيات والتقارير.',
                        value: canViewStats,
                        onChanged: (v) async {
                          setStateLocal(() {
                            canViewStats = v;
                          });
                          await adminDoc.update({
                            'canViewStats': v,
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // زر إعادة تعيين الصلاحيات
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              theme.hintColor,
                          side: BorderSide(
                            color: borderColor,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                          ),
                        ),
                        onPressed: () async {
                          final confirm =
                              await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              final dialogTheme =
                                  Theme.of(context);
                              final primaryDialog = dialogTheme
                                  .colorScheme.primary;
                              return AlertDialog(
                                title: Text(
                                  'إعادة تعيين الصلاحيات',
                                  style: dialogTheme
                                      .textTheme
                                      .titleMedium,
                                ),
                                content: Text(
                                  'سيتم إعادة الصلاحيات للحالة الافتراضية (السماح بإدارة الشكاوى وعرض الإحصائيات فقط).',
                                  style: dialogTheme
                                      .textTheme
                                      .bodyMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                      context,
                                      false,
                                    ),
                                    child:
                                        const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                      context,
                                      true,
                                    ),
                                    child: Text(
                                      'تأكيد',
                                      style: TextStyle(
                                        color:
                                            primaryDialog,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            setStateLocal(() {
                              canManageComplaints = true;
                              canManageUsers = false;
                              canViewStats = true;
                            });
                            await adminDoc.update({
                              'canManageComplaints': true,
                              'canManageUsers': false,
                              'canViewStats': true,
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                        ),
                        label: const Text(
                          'إعادة تعيين إلى الافتراضي',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

class _PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    // ignore: unused_local_variable
    final borderColor = theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
