import 'package:flutter/material.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  const ComplaintDetailsScreen({super.key});

  static const Color brandBlue = Color(0xFF4A76B8);
  static const Color brandLightBlue = Color(0xFFA3BCE0);
  static const Color bgGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر مع سهم رجوع
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
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
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'تفاصيل الشكوى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                      width: 40, // فراغ مقابل زر الرجوع
                    ),
                  ],
                ),
              ),

              // باقي المحتوى على عرض الصفحة
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نظرة عامة على الشكوى
                      _buildComplaintOverviewSection(),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // معلومات صاحب الشكوى
                      _buildComplainantInfoSection(),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // التعليقات الداخلية
                      _buildInternalCommentsSection(),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      // الرد الرسمي
                      _buildOfficialResponseSection(),
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

  // == Sections ==

  Widget _buildComplaintOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'قسم طريق عام متضرر في شارع الم (Elm Street)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'وصف المشكلة',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'تدهور قسم كبير من شارع الم بالقرب من تقاطع جادة مابل (Maple Avenue)، حيث تشكلت حفر وتشققات كبيرة. هذا يشكل خطراً جسيماً على...',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'المرفقات',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _AttachmentCard(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDqOBHqiyI44PKK8Zf7KH88G-45yax2-n4xILaTIV6ENtNgE0fEhnHbtqq7fZu-atJXHP4hFe0gq10-N_29Nlr-MigPrGwULyXl4iaLSZjKt8NC779IHBXHysAV4HmtSkvYozqdwteMexgAcTyUiXIxGpGLflpOGss31kcMhDbjyxW9cD6HiLqYM6K76OB_5iV7nVvwnMZZcyntAeBjNdUBePgh1w7EWTl2BwlW4p9LYVoH_1r_MtFRPkk0QdDEdjlVhNo9B5KIGBUd',
                fileName: 'pothole_01.jpg',
                sizeLabel: '2.3MB',
              ),
              SizedBox(width: 8),
              _AttachmentCard(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDvI9D5qehwEuoQwp_fN-J9jbC5CSYK8Ia9rDdsI_dHNKcHbtkTgwXgZmd1uxMCDyy9KmGIUgAbiUjtpT8_xeasB-p-kfa7YPbpCFomvGI5PtFBXTSOemfOTEulkhBEkf2JpSDeKyPmqgIr0cQx7Odw7_nyCkTUiWxwT54Vt1p2KTF8yOlpw-tCAaaaxOrnQ7ew_RW6JQAeCkwbhkn28WsPF2mcJ5ymfZrpKSQvrDT0xFKKPAaMghkKRNKqcdY6kwx9XRpnCHonvddY',
                fileName: 'damage_report.jpg',
                sizeLabel: '1.8MB',
              ),
              SizedBox(width: 8),
              _DocAttachmentCard(
                fileName: 'statement.pdf',
                sizeLabel: '0.5MB',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplainantInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات صاحب الشكوى',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: brandLightBlue,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBX54Tte0lYZp0TtfYGRH9WdWGieHIEdbSLKJnKGESR3ax2I1FKrfGo-7l_MNbwNRKmZbqwSiLQvVzbD6Mr0WIAZDf2dj6ftCQ4N_Q938rF3XnsBqJQTPfIxSooSZZ0gPCFuFv1mtlTQvkoSzzCfXMWgu7WbcbrfpsmOcpu0AMeBbAng_9ZQMfmTCJ3EBKoGrvJ6sQOVYhPl8s-XU0eeSbHoH89SRiaDzFOO8tePC6sje8UB3ct-72MmEhwkMkfHxEP3OLxYccAek7T',
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جين دو (Jane Doe)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email_outlined,
                        size: 12, color: Color(0xFF6B7280)),
                    SizedBox(width: 4),
                    Text(
                      'jane.doe@example.com',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_in_talk_outlined,
                        size: 12, color: Color(0xFF6B7280)),
                    SizedBox(width: 4),
                    Text(
                      '+1 (555) 123-4567',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'عرض الملف الشخصي',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInternalCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التعليقات الداخلية',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const _InternalCommentCard(
          author: 'المسؤول أ',
          datetime: '2023-10-26 10:30 ص',
          text:
              'تم تحويل الطلب إلى قسم صيانة الطرق للتقييم. في انتظار التقرير الأولي.',
        ),
        const SizedBox(height: 6),
        const _InternalCommentCard(
          author: 'المسؤول ب',
          datetime: '2023-10-26 02:15 م',
          text:
              'تمت المتابعة مع المهندس خان. أكد أنه تم إرسال فريق لمعاينة الموقع غداً.',
        ),
        const SizedBox(height: 10),
        const Text(
          'إضافة تعليق جديد',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'اكتب تعليقك الداخلي هنا...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: brandBlue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: brandBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'إضافة تعليق',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialResponseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الرد الرسمي',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'كتابة رسالة',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب ردك الرسمي للمواطن هنا...',
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: brandBlue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null, // disabled
            icon: const Icon(Icons.send, size: 18),
            label: const Text(
              'إرسال الرد',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandLightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// == Widgets مساعدة ==

class _AttachmentCard extends StatelessWidget {
  final String imageUrl;
  final String fileName;
  final String sizeLabel;

  const _AttachmentCard({
    required this.imageUrl,
    required this.fileName,
    required this.sizeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 60,
              width: double.infinity,
              color: const Color(0xFFD1D5DB),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
          Text(
            sizeLabel,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _DocAttachmentCard extends StatelessWidget {
  final String fileName;
  final String sizeLabel;

  const _DocAttachmentCard({
    required this.fileName,
    required this.sizeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined,
              size: 36, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 4),
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
          Text(
            sizeLabel,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding:
          const EdgeInsets.only(right: 10, left: 8, top: 6, bottom: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: ComplaintDetailsScreen.brandBlue, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                datetime,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
