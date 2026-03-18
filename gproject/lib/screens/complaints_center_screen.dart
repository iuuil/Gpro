import 'package:flutter/material.dart';
import 'complaint_details_screen.dart';

class ComplaintsCenterScreen extends StatefulWidget {
  const ComplaintsCenterScreen({super.key});

  @override
  State<ComplaintsCenterScreen> createState() => _ComplaintsCenterScreenState();
}

class _ComplaintsCenterScreenState extends State<ComplaintsCenterScreen> {
  static const Color primaryColor = Color(0xFF137FEC);

  String _selectedFilter = 'الكل';

  // بيانات الشكاوى (ثابتة مؤقتاً)
  final List<_ComplaintItem> _allComplaints = const [
    _ComplaintItem(
      title: 'حفر في الشارع الرئيسي',
      statusLabel: 'قيد المراجعة',
      statusType: ComplaintStatus.review,
      date: '2023-10-26',
      lastUpdate:
          'آخر تحديث: تم استلام الشكوى وتعيينها لدائرة الطرق. التوقع للحل خلال 7 أيام.',
    ),
    _ComplaintItem(
      title: 'انقطاع المياه، الكرادة',
      statusLabel: 'تم حلها',
      statusType: ComplaintStatus.resolved,
      date: '2023-10-20',
      lastUpdate:
          'آخر تحديث: تمت استعادة إمدادات المياه بالكامل في الكرادة. شكراً لصبركم. أغلقت القضية.',
    ),
    _ComplaintItem(
      title: 'تلوث ضوضائي من موقع بناء، المنصور',
      statusLabel: 'مرفوضة',
      statusType: ComplaintStatus.rejected,
      date: '2023-10-15',
      lastUpdate:
          'آخر تحديث: وجد التحقيق أن الموقع متوافق مع اللوائح. لا يمكن اتخاذ المزيد من الإجراءات.',
    ),
    _ComplaintItem(
      title: 'انقطاع الكهرباء، حي الدورة',
      statusLabel: 'قيد المراجعة',
      statusType: ComplaintStatus.review,
      date: '2023-11-01',
      lastUpdate:
          'آخر تحديث: تم إبلاغ وزارة الكهرباء بالانقطاع. الفنيون في الطريق. التقدير لإصلاح العطل بنهاية اليوم.',
    ),
    _ComplaintItem(
      title: 'رمي نفايات غير قانوني، مدينة الصدر',
      statusLabel: 'جديد',
      statusType: ComplaintStatus.newStatus,
      date: '2023-11-03',
      lastUpdate:
          'آخر تحديث: تم تسجيل شكوى جديدة. في انتظار التعيين للخدمات البلدية. رقم التتبع: COMP-2023-005.',
    ),
  ];

  List<_ComplaintItem> get _filteredComplaints {
    if (_selectedFilter == 'الكل') {
      return _allComplaints;
    }
    return _allComplaints
        .where((c) => c.statusLabel == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main-shell', // الصفحة الرئيسية
                            (route) => false,
                          );
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'حالة الشكاوى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                      width: 40, // مكان فاضي بدل أيقونة الإشعارات
                    ),
                  ],
                ),
              ),

              // فلاتر الحالة فقط
              SizedBox(
                height: 44,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('الكل'),
                    _buildFilterChip('قيد المراجعة'),
                    _buildFilterChip('تم حلها'),
                    _buildFilterChip('مرفوضة'),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نظرة عامة على شكواك',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // عرض الشكاوى بعد الفلترة
                      for (final c in _filteredComplaints) ...[
                        _StatusCard(
                          title: c.title,
                          statusLabel: c.statusLabel,
                          statusType: c.statusType,
                          date: c.date,
                          lastUpdate: c.lastUpdate,
                        ),
                        const SizedBox(height: 10),
                      ],
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

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              // ignore: deprecated_member_use
              ? primaryColor.withOpacity(0.2) // bg-primary/20
              : const Color(0xFFE5E7EB), // slate-200
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? primaryColor
                : const Color(0xFF374151), // slate-700
          ),
        ),
      ),
    );
  }
}

enum ComplaintStatus { review, resolved, rejected, newStatus, neww, underReview }

// كائن بسيط لتمثيل الشكوى
class _ComplaintItem {
  final String title;
  final String statusLabel;
  final ComplaintStatus statusType;
  final String date;
  final String lastUpdate;

  const _ComplaintItem({
    required this.title,
    required this.statusLabel,
    required this.statusType,
    required this.date,
    required this.lastUpdate,
  });
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String statusLabel;
  final ComplaintStatus statusType;
  final String date;
  final String lastUpdate;

  const _StatusCard({
    required this.title,
    required this.statusLabel,
    required this.statusType,
    required this.date,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(statusType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + شارة الحالة
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors['bg'],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors['text'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // التاريخ
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                'التاريخ: $date',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // آخر تحديث
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.update,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lastUpdate,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // زر عرض التفاصيل
          // داخل _StatusCard
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ComplaintDetailsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF137FEC),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF137FEC),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  static Map<String, Color> _statusColors(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.review:
        return {
          'bg': const Color(0xFFE0F2FE),
          'text': const Color(0xFF0369A1),
        };
      case ComplaintStatus.resolved:
        return {
          'bg': const Color(0xFFDCFCE7),
          'text': const Color(0xFF15803D),
        };
      case ComplaintStatus.rejected:
        return {
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFFB91C1C),
        };
      case ComplaintStatus.newStatus:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF374151),
        };
      case ComplaintStatus.neww:
        
        throw UnimplementedError();
      case ComplaintStatus.underReview:
        
        throw UnimplementedError();
    }
  }
}
