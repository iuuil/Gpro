// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// استخدم الـ prefix لتجنب التداخل
// ignore: library_prefixes
import 'complaint_details_screen.dart' as DetailsScreen;

class UserComplaintsListScreen extends StatelessWidget {
  final String status;
  final String title;

  const UserComplaintsListScreen({
    super.key,
    required this.status,
    required this.title,
  });

  static const Color primaryColor = Color(0xFF137FEC);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
          leading: SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF4B5563),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: user == null
            ? const Center(
                child: Text(
                  'يرجى تسجيل الدخول لعرض الشكاوى.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('complaints')
                    .where('userId', isEqualTo: user.uid)
                    .where('status', isEqualTo: status)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء جلب الشكاوى: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد شكاوى لعرضها.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      final title = (data['title'] as String?)?.trim().isNotEmpty == true
                          ? data['title'] as String
                          : (data['description'] as String? ?? 'بدون عنوان').toString();
                      final createdAt = (data['createdAt'] as Timestamp?)?.toDate().toString().split(' ').first;
                      final lastUpdate = data['lastUpdate'] as String? ?? 'لا توجد تحديثات متاحة حالياً.';

                      return _ComplaintListTile(
                        complaintId: doc.id,
                        title: title,
                        date: createdAt ?? '',
                        lastUpdate: lastUpdate,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ComplaintListTile extends StatelessWidget {
  final String complaintId;
  final String title;
  final String date;
  final String lastUpdate;

  const _ComplaintListTile({
    required this.complaintId,
    required this.title,
    required this.date,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // استخدم الـ prefix هنا
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen.ComplaintDetailsScreen(complaintId: complaintId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
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
            const SizedBox(height: 6),
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
          ],
        ),
      ),
    );
  }
}