import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: unused_import
import '../screens/my_complaints_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFF137FEC);
  static const Color backgroundLight = Color(0xFFF6F7F8);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
    _testFirebase();
  }

  void _checkLoginState() {
    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('ping')
          .set({
        'time': DateTime.now().toIso8601String(),
        'source': 'home_screen',
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // الهيدر العلوي مع العنوان
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor ??
                      theme.cardColor, // يتبع الثيم
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'صوت المواطن',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // بانر علوي (كرت كبير)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuClxssmMsvRhdxAjOf6-rwnyTxTKT8O8o8T1mpzLxghWmHlOm4EYovFyh0PIFv36IoFhAaRjXWGg7Yz88lhfi6u_tkgSyApQtwbhg_8wUCQ3QH4taXYmpc7V8IrYTlaILjcpLDgz721CSzNJ6Fq9tWx-YKCNWdLmTaAbgbnaHbbf6KUZ4aUpPyEYa-fH-JBaCJZlnczMDViSfe83FMW7pTj3_7k9zFERByUwcKmCdVATq2i_ePTECd11L07mKfbEnX9Dj_Fnn-8MIh4',
                            ),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black54,
                              BlendMode.darken,
                            ),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 8),
                            Text(
                              'صوت المواطن',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'منصّة رقمية لعرض شكاوى المواطنين وربطها بالوزارات الحكومية المختصة.',
                              style: TextStyle(
                                color: Color(0xFFE5E7EB),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // نص ترحيبي
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'صوتك من أجل عراق أفضل',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'قدّم شكوى، بلّغ عن مشكلة خدمية، وساهم بتحسين أداء المؤسسات الحكومية.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // عنوان ما الذي تريد القيام به؟
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'ما الذي تريد القيام به؟',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // كروت الميزات
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _FeatureCard(
                              icon: Icons.edit_note,
                              title: 'تقديم شكوى',
                              description:
                                  'أنشئ وأرسل بلاغاً تفصيلياً مع وصف واضح وصور داعمة.',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/education-complaint',
                                );
                              },
                            ),
                            _FeatureCard(
                              icon: Icons.map_outlined,
                              title: 'تقديم شكوى من الخريطة',
                              description:
                                  'حدد موقع المشكلة على الخريطة أو أبلغ عن حادث مروري.',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/map-report-screen',
                                );
                              },
                            ),
                            _FeatureCard(
                              icon: Icons.rule_folder_outlined,
                              title: 'شكاواي',
                              description:
                                  'استعرض شكاواك السابقة وتابع حالة كل شكوى والتحديثات عليها.',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/my-complaints',
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),

              // شريط إنشاء حساب / تسجيل الدخول
              if (!_isLoggedIn)
                Container(
                  decoration: BoxDecoration(
                    color:
                        // ignore: deprecated_member_use
                        theme.cardColor.withOpacity(0.98), // بدل Colors.white
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HomeScreen.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HomeScreen.primaryColor,
                            side: const BorderSide(
                                color: HomeScreen.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin-login');
                        },
                        child: const Text(
                          'تسجيل الدخول كمسؤول',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF137FEC),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _FeatureCard({
    // ignore: unused_element_parameter
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double cardWidth =
        (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;

    return SizedBox(
      width: cardWidth,
      height: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor, // بدل Colors.white
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
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
              Icon(
                icon,
                color: HomeScreen.primaryColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}