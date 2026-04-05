import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const double contentMaxWidth = 520;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر بدون أيقونة الإشعارات
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const SizedBox(
                      width: 48, // نفس تقريبا عرض IconButton حتى يبقى العنوان متوسّط
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: contentMaxWidth),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FilterSection(),
                          SizedBox(height: 16),
                          Text(
                            'ملخص عام',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8),
                          _SummaryGrid(),
                          SizedBox(height: 16),
                          _ComplaintsByTypeSection(),
                          SizedBox(height: 16),
                          _ComplaintsByLocationSection(),
                          SizedBox(height: 16),
                          _ComplaintsOverTimeSection(),
                          SizedBox(height: 16),
                          _ExportSection(),
                          SizedBox(height: 8),
                        ],
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
}

class _FilterSection extends StatelessWidget {
  const _FilterSection();

  @override
  Widget build(BuildContext context) {
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
      child: Column(
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 360;
              return Wrap(
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
                        decoration: _inputDecoration,
                        readOnly: true,
                        onTap: () {},
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
                        decoration: _inputDecoration,
                        readOnly: true,
                        onTap: () {},
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
                              value: 'all', child: Text('جميع الأنواع')),
                          DropdownMenuItem(value: 'roads', child: Text('طرق')),
                          DropdownMenuItem(value: 'water', child: Text('مياه')),
                          DropdownMenuItem(
                              value: 'sanitation', child: Text('صرف صحي')),
                        ],
                        onChanged: (v) {},
                        decoration: _inputDecoration,
                        initialValue: 'all',
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
                              value: 'all', child: Text('جميع المواقع')),
                          DropdownMenuItem(
                              value: 'north', child: Text('المنطقة الشمالية')),
                          DropdownMenuItem(
                              value: 'south', child: Text('المنطقة الجنوبية')),
                        ],
                        onChanged: (v) {},
                        decoration: _inputDecoration,
                        initialValue: 'all',
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
                              value: 'all', child: Text('جميع الوزارات')),
                          DropdownMenuItem(
                              value: 'transport', child: Text('وزارة النقل')),
                          DropdownMenuItem(
                              value: 'environment',
                              child: Text('وزارة البيئة')),
                          DropdownMenuItem(
                              value: 'health', child: Text('وزارة الصحة')),
                        ],
                        onChanged: (v) {},
                        decoration: _inputDecoration,
                        // ignore: deprecated_member_use
                        value: 'all',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminReportsScreen.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'تطبيق التصفية',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
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
      ),
    );
  }
}

const InputDecoration _inputDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
    borderSide: BorderSide(color: AdminReportsScreen.primaryColor, width: 1.5),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: const [
        _SummaryCard(
          label: 'إجمالي الشكاوى',
          value: '1,350',
          hint: 'آخر 30 يوم',
          trendIcon: '↑',
          trendColor: Color(0xFF16A34A),
        ),
        _SummaryCard(
          label: 'تم حلها',
          value: '1,080',
          hint: '80% نسبة الحل',
          trendIcon: '↑',
          trendColor: Color(0xFF16A34A),
        ),
        _SummaryCard(
          label: 'متوسط وقت الحل',
          value: '2.5 يوم',
          hint: '20% أسرع من السابق',
          trendIcon: '↓',
          trendColor: Color(0xFFEF4444),
        ),
        _SummaryCard(
          label: 'شكاوى مفتوحة',
          value: '270',
          hint: 'إجراءات قيد التنفيذ',
          trendIcon: '●',
          trendColor: Color(0xFF2563EB),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

class _ComplaintsByTypeSection extends StatelessWidget {
  const _ComplaintsByTypeSection();

  @override
  Widget build(BuildContext context) {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الشكاوى حسب النوع',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'توزيع الشكاوى عبر الفئات المختلفة',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 12,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF3B82F6),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1,350',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'إجمالي',
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
          SizedBox(height: 8),
          _ComplaintsByTypeLegend(),
        ],
      ),
    );
  }
}

