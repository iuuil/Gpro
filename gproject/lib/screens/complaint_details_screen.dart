// ignore_for_file: dead_code, deprecated_member_use, empty_statements, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/account_screen.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
  });

  // نخلي الألوان البراند تعتمد على الثيم قدر الإمكان، بس نخلي قيم افتراضية إذا ما حددت بالثيم
  static const Color brandBlue = Color(0xFF4A76B8);
  static const Color brandLightBlue = Color(0xFFA3BCE0);
  static const Color bgGray = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? theme.scaffoldBackgroundColor : bgGray,
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
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color:
                              theme.appBarTheme.foregroundColor ??
                                  theme.iconTheme.color ??
                                  const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'تفاصيل الشكوى',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.appBarTheme.foregroundColor ??
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

              // المحتوى
              Expanded(
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(complaintId)
                      .get(),
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            child: Text(
                              'حدث خطأ أثناء جلب بيانات الشكوى:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontSize: 13,
                                color: theme.colorScheme.error,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'لم يتم العثور على هذه الشكوى.',
                            textAlign: TextAlign.center,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      );
                    }

                    final data =
                        snapshot.data!.data() as Map<String, dynamic>? ??
                            {};

                    final title =
                        (data['title'] as String?)?.trim().isNotEmpty ==
                                true
                            ? data['title'] as String
                            : (data['description'] as String? ??
                                    'بدون عنوان')
                                .toString();
                    final description =
                        (data['description'] as String? ?? '')
                            .toString();
                    final status =
                        (data['status'] as String? ?? 'pending')
                            .toString();
                    final ministry =
                        (data['ministry'] as String? ?? 'غير محددة')
                            .toString();
                    final createdAt = (data['createdAt'] as Timestamp?)
                        ?.toDate()
                        .toString()
                        .split(' ')
                        .first;
                    final contactName =
                        (data['contactName'] as String? ?? '')
                            .toString();
                    final contactPhone =
                        (data['contactPhone'] as String? ?? '')
                            .toString();

                    // المرفقات
                    final List<dynamic> attachmentsDyn =
                        (data['attachments'] as List<dynamic>? ??
                            []);
                    final List<String> attachments = attachmentsDyn
                        .map((e) => e.toString())
                        .toList();

                    final statusLabel =
                        _statusLabelFromStatus(status);
                    final statusColor =
                        _statusColorFromStatus(status);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          // كرت نظرة عامة
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildComplaintOverviewSection(
                              context: context,
                              title: title,
                              description: description,
                              statusLabel: statusLabel,
                              statusColor: statusColor,
                              ministry: ministry,
                              createdAt: createdAt,
                              attachments: attachments,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // كرت معلومات صاحب الشكوى
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildComplainantInfoSection(
                              context: context,
                              contactName: contactName,
                              contactPhone: contactPhone,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // كرت ملاحظة النظام
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius:
                                  BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildInternalCommentsSection(
                                context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // زر حذف الشكوى أسفل الصفحة
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor:
                          theme.colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          final dialogTheme =
                              Theme.of(ctx).dialogTheme;
                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              shape: dialogTheme.shape ??
                                  RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            16),
                                  ),
                              title: Text(
                                'تأكيد الحذف',
                                textAlign: TextAlign.center,
                                style: dialogTheme.titleTextStyle ??
                                    Theme.of(ctx)
                                        .textTheme
                                        .titleMedium,
                              ),
                              content: Text(
                                'هل أنت متأكد من حذف هذه الشكوى بشكل نهائي؟',
                                textAlign: TextAlign.center,
                                style:
                                    dialogTheme.contentTextStyle ??
                                        Theme.of(ctx)
                                            .textTheme
                                            .bodyMedium,
                              ),
                              actionsAlignment:
                                  MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      if (confirm != true) return;

                      try {
                        await FirebaseFirestore.instance
                            .collection('complaints')
                            .doc(complaintId)
                            .delete();

                        if (context.mounted) {
                          await showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) {
                              final themeDialog =
                                  Theme.of(ctx);
                              return Directionality(
                                textDirection:
                                    TextDirection.rtl,
                                child: AlertDialog(
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            18),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(
                                          24, 24, 24, 8),
                                  content: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons
                                            .check_circle_rounded,
                                        color: themeDialog
                                            .colorScheme
                                            .primary,
                                        size: 48,
                                      ),
                                      const SizedBox(
                                          height: 12),
                                      Text(
                                        'تم حذف الشكوى بنجاح',
                                        textAlign:
                                            TextAlign.center,
                                        style: themeDialog
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 8),
                                      Text(
                                        'تمت إزالة الشكوى من سجلك في النظام.',
                                        textAlign:
                                            TextAlign.center,
                                        style: themeDialog
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.center,
                                  actions: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(
                                              bottom: 8),
                                      child: SizedBox(
                                        width:
                                            double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                                themeDialog
                                                    .colorScheme
                                                    .primary,
                                            foregroundColor:
                                                themeDialog
                                                    .colorScheme
                                                    .onPrimary,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          10),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(ctx)
                                                .pop();
                                          },
                                          child: const Text(
                                            'حسنًا',
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'فشل حذف الشكوى: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    label: const Text(
                      'حذف الشكوى',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // == Sections ==

  Widget _buildComplaintOverviewSection({
    required BuildContext context,
    required String title,
    required String description,
    required String statusLabel,
    required Color statusColor,
    required String ministry,
    required String? createdAt,
    required List<String> attachments,
  }) {
    final theme = Theme.of(context);
    final subtleBg = theme.colorScheme.surfaceVariant
        .withOpacity(0.25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان + الحالة
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (ministry.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.account_balance,
                size: 16,
                color: theme.iconTheme.color
                        ?.withOpacity(0.6) ??
                    const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                'الجهة: $ministry',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (createdAt != null)
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.iconTheme.color
                        ?.withOpacity(0.5) ??
                    const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Text(
                'تاريخ الإرسال: $createdAt',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontSize: 12),
              ),
            ],
          ),
        const SizedBox(height: 12),
        Text(
          'وصف المشكلة',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: subtleBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.dividerColor,
            ),
          ),
          child: Text(
            description.isNotEmpty
                ? description
                : 'لا يوجد وصف تفصيلي لهذه الشكوى.',
            style:
                theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'المرفقات',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (attachments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: subtleBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 16,
                  color: theme.iconTheme.color
                          ?.withOpacity(0.5) ??
                      const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'لا توجد مرفقات مضافة لهذه الشكوى.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: subtleBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor,
              ),
            ),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = attachments[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildComplainantInfoSection({
    required BuildContext context,
    required String contactName,
    required String contactPhone,
  }) {
    final theme = Theme.of(context);
    final hasName = contactName.trim().isNotEmpty;
    final hasPhone = contactPhone.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات صاحب الشكوى',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: brandLightBlue,
              child: Icon(
                Icons.person,
                size: 26,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    hasName
                        ? contactName
                        : 'مستخدم التطبيق',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasPhone)
                    Row(
                      children: [
                        Icon(
                          Icons.phone_in_talk_outlined,
                          size: 12,
                          color: theme.iconTheme.color
                                  ?.withOpacity(0.6) ??
                              const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contactPhone,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'لم يقم المستخدم بإدخال رقم هاتف.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                        fontSize: 11,
                        color: theme.hintColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 10),
            ),
            child: Text(
              'عرض الملف الشخصي',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInternalCommentsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظة',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _InternalCommentCard(
          author: 'النظام',
          datetime: '—',
          text:
              'تم تسجيل الشكوى في النظام، بانتظار اتخاذ إجراء من الجهة المختصة.',
        ),
      ],
    );
  }

  // == Helpers للحالة ==

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

  Color _statusColorFromStatus(String status) {
    switch (status) {
      case 'resolved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFB91C1C);
      case 'pending':
      default:
        return const Color(0xFF0369A1);
    }
  }
}

// == Widgets مساعدة ==

class _InternalCommentCard extends StatelessWidget {
  final String author;
  final String datetime;
  final String text;

  const _InternalCommentCard({
    required this.author,
    required this.datetime,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        theme.colorScheme.primary.withOpacity(0.8);

    return Container(
      padding: const EdgeInsets.only(
        right: 10,
        left: 8,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                datetime,
                style: theme.textTheme.bodySmall
                    ?.copyWith(
                  fontSize: 10,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}