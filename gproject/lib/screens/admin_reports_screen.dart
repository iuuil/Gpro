// ignore_for_file: unused_import, unused_local_variable, deprecated_member_use

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  static const double contentMaxWidth = 520;

  @override
  State<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState
    extends State<AdminReportsScreen> {
  // فلاتر الواجهة
  DateTime? startDate;
  DateTime? endDate;
  String? selectedType = 'all';
  String? selectedRegion = 'all';
  String? selectedMinistry = 'all';

  // الفلاتر المطبقة فعلياً
  DateTime? appliedStartDate;
  DateTime? appliedEndDate;
  String? appliedType = 'all';
  String? appliedRegion = 'all';
  String? appliedMinistry = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final complaintsRef =
        FirebaseFirestore.instance.collection('complaints');

    final Query baseQuery =
        complaintsRef.orderBy('createdAt', descending: true);

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
                  horizontal: 16,
                  vertical: 12,
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
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: theme.iconTheme.color ??
                            const Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                    Text(
                      'التقارير والإحصائيات',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: baseQuery.snapshots(),
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
                            'خطأ في تحميل البيانات: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                              fontSize: 13,
                              color: theme
                                  .colorScheme.error,
                            ),
                          ),
                        ),
                      );
                    }

                    var docs = snapshot.data?.docs ?? [];

                    // ===== تطبيق الفلاتر المطبقة =====

                    if (appliedType != null &&
                        appliedType != 'all') {
                      docs = docs.where((d) {
                        final data = d.data()
                            as Map<String, dynamic>;
                        return data['type'] == appliedType;
                      }).toList();
                    }

                    if (appliedRegion != null &&
                        appliedRegion != 'all') {
                      docs = docs.where((d) {
                        final data = d.data()
                            as Map<String, dynamic>;
                        return data['region'] ==
                            appliedRegion;
                      }).toList();
                    }

                    if (appliedMinistry != null &&
                        appliedMinistry != 'all') {
                      docs = docs.where((d) {
                        final data = d.data()
                            as Map<String, dynamic>;
                        return data['ministry'] ==
                            appliedMinistry;
                      }).toList();
                    }

                    if (appliedStartDate != null) {
                      docs = docs.where((d) {
                        final data = d.data()
                            as Map<String, dynamic>;
                        final ts = data['createdAt']
                            as Timestamp?;
                        if (ts == null) return false;
                        final dt = ts.toDate();
                        final from = DateTime(
                          appliedStartDate!.year,
                          appliedStartDate!.month,
                          appliedStartDate!.day,
                        );
                        return dt.isAtSameMomentAs(from) ||
                            dt.isAfter(from);
                      }).toList();
                    }

                    if (appliedEndDate != null) {
                      docs = docs.where((d) {
                        final data = d.data()
                            as Map<String, dynamic>;
                        final ts = data['createdAt']
                            as Timestamp?;
                        if (ts == null) return false;
                        final dt = ts.toDate();
                        final to = DateTime(
                          appliedEndDate!.year,
                          appliedEndDate!.month,
                          appliedEndDate!.day,
                          23,
                          59,
                          59,
                        );
                        return dt.isAtSameMomentAs(to) ||
                            dt.isBefore(to);
                      }).toList();
                    }

                    // ===== الحسابات =====

                    final totalComplaints = docs.length;

                    int resolvedCount = 0;
                    int openCount = 0;
                    int totalResolutionDays = 0;
                    int resolvedWithTime = 0;

                    final Map<String, int> byType = {};
                    final Map<String, int> byMinistry = {};
                    final Map<String, int> countsByMonth = {};

                    for (final d in docs) {
                      final data =
                          d.data() as Map<String, dynamic>;
                      final status =
                          (data['status'] ?? 'open')
                              .toString();
                      final type =
                          (data['type'] ?? 'unknown')
                              .toString();
                      final ministry =
                          (data['ministry'] ?? 'غير محدد')
                              .toString();
                      final createdAt =
                          data['createdAt'] as Timestamp?;
                      final resolvedAt =
                          data['resolvedAt'] as Timestamp?;

                      byType[type] =
                          (byType[type] ?? 0) + 1;
                      byMinistry[ministry] =
                          (byMinistry[ministry] ?? 0) + 1;

                      if (createdAt != null) {
                        final dt = createdAt.toDate();
                        final key =
                            '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
                        countsByMonth[key] =
                            (countsByMonth[key] ?? 0) + 1;
                      }

                      if (status == 'resolved' ||
                          status == 'closed') {
                        resolvedCount++;
                        if (createdAt != null &&
                            resolvedAt != null) {
                          final diff = resolvedAt
                              .toDate()
                              .difference(
                                  createdAt.toDate())
                              .inHours;
                          totalResolutionDays +=
                              (diff / 24).round();
                          resolvedWithTime++;
                        }
                      } else {
                        openCount++;
                      }
                    }

                    final double avgResolutionDays =
                        resolvedWithTime > 0
                            ? totalResolutionDays /
                                resolvedWithTime
                            : 0;

                    final double resolvedPercent =
                        totalComplaints > 0
                            ? resolvedCount *
                                100 /
                                totalComplaints
                            : 0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(
                            maxWidth:
                                AdminReportsScreen
                                    .contentMaxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _FilterSection(
                                startDate: startDate,
                                endDate: endDate,
                                selectedType:
                                    selectedType,
                                selectedRegion:
                                    selectedRegion,
                                selectedMinistry:
                                    selectedMinistry,
                                onPickStartDate:
                                    () async {
                                  final picked =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        startDate ??
                                            DateTime
                                                .now(),
                                    firstDate:
                                        DateTime(2020),
                                    lastDate:
                                        DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startDate =
                                          picked;
                                    });
                                  }
                                },
                                onPickEndDate:
                                    () async {
                                  final picked =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        endDate ??
                                            DateTime
                                                .now(),
                                    firstDate:
                                        DateTime(2020),
                                    lastDate:
                                        DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      endDate = picked;
                                    });
                                  }
                                },
                                onTypeChanged: (v) {
                                  setState(() {
                                    selectedType = v;
                                  });
                                },
                                onRegionChanged: (v) {
                                  setState(() {
                                    selectedRegion =
                                        v;
                                  });
                                },
                                onMinistryChanged:
                                    (v) {
                                  setState(() {
                                    selectedMinistry =
                                        v;
                                  });
                                },
                                onApplyFilters: () {
                                  setState(() {
                                    appliedStartDate =
                                        startDate;
                                    appliedEndDate =
                                        endDate;
                                    appliedType =
                                        selectedType;
                                    appliedRegion =
                                        selectedRegion;
                                    appliedMinistry =
                                        selectedMinistry;
                                  });
                                },
                                onResetFilters: () {
                                  setState(() {
                                    startDate = null;
                                    endDate = null;
                                    selectedType =
                                        'all';
                                    selectedRegion =
                                        'all';
                                    selectedMinistry =
                                        'all';

                                    appliedStartDate =
                                        null;
                                    appliedEndDate =
                                        null;
                                    appliedType =
                                        'all';
                                    appliedRegion =
                                        'all';
                                    appliedMinistry =
                                        'all';
                                  });
                                },
                              ),
                              const SizedBox(
                                  height: 16),
                              Text(
                                'ملخص عام',
                                style: theme
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                  height: 8),
                              _SummaryGrid(
                                totalComplaints:
                                    totalComplaints,
                                resolvedCount:
                                    resolvedCount,
                                openCount: openCount,
                                avgResolutionDays:
                                    avgResolutionDays,
                                resolvedPercent:
                                    resolvedPercent,
                              ),
                              const SizedBox(
                                  height: 16),
                              _ComplaintsByMinistrySection(
                                totalComplaints:
                                    totalComplaints,
                                byMinistry:
                                    byMinistry,
                              ),
                              const SizedBox(
                                  height: 16),
                              _ComplaintsOverTimeSection(
                                countsByMonth:
                                    countsByMonth,
                              ),
                              const SizedBox(
                                  height: 16),
                            ],
                          ),
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

// ====================== الفلترة ======================

class _FilterSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedType;
  final String? selectedRegion;
  final String? selectedMinistry;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onRegionChanged;
  final ValueChanged<String?> onMinistryChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onResetFilters;

  const _FilterSection({
    required this.startDate,
    required this.endDate,
    required this.selectedType,
    required this.selectedRegion,
    required this.selectedMinistry,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onTypeChanged,
    required this.onRegionChanged,
    required this.onMinistryChanged,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    String startLabel = 'غير محدد';
    String endLabel = 'غير محدد';

    if (startDate != null) {
      startLabel =
          '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      endLabel =
          '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    }

    final baseDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      fillColor: theme.cardColor,
      filled: true,
      hintStyle: theme.textTheme.bodySmall?.copyWith(
        fontSize: 13,
        color: theme.hintColor,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 360;
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'تصفية التقارير',
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 8) / 2
                        : constraints.maxWidth,
                    child: _LabeledField(
                      label: 'تاريخ البدء',
                      child: TextField(
                        readOnly: true,
                        onTap: onPickStartDate,
                        decoration:
                            baseDecoration.copyWith(
                          hintText: startLabel,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 8) / 2
                        : constraints.maxWidth,
                    child: _LabeledField(
                      label: 'تاريخ الانتهاء',
                      child: TextField(
                        readOnly: true,
                        onTap: onPickEndDate,
                        decoration:
                            baseDecoration.copyWith(
                          hintText: endLabel,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 8) / 2
                        : constraints.maxWidth,
                    child: _LabeledField(
                      label: 'نوع الشكوى',
                      child: DropdownButtonFormField<
                          String>(
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('جميع الأنواع'),
                          ),
                          DropdownMenuItem(
                            value: 'roads',
                            child: Text('طرق'),
                          ),
                          DropdownMenuItem(
                            value: 'water',
                            child: Text('مياه'),
                          ),
                          DropdownMenuItem(
                            value: 'sanitation',
                            child: Text('صرف صحي'),
                          ),
                          DropdownMenuItem(
                            value: 'security',
                            child: Text('أمن عام'),
                          ),
                        ],
                        onChanged: onTypeChanged,
                        decoration: baseDecoration,
                        value: selectedType ?? 'all',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 8) / 2
                        : constraints.maxWidth,
                    child: _LabeledField(
                      label: 'المنطقة',
                      child:
                          DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('جميع المواقع'),
                          ),
                          DropdownMenuItem(
                            value: 'central',
                            child: Text('الوسطى'),
                          ),
                          DropdownMenuItem(
                            value: 'east',
                            child: Text('الشرقية'),
                          ),
                          DropdownMenuItem(
                            value: 'west',
                            child: Text('الغربية'),
                          ),
                          DropdownMenuItem(
                            value: 'north',
                            child: Text('الشمالية'),
                          ),
                          DropdownMenuItem(
                            value: 'south',
                            child: Text('الجنوبية'),
                          ),
                        ],
                        onChanged: onRegionChanged,
                        decoration: baseDecoration,
                        value: selectedRegion ?? 'all',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _LabeledField(
                      label: 'الوزارة',
                      child:
                          DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('جميع الوزارات'),
                          ),
                          DropdownMenuItem(
                            value: 'وزارة الكهرباء',
                            child: Text('وزارة الكهرباء'),
                          ),
                          DropdownMenuItem(
                            value: 'وزارة الموارد المائية',
                            child:
                                Text('وزارة الموارد المائية'),
                          ),
                          DropdownMenuItem(
                            value: 'وزارة الداخلية',
                            child: Text('وزارة الداخلية'),
                          ),
                          DropdownMenuItem(
                            value: 'وزارة الصحة',
                            child: Text('وزارة الصحة'),
                          ),
                        ],
                        onChanged: onMinistryChanged,
                        decoration: baseDecoration,
                        value: selectedMinistry ?? 'all',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor:
                            theme.colorScheme.onPrimary,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onApplyFilters,
                      child: const Text(
                        'تطبيق التصفية',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: theme.dividerColor),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onResetFilters,
                      child: Text(
                        'إعادة تعيين',
                        style: theme
                            .textTheme.bodyMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ====================== الملخص ======================

class _SummaryGrid extends StatelessWidget {
  final int totalComplaints;
  final int resolvedCount;
  final int openCount;
  final double avgResolutionDays;
  final double resolvedPercent;

  const _SummaryGrid({
    required this.totalComplaints,
    required this.resolvedCount,
    required this.openCount,
    required this.avgResolutionDays,
    required this.resolvedPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avgText = avgResolutionDays.toStringAsFixed(1);
    final resolvedPercentText =
        resolvedPercent.toStringAsFixed(0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 360;
        final cardWidth = isWide
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'إجمالي الشكاوى',
                value: totalComplaints.toString(),
                hint: 'حسب الفلاتر الحالية',
                trendIcon: '●',
                trendColor:
                    theme.colorScheme.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'تم حلها',
                value: resolvedCount.toString(),
                hint: '$resolvedPercentText% نسبة الحل',
                trendIcon: '●',
                trendColor: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'متوسط وقت الحل',
                value: totalComplaints == 0
                    ? '-'
                    : '$avgText يوم',
                hint:
                    'يُحسب من الفرق بين تاريخ الإنشاء والحل',
                trendIcon: '●',
                trendColor:
                    theme.colorScheme.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'شكاوى مفتوحة',
                value: openCount.toString(),
                hint: 'ما زالت قيد المتابعة',
                trendIcon: '●',
                trendColor:
                    theme.colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final String trendIcon;
  final Color trendColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.trendIcon,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style:
                    theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.hintColor,
                ),
              ),
              Text(
                trendIcon,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge
                ?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style:
                theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== الشكاوى حسب الوزارة ======================

class _ComplaintsByMinistrySection
    extends StatelessWidget {
  final int totalComplaints;
  final Map<String, int> byMinistry;

  const _ComplaintsByMinistrySection({
    required this.totalComplaints,
    required this.byMinistry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final total =
        totalComplaints == 0 ? 1 : totalComplaints;

    final entries =
        byMinistry.entries.toList()
          ..sort((a, b) =>
              b.value.compareTo(a.value));
    final top = entries.length > 6
        ? entries.sublist(0, 6)
        : entries;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'الشكاوى حسب الوزارة',
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'توزيع الشكاوى على الوزارات المختلفة (حسب البيانات الفعلية)',
            style:
                theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CustomPaint(
                          painter: _PieChartPainter(
                            entries: top,
                            total: total.toDouble(),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            totalComplaints
                                .toString(),
                            style: theme.textTheme
                                .titleLarge
                                ?.copyWith(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'إجمالي الشكاوى',
                            style: theme
                                .textTheme.bodySmall
                                ?.copyWith(
                              fontSize: 10,
                              color: theme.hintColor,
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
          const SizedBox(height: 8),
          _DynamicMinistryLegend(
            total: total,
            topMinistries: top,
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final double total;

  _PieChartPainter({
    required this.entries,
    required this.total,
  });

  Color _colorForIndex(int i) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF9CA3AF),
      Color(0xFFEF4444),
      Color(0xFFEAB308),
      Color(0xFF22C55E),
      Color(0xFF6366F1),
    ];
    return colors[i % colors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius =
        min(size.width, size.height) / 2;

    double startRadian = -pi / 2;

    for (int i = 0;
        i < entries.length;
        i++) {
      final value =
          entries[i].value.toDouble();
      if (value == 0) continue;
      final sweepRadian =
          (value / total) * 2 * pi;

      final paint = Paint()
        ..color = _colorForIndex(i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius - 10,
        ),
        startRadian,
        sweepRadian,
        false,
        paint,
      );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(
          covariant CustomPainter
              oldDelegate) =>
      true;
}

class _DynamicMinistryLegend
    extends StatelessWidget {
  final int total;
  final List<MapEntry<String, int>>
      topMinistries;

  const _DynamicMinistryLegend({
    required this.total,
    required this.topMinistries,
  });

  Color _colorForIndex(int i) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF9CA3AF),
      Color(0xFFEF4444),
      Color(0xFFEAB308),
      Color(0xFF22C55E),
      Color(0xFF6366F1),
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      itemCount: topMinistries.length,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 4,
      ),
      itemBuilder: (context, index) {
        final entry = topMinistries[index];
        final percent = (entry.value *
                100 /
                total)
            .toStringAsFixed(0);
        return _LegendItem(
          color: _colorForIndex(index),
          label: '${entry.key} ($percent%)',
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style:
                theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.hintColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ====================== الشكاوى بمرور الوقت ======================

class _ComplaintsOverTimeSection
    extends StatelessWidget {
  final Map<String, int>
      countsByMonth; // YYYY-MM -> count

  const _ComplaintsOverTimeSection({
    required this.countsByMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness ==
        Brightness.dark;

    final entries =
        countsByMonth.entries.toList()
          ..sort((a, b) =>
              a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'الشكاوى بمرور الوقت',
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'عدد الشكاوى لكل شهر ',
            style:
                theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(
                double.infinity,
                150,
              ),
              painter: _DynamicLineChartPainter(
                entries: entries,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: entries.isEmpty
                  ? [
                      Text(
                        'لا توجد بيانات كافية',
                        style: theme
                            .textTheme.bodySmall
                            ?.copyWith(
                          fontSize: 11,
                          color: theme.hintColor,
                        ),
                      ),
                    ]
                  : _buildMonthLabels(entries, theme),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonthLabels(
    List<MapEntry<String, int>> entries,
    ThemeData theme,
  ) {
    const maxLabels = 6;
    final step =
        (entries.length / maxLabels)
            .ceil()
            .clamp(1, 9999);
    final selected =
        <MapEntry<String, int>>[];

    for (int i = 0;
        i < entries.length;
        i += step) {
      selected.add(entries[i]);
    }

    return selected
        .map(
          (e) => Text(
            e.key,
            style: theme.textTheme.bodySmall
                ?.copyWith(
              fontSize: 10,
              color: theme.hintColor,
            ),
          ),
        )
        .toList();
  }
}

class _DynamicLineChartPainter
    extends CustomPainter {
  final List<MapEntry<String, int>> entries;

  _DynamicLineChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (entries.isEmpty) return;

    final maxValue = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final minValue = entries
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);

    final range = (maxValue - minValue)
        .clamp(1, 999999);

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < entries.length; i++) {
      final x = size.width *
          (i /
              (entries.length - 1)
                  .clamp(1, 9999));
      final normalized =
          (entries[i].value - minValue) /
              range;
      final y = size.height *
          (1 - normalized * 0.9);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(
          covariant CustomPainter
              oldDelegate) =>
      true;
}