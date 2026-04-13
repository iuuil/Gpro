// ignore_for_file: deprecated_member_use

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
    final adminDoc = FirebaseFirestore.instance
        .collection('admins')
        .doc(adminDocId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme:
              const IconThemeData(color: Color(0xFF020617)),
          title: const Text(
            'إدارة صلاحيات المسؤول',
            style: TextStyle(
              color: Color(0xFF020617),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: adminDoc.snapshots(),
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
                  'خطأ في تحميل بيانات المسؤول: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'لم يتم العثور على هذا المسؤول.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
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
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                const Color(0xFFE5E7EB),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
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
                                color:
                                    const Color(0xFFF1F5F9),
                                borderRadius:
                                    BorderRadius.circular(
                                        999),
                                border: Border.all(
                                  color: const Color(
                                      0xFFE5E7EB),
                                ),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: Color(0xFF0F172A),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: Color(
                                          0xFF020617),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    email,
                                    style:
                                        const TextStyle(
                                      fontSize: 13,
                                      color: Color(
                                          0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    'الجهة: $ministry',
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      color: Color(
                                          0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    'مسؤول منذ: $createdAt',
                                    style:
                                        const TextStyle(
                                      fontSize: 11,
                                      color: Color(
                                          0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'الصلاحيات الممنوحة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
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
                              const Color(0xFF6B7280),
                          side: const BorderSide(
                            color: Color(0xFFD1D5DB),
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final confirm =
                              await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'إعادة تعيين الصلاحيات'),
                                content: const Text(
                                  'سيتم إعادة الصلاحيات للحالة الافتراضية (السماح بإدارة الشكاوى وعرض الإحصائيات فقط).',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            context,
                                            false),
                                    child:
                                        const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            context,
                                            true),
                                    child: const Text(
                                      'تأكيد',
                                      style: TextStyle(
                                        color: Color(
                                            0xFF2563EB),
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
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeColor: const Color(0xFF22C55E),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
