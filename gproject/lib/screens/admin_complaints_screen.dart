// ignore_for_file: deprecated_member_use, non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_complaint_details_screen.dart';

// رجعنا neww كحالة خاصة لفلتر "جديدة"
enum ComplaintStatus { all, neww, pending, resolved, rejected, underReview }

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({
    super.key,
    this.initialFilter = ComplaintStatus.all,
  });

  final ComplaintStatus initialFilter;

  // ممكن تتركهم كقيم افتراضية، بس راح نستخدم theme أغلب الوقت
  static const Color primaryColor = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  @override
  State<AdminComplaintsScreen> createState() =>
      _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState
    extends State<AdminComplaintsScreen> {
  late ComplaintStatus _selectedFilter;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedFilter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ComplaintStatus _statusFromString(String? status) {
    switch (status) {
      case 'new':
      case 'neww':
        return ComplaintStatus.neww; // نخزنها داخلياً كـ neww
      case 'pending':
        return ComplaintStatus.pending;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'rejected':
        return ComplaintStatus.rejected;
      case 'underReview':
        return ComplaintStatus.underReview;
      default:
        return ComplaintStatus.all;
    }
  }

  bool _filterByStatus(
    ComplaintStatus complaintStatus,
    Map<String, dynamic> c,
  ) {
    // فلتر "الكل" => لا يقيّد بالحالة
    if (_selectedFilter == ComplaintStatus.all) return true;

    // فلتر "جديدة" => الشكاوى pending خلال آخر 24 ساعة فقط
    if (_selectedFilter == ComplaintStatus.neww) {
      // لازم تكون حالتها pending
      if (complaintStatus != ComplaintStatus.pending) {
        return false;
      }

      final createdAt = c['createdAt'];
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        final isLast24h =
            DateTime.now().difference(dt).inHours <= 24;
        return isLast24h;
      } else {
        return false;
      }
    }

    // باقي الفلاتر العادية (قيد المراجعة، تم الحل، مرفوضة)
    return complaintStatus == _selectedFilter;
  }

  bool _filterBySearch(Map<String, dynamic> c) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return true;

    final id = (c['id'] ?? '').toString();
    final citizen = (c['citizenName'] ?? '').toString();
    final title = (c['title'] ?? '').toString();
    final text = '$id $citizen $title';

    return text.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final scaffoldBg =
        theme.scaffoldBackgroundColor; // نستخدمه بدل backgroundLight

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor ??
                      theme.cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: theme
                                  .appBarTheme
                                  .foregroundColor ??
                              theme.iconTheme.color ??
                              const Color(0xFF020617),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'كل الشكاوى (عرض المسؤول)',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme
                                  .appBarTheme
                                  .foregroundColor ??
                              const Color(0xFF020617),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // حقل البحث
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'البحث برقم الشكوى أو اسم المواطن...',
                      filled: true,
                      fillColor: theme.cardColor,
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.iconTheme.color
                                ?.withOpacity(0.6) ??
                            const Color(0xFF94A3B8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // الفلاتر (أضفنا "جديدة")
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  children: [
                    _buildFilterChip(
                      context: context,
                      label: 'الكل',
                      selected:
                          _selectedFilter == ComplaintStatus.all,
                      onTap: () {
                        setState(() =>
                            _selectedFilter =
                                ComplaintStatus.all);
                      },
                    ),
                    _buildFilterChip(
                      context: context,
                      label: 'جديدة',
                      selected: _selectedFilter ==
                          ComplaintStatus.neww,
                      dotColor: primary,
                      onTap: () {
                        setState(() => _selectedFilter =
                            ComplaintStatus.neww);
                      },
                    ),
                    _buildFilterChip(
                      context: context,
                      label: 'قيد المراجعة',
                      selected: _selectedFilter ==
                          ComplaintStatus.pending,
                      dotColor: Colors.amber,
                      onTap: () {
                        setState(() => _selectedFilter =
                            ComplaintStatus.pending);
                      },
                    ),
                    _buildFilterChip(
                      context: context,
                      label: 'تم الحل',
                      selected: _selectedFilter ==
                          ComplaintStatus.resolved,
                      dotColor: Colors.green,
                      onTap: () {
                        setState(() => _selectedFilter =
                            ComplaintStatus.resolved);
                      },
                    ),
                    _buildFilterChip(
                      context: context,
                      label: 'مرفوضة',
                      selected: _selectedFilter ==
                          ComplaintStatus.rejected,
                      dotColor: theme
                          .colorScheme.error,
                      onTap: () {
                        setState(() => _selectedFilter =
                            ComplaintStatus.rejected);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // شكاوى + إحصائيات من Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .orderBy('createdAt',
                          descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final theme = Theme.of(context);
                    // ignore: unused_local_variable
                    final primary =
                        theme.colorScheme.primary;

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء تحميل الشكاوى: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style:
                              theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    final docs =
                        snapshot.data?.docs ?? [];

                    // حساب الإحصائيات من كل الشكاوى
                    int total = docs.length;
                    int pendingCount = 0;
                    int resolvedCount = 0;
                    int rejectedCount = 0;
                    int newCount = 0;

                    for (final doc in docs) {
                      final data = doc.data()
                          as Map<String, dynamic>;
                      final s = (data['status'] ?? '')
                          .toString()
                          .trim();
                      final createdAt =
                          data['createdAt'];

                      switch (s) {
                        case 'pending':
                          pendingCount++;
                          // نعتبر "جديدة" pending خلال آخر 24 ساعة
                          if (createdAt
                              is Timestamp) {
                            final dt =
                                createdAt.toDate();
                            final isLast24h = DateTime
                                    .now()
                                .difference(dt)
                                .inHours <=
                                24;
                            if (isLast24h) {
                              newCount++;
                            }
                          }
                          break;
                        case 'resolved':
                          resolvedCount++;
                          break;
                        case 'rejected':
                          rejectedCount++;
                          break;
                        case 'new':
                        case 'neww':
                          // لو عندك حالة خاصة في الـ DB
                          newCount++;
                          break;
                        default:
                          break;
                      }
                    }

                    // تحويل للعرض (مع الفلتر الحالي والبحث)
                    final complaints = docs
                        .map((doc) {
                          final data = doc.data()
                              as Map<String, dynamic>;
                          data['docId'] = doc.id;
                          return data;
                        })
                        .where((c) {
                          final status =
                              _statusFromString(
                            (c['status'] ?? '')
                                .toString(),
                          );

                          return _filterByStatus(
                                  status, c) &&
                              _filterBySearch(c);
                        })
                        .toList();

                    if (complaints.isEmpty) {
                      return SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildStatsRow(
                              context: context,
                              total: total,
                              pending:
                                  pendingCount,
                              resolved:
                                  resolvedCount,
                              rejected:
                                  rejectedCount,
                              newCount: newCount,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'لا توجد شكاوى مطابقة للبحث / الفلتر الحالي.',
                                style: theme.textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontSize: 14,
                                  color: theme
                                      .hintColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildStatsRow(
                            context: context,
                            total: total,
                            pending: pendingCount,
                            resolved: resolvedCount,
                            rejected: rejectedCount,
                            newCount: newCount,
                          ),
                          const SizedBox(height: 12),
                          for (final c in complaints)
                            _ComplaintCard(
                              data: c,
                              status:
                                  _statusFromString(
                                (c['status'] ?? '')
                                    .toString(),
                              ),
                            ),
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

  Widget _buildStatsRow({
    required BuildContext context,
    required int total,
    required int pending,
    required int resolved,
    required int rejected,
    required int newCount,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'إجمالي الشكاوى',
            value: total.toString(),
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'شكاوى جديدة (آخر ٢٤ ساعة)',
            value: newCount.toString(),
            color: primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'شكاوى قيد المراجعة',
            value: pending.toString(),
            color: Colors.amber.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'تم حلها',
            value: resolved.toString(),
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'مرفوضة',
            value: rejected.toString(),
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool selected,
    Color? dotColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding:
          const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? primary
                : theme.cardColor,
            borderRadius:
                BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? primary
                  : theme.dividerColor,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : const Color(0xFF1F2933),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كرت الإحصائيات الصغير
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness ==
        Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall
                ?.copyWith(
              fontSize: 11,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// كارت الشكوى الواحد مع النقل لصفحة التفاصيل
class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final ComplaintStatus status;

  const _ComplaintCard({
    required this.data,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    Color sideColor;
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    switch (status) {
      case ComplaintStatus.pending:
      case ComplaintStatus.underReview:
        sideColor = Colors.amber;
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFF92400E);
        badgeLabel = 'قيد المراجعة';
        break;
      case ComplaintStatus.resolved:
        sideColor = Colors.green;
        badgeBg = const Color(0xFFD1FAE5);
        badgeText = const Color(0xFF047857);
        badgeLabel = 'تم الحل';
        break;
      case ComplaintStatus.rejected:
        sideColor = theme.colorScheme.error;
        badgeBg = theme.colorScheme
            .errorContainer;
        badgeText = theme.colorScheme.error;
        badgeLabel = 'مرفوضة';
        break;
      case ComplaintStatus.neww:
        sideColor = primary;
        badgeBg = const Color(0xFFDBEAFE);
        badgeText = const Color(0xFF1D4ED8);
        badgeLabel = 'جديدة';
        break;
      case ComplaintStatus.all:
      // ignore: unreachable_switch_default
      default:
        sideColor = theme.hintColor;
        badgeBg = const Color(0xFFE5E7EB);
        badgeText = const Color(0xFF374151);
        badgeLabel = 'غير محدد';
        break;
    }

    final docId =
        (data['docId'] ?? '').toString(); // مهم
    final id = (data['id'] ?? '').toString();
    final title = (data['title'] ?? '').toString();
    final ministry =
        (data['ministry'] ?? '').toString();
    final citizen =
        (data['citizenName'] ?? '').toString();
    final createdAt = data['createdAt'];
    String dateText = '';

    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      dateText =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } else {
      dateText = (data['date'] ?? '').toString();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (docId.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminComplaintDetailsScreen(
              complaintDocId: docId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.dividerColor,
          ),
          boxShadow: [
            if (theme.brightness ==
                Brightness.light)
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: sideColor,
                  borderRadius:
                      const BorderRadiusDirectional
                          .only(
                    topEnd: Radius.circular(14),
                    bottomEnd:
                        Radius.circular(14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // العنوان + الوزارة + البادج
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
                              '$title - ID $id',
                              style: theme
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w700,
                                color: theme
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                            const SizedBox(
                                height: 4),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: primary
                                    .withOpacity(
                                        0.08),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            999),
                              ),
                              child: Text(
                                ministry,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color: primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius:
                              BorderRadius.circular(
                                  8),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // المواطن + التاريخ
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          citizen.isEmpty
                              ? 'غير معروف'
                              : citizen,
                          style: theme
                              .textTheme.bodySmall
                              ?.copyWith(
                            fontSize: 12,
                            color:
                                theme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons
                            .calendar_today_outlined,
                        size: 14,
                        color: theme.hintColor
                            .withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تاريخ التقديم: $dateText',
                        style: theme
                            .textTheme.bodySmall
                            ?.copyWith(
                          fontSize: 11,
                          color:
                              theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}