// ignore_for_file: unused_import, duplicate_ignore, deprecated_member_use, use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const double contentMaxWidth = 520;

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
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
    final complaintsRef =
        FirebaseFirestore.instance.collection('complaints');

    final Query baseQuery =
        complaintsRef.orderBy('createdAt', descending: true);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminReportsScreen.bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                    const Text(
                      'التقارير والإحصائيات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
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
                        child: Text(
                          'خطأ في تحميل البيانات: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }

                    var docs = snapshot.data?.docs ?? [];

                    // ===== تطبيق الفلاتر المطبقة =====

                    if (appliedType != null && appliedType != 'all') {
                      docs = docs.where((d) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        return data['type'] == appliedType;
                      }).toList();
                    }

                    if (appliedRegion != null && appliedRegion != 'all') {
                      docs = docs.where((d) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        return data['region'] == appliedRegion;
                      }).toList();
                    }

                    if (appliedMinistry != null &&
                        appliedMinistry != 'all') {
                      docs = docs.where((d) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        return data['ministry'] == appliedMinistry;
                      }).toList();
                    }

                    if (appliedStartDate != null) {
                      docs = docs.where((d) {
                        final data =
                            d.data() as Map<String, dynamic>;
                        final ts =
                            data['createdAt'] as Timestamp?;
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
                        final data =
                            d.data() as Map<String, dynamic>;
                        final ts =
                            data['createdAt'] as Timestamp?;
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
                          (data['status'] ?? 'open').toString();
                      final type =
                          (data['type'] ?? 'unknown').toString();
                      final ministry = (data['ministry'] ??
                              'غير محدد')
                          .toString();
                      final createdAt =
                          data['createdAt'] as Timestamp?;
                      final resolvedAt =
                          data['resolvedAt'] as Timestamp?;

                      byType[type] = (byType[type] ?? 0) + 1;
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
                              .difference(createdAt.toDate())
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
                          constraints: const BoxConstraints(
                            maxWidth: AdminReportsScreen
                                .contentMaxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _FilterSection(
                                startDate: startDate,
                                endDate: endDate,
                                selectedType: selectedType,
                                selectedRegion: selectedRegion,
                                selectedMinistry: selectedMinistry,
                                onPickStartDate: () async {
                                  final picked =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: startDate ??
                                        DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startDate = picked;
                                    });
                                  }
                                },
                                onPickEndDate: () async {
                                  final picked =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        endDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
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
                                    selectedRegion = v;
                                  });
                                },
                                onMinistryChanged: (v) {
                                  setState(() {
                                    selectedMinistry = v;
                                  });
                                },
                                onApplyFilters: () {
                                  setState(() {
                                    appliedStartDate = startDate;
                                    appliedEndDate = endDate;
                                    appliedType = selectedType;
                                    appliedRegion = selectedRegion;
                                    appliedMinistry =
                                        selectedMinistry;
                                  });
                                },
                                onResetFilters: () {
                                  setState(() {
                                    startDate = null;
                                    endDate = null;
                                    selectedType = 'all';
                                    selectedRegion = 'all';
                                    selectedMinistry = 'all';

                                    appliedStartDate = null;
                                    appliedEndDate = null;
                                    appliedType = 'all';
                                    appliedRegion = 'all';
                                    appliedMinistry = 'all';
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'ملخص عام',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _SummaryGrid(
                                totalComplaints: totalComplaints,
                                resolvedCount: resolvedCount,
                                openCount: openCount,
                                avgResolutionDays:
                                    avgResolutionDays,
                                resolvedPercent: resolvedPercent,
                              ),
                              const SizedBox(height: 16),
                              _ComplaintsByMinistrySection(
                                totalComplaints: totalComplaints,
                                byMinistry: byMinistry,
                              ),
                              const SizedBox(height: 16),
                              _ComplaintsOverTimeSection(
                                countsByMonth: countsByMonth,
                              ),
                              const SizedBox(height: 16),
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 360;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تصفية التقارير',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
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
                        decoration: _inputDecoration.copyWith(
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
                        decoration: _inputDecoration.copyWith(
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
                      child: DropdownButtonFormField<String>(
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
                        decoration: _inputDecoration,
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
                      child: DropdownButtonFormField<String>(
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
                        decoration: _inputDecoration,
                        value: selectedRegion ?? 'all',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _LabeledField(
                      label: 'الوزارة',
                      child: DropdownButtonFormField<String>(
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
                            child: Text('وزارة الموارد المائية'),
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
                        decoration: _inputDecoration,
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
                        backgroundColor:
                            AdminReportsScreen.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                        side: const BorderSide(
                            color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onResetFilters,
                      child: const Text(
                        'إعادة تعيين',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
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

const InputDecoration _inputDecoration = InputDecoration(
  isDense: true,
  contentPadding:
      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: AdminReportsScreen.primaryColor,
      width: 1.5,
    ),
  ),
  fillColor: Colors.white,
  filled: true,
  hintStyle: TextStyle(fontSize: 13),
);

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
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
    final avgText = avgResolutionDays.toStringAsFixed(1);
    final resolvedPercentText =
        resolvedPercent.toStringAsFixed(0);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: [
        _SummaryCard(
          label: 'إجمالي الشكاوى',
          value: totalComplaints.toString(),
          hint: 'حسب الفلاتر الحالية',
          trendIcon: '●',
          trendColor: const Color(0xFF2563EB),
        ),
        _SummaryCard(
          label: 'تم حلها',
          value: resolvedCount.toString(),
          hint: '$resolvedPercentText% نسبة الحل',
          trendIcon: '●',
          trendColor: const Color(0xFF16A34A),
        ),
        _SummaryCard(
          label: 'متوسط وقت الحل',
          value: totalComplaints == 0
              ? '-'
              : '$avgText يوم',
          hint: 'يُحسب من الفرق بين تاريخ الإنشاء والحل',
          trendIcon: '●',
          trendColor: const Color(0xFF2563EB),
        ),
        _SummaryCard(
          label: 'شكاوى مفتوحة',
          value: openCount.toString(),
          hint: 'ما زالت قيد المتابعة',
          trendIcon: '●',
          trendColor: const Color(0xFF2563EB),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
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
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== الشكاوى حسب الوزارة ======================

class _ComplaintsByMinistrySection extends StatelessWidget {
  final int totalComplaints;
  final Map<String, int> byMinistry;

  const _ComplaintsByMinistrySection({
    required this.totalComplaints,
    required this.byMinistry,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalComplaints == 0 ? 1 : totalComplaints;

    final entries = byMinistry.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top =
        entries.length > 6 ? entries.sublist(0, 6) : entries;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'الشكاوى حسب الوزارة',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'توزيع الشكاوى على الوزارات المختلفة (حسب البيانات الفعلية)',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
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
                            totalComplaints.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'إجمالي الشكاوى',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
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
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = min(size.width, size.height) / 2;

    double startRadian = -pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final value = entries[i].value.toDouble();
      if (value == 0) continue;
      final sweepRadian = (value / total) * 2 * pi;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      true;
}

class _DynamicMinistryLegend extends StatelessWidget {
  final int total;
  final List<MapEntry<String, int>> topMinistries;

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
    return GridView.builder(
      itemCount: topMinistries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 4,
      ),
      itemBuilder: (context, index) {
        final entry = topMinistries[index];
        final percent =
            (entry.value * 100 / total).toStringAsFixed(0);
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
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}

// ====================== الشكاوى بمرور الوقت ======================

class _ComplaintsOverTimeSection extends StatelessWidget {
  final Map<String, int> countsByMonth; // YYYY-MM -> count

  const _ComplaintsOverTimeSection({
    required this.countsByMonth,
  });

  @override
  Widget build(BuildContext context) {
    final entries = countsByMonth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'الشكاوى بمرور الوقت',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'عدد الشكاوى لكل شهر ',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _DynamicLineChartPainter(
                entries: entries,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: entries.isEmpty
                  ? const [
                      Text('لا توجد بيانات كافية'),
                    ]
                  : _buildMonthLabels(entries),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonthLabels(
      List<MapEntry<String, int>> entries) {
    const maxLabels = 6;
    final step =
        (entries.length / maxLabels).ceil().clamp(1, 9999);
    final selected = <MapEntry<String, int>>[];

    for (int i = 0; i < entries.length; i += step) {
      selected.add(entries[i]);
    }

    return selected
        .map(
          (e) => Text(
            e.key,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
        )
        .toList();
  }
}

class _DynamicLineChartPainter extends CustomPainter {
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

    final range = (maxValue - minValue).clamp(1, 999999);

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < entries.length; i++) {
      final x = size.width *
          (i / (entries.length - 1).clamp(1, 9999));
      final normalized =
          (entries[i].value - minValue) / range;
      final y = size.height * (1 - normalized * 0.9);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      true;
}
