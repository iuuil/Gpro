// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ?? theme.cardColor,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.appBarTheme.foregroundColor ??
                  theme.textTheme.bodyLarge?.color,
            ),
          ),
          centerTitle: true,
          leading: SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: theme.appBarTheme.foregroundColor ??
                    theme.iconTheme.color ??
                    const Color(0xFF4B5563),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: user == null
            ? Center(
                child: Text(
                  'يرجى تسجيل الدخول لعرض الشكاوى.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.hintColor,
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
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء جلب الشكاوى: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد شكاوى لعرضها.',
                        style:
                            theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data =
                          doc.data() as Map<String, dynamic>? ?? {};

                      final String title =
                          (data['title'] as String?)
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? data['title'] as String
                              : (data['description'] as String? ??
                                      'بدون عنوان')
                                  .toString();

                      final createdAtTs =
                          data['createdAt'] as Timestamp?;
                      final createdAt = createdAtTs != null
                          ? createdAtTs
                              .toDate()
                              .toString()
                              .split(' ')
                              .first
                          : '';

                      final lastUpdate =
                          data['lastUpdate'] as String? ??
                              'لا توجد تحديثات متاحة حالياً.';

                      return _ComplaintListTile(
                        complaintId: doc.id,
                        title: title,
                        date: createdAt,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen.ComplaintDetailsScreen(
              complaintId: complaintId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            if (!isDark)
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
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: theme.iconTheme.color?.withOpacity(0.6) ??
                      const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  'التاريخ: $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.update,
                    size: 14,
                    color:
                        theme.iconTheme.color?.withOpacity(0.6) ??
                            const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lastUpdate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      color: theme.hintColor,
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