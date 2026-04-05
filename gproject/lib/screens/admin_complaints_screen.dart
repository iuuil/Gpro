import 'package:flutter/material.dart';

enum ComplaintStatus { all, neww, underReview, resolved, rejected }

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({
    super.key,
    this.initialFilter = ComplaintStatus.all,
  });

  final ComplaintStatus initialFilter;

  static const Color primaryColor = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  late ComplaintStatus _selectedFilter;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedFilter = widget.initialFilter; // نستلم الفلتر من الكونستركتور
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // بيانات تجريبية مطابقة تقريباً للي في الـ HTML
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '#8821',
      'title': 'شكوى ضوضاء',
      'ministry': 'وزارة البيئة',
      'citizen': 'المواطن: أحمد منصور',
      'date': '2023-10-25',
      'status': ComplaintStatus.neww,
    },
    {
      'id': '#8815',
      'title': 'صيانة طريق فرعي',
      'ministry': 'وزارة النقل',
      'citizen': 'المواطنة: سارة علي',
      'date': '2023-10-22',
      'status': ComplaintStatus.underReview,
    },
    {
      'id': '#8790',
      'title': 'انقطاع مياه متكرر',
      'ministry': 'وزارة المياه',
      'citizen': 'المواطن: محمد القحطاني',
      'date': '2023-10-18',
      'status': ComplaintStatus.resolved,
    },
    {
      'id': '#8765',
      'title': 'طلب إنارة شارع خاص',
      'ministry': 'وزارة الشؤون البلدية',
      'citizen': 'المواطن: فهد العتيبي',
      'date': '2023-10-15',
      'status': ComplaintStatus.rejected,
    },
  ];

  List<Map<String, dynamic>> get _filteredComplaints {
    final query = _searchController.text.trim();
    return _complaints.where((c) {
      // فلترة بالحالة
      if (_selectedFilter != ComplaintStatus.all &&
          c['status'] != _selectedFilter) {
        return false;
      }

      // فلترة بالبحث (ID أو اسم المواطن أو العنوان)
      if (query.isNotEmpty) {
        final text = '${c['id']} ${c['citizen']} ${c['title']}';
        if (!text.contains(query)) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminComplaintsScreen.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
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
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Color(0xFF020617),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'كل الشكاوى (عرض المسؤول)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF020617),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // حقل البحث
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'البحث برقم الشكوى أو اسم المواطن...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AdminComplaintsScreen.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // الفلاتر
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    _buildFilterChip(
                      label: 'الكل',
                      selected: _selectedFilter == ComplaintStatus.all,
                      onTap: () {
                        setState(() => _selectedFilter = ComplaintStatus.all);
                      },
                    ),
                    _buildFilterChip(
                      label: 'جديدة',
                      selected: _selectedFilter == ComplaintStatus.neww,
                      dotColor: Colors.blue,
                      onTap: () {
                        setState(
                            () => _selectedFilter = ComplaintStatus.neww);
                      },
                    ),
                    _buildFilterChip(
                      label: 'قيد المراجعة',
                      selected: _selectedFilter == ComplaintStatus.underReview,
                      dotColor: Colors.amber,
                      onTap: () {
                        setState(() =>
                            _selectedFilter = ComplaintStatus.underReview);
                      },
                    ),
                    _buildFilterChip(
                      label: 'تم الحل',
                      selected: _selectedFilter == ComplaintStatus.resolved,
                      dotColor: Colors.green,
                      onTap: () {
                        setState(
                            () => _selectedFilter = ComplaintStatus.resolved);
                      },
                    ),
                    _buildFilterChip(
                      label: 'مرفوضة',
                      selected: _selectedFilter == ComplaintStatus.rejected,
                      dotColor: Colors.red,
                      onTap: () {
                        setState(
                            () => _selectedFilter = ComplaintStatus.rejected);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // قائمة الشكاوى
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: _filteredComplaints
                        .map((c) => _ComplaintCard(data: c))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    Color? dotColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AdminComplaintsScreen.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AdminComplaintsScreen.primaryColor
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF1F2933),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كارت الشكوى الواحد
class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ComplaintCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final ComplaintStatus status = data['status'] as ComplaintStatus;

    Color sideColor;
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    switch (status) {
      case ComplaintStatus.neww:
        sideColor = Colors.blue;
        badgeBg = const Color(0xFFDBEAFE);
        badgeText = const Color(0xFF1D4ED8);
        badgeLabel = 'جديدة';
        break;
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
        sideColor = Colors.red;
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFB91C1C);
        badgeLabel = 'مرفوضة';
        break;
      case ComplaintStatus.all:
        sideColor = Colors.grey;
        badgeBg = const Color(0xFFE5E7EB);
        badgeText = const Color(0xFF374151);
        badgeLabel = 'غير محدد';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
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
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(14),
                  bottomEnd: Radius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان + الوزارة + البادج
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data['title']} - ID ${data['id']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AdminComplaintsScreen.primaryColor
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              data['ministry'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AdminComplaintsScreen.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data['citizen'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تاريخ التقديم: ${data['date']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