class _ComplaintsByTypeLegend extends StatelessWidget {
  const _ComplaintsByTypeLegend();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 4,
      children: const [
        _LegendItem(color: Color(0xFF3B82F6), label: 'طرق (34%)'),
        _LegendItem(color: Color(0xFF9CA3AF), label: 'مياه (26%)'),
        _LegendItem(color: Color(0xFFEF4444), label: 'صرف صحي (19%)'),
        _LegendItem(color: Color(0xFFEAB308), label: 'أمن عام (13%)'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

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

class _ComplaintsByLocationSection extends StatelessWidget {
  const _ComplaintsByLocationSection();

  @override
  Widget build(BuildContext context) {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الشكاوى حسب الموقع',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'إجمالي الشكاوى والشكاوى التي تم حلها لكل منطقة',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _LocationBarGroup(
                    label: 'الوسطى',
                    totalHeightFactor: 0.8,
                    resolvedHeightFactor: 0.7,
                  ),
                ),
                Expanded(
                  child: _LocationBarGroup(
                    label: 'الشرقية',
                    totalHeightFactor: 0.6,
                    resolvedHeightFactor: 0.8,
                  ),
                ),
                Expanded(
                  child: _LocationBarGroup(
                    label: 'الغربية',
                    totalHeightFactor: 0.55,
                    resolvedHeightFactor: 0.4,
                  ),
                ),
                Expanded(
                  child: _LocationBarGroup(
                    label: 'الشمالية',
                    totalHeightFactor: 0.4,
                    resolvedHeightFactor: 0.3,
                  ),
                ),
                Expanded(
                  child: _LocationBarGroup(
                    label: 'الجنوبية',
                    totalHeightFactor: 0.3,
                    resolvedHeightFactor: 0.25,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LocationLegendItem(
                color: Color(0xFF2563EB),
                label: 'إجمالي الشكاوى',
              ),
              SizedBox(width: 16),
              _LocationLegendItem(
                color: Color(0xFF9CA3AF),
                label: 'التي تم حلها',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationBarGroup extends StatelessWidget {
  final String label;
  final double totalHeightFactor;
  final double resolvedHeightFactor;

  const _LocationBarGroup({
    required this.label,
    required this.totalHeightFactor,
    required this.resolvedHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxBarHeight = c.maxHeight * 0.8;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: maxBarHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: maxBarHeight * totalHeightFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: maxBarHeight * resolvedHeightFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3AF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LocationLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LocationLegendItem({
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _ComplaintsOverTimeSection extends StatelessWidget {
  const _ComplaintsOverTimeSection();

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            'التوجه الشهري للشكاوى المقدمة والمحلولة',
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
              painter: _SimpleLineChartPainter(),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MonthLabel('يناير'),
                _MonthLabel('فبراير'),
                _MonthLabel('مارس'),
                _MonthLabel('أبريل'),
                _MonthLabel('مايو'),
                _MonthLabel('يونيو'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthLabel extends StatelessWidget {
  final String text;
  const _MonthLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final bluePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final grayPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pathBlue = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.125,
        size.height * 0.5,
        size.width * 0.25,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width * 0.75,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.15,
        size.width,
        size.height * 0.1,
      );

    final pathGray = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.125,
        size.height * 0.7,
        size.width * 0.25,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.7,
        size.width * 0.75,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.4,
        size.width,
        size.height * 0.35,
      );

    canvas.drawPath(pathBlue, bluePaint);
    canvas.drawPath(pathGray, grayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExportSection extends StatelessWidget {
  const _ExportSection();

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصدير التقارير',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminReportsScreen.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
                shadowColor:
                    // ignore: deprecated_member_use
                    AdminReportsScreen.primaryColor.withOpacity(0.25),
              ),
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: const Text(
                'تصدير بصيغة PDF',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AdminReportsScreen.primaryColor),
                foregroundColor: AdminReportsScreen.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.insert_chart_outlined_rounded, size: 20),
              label: const Text(
                'تصدير بصيغة Excel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

