import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFF137FEC);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SafeArea(
          child: Column(
            children: [
              // الجزء العلوي مع الصورة
              Container(
                height: 260,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuClxssmMsvRhdxAjOf6-rwnyTxTKT8O8o8T1mpzLxghWmHlOm4EYovFyh0PIFv36IoFhAaRjXWGg7Yz88lhfi6u_tkgSyApQtwbhg_8wUCQ3QH4taXYmpc7V8IrYTlaILjcpLDgz721CSzNJ6Fq9tWx-YKCNWdLmTaAbgbnaHbbf6KUZ4aUpPyEYa-fH-JBaCJZlnczMDViSfe83FMW7pTj3_7k9zFERByUwcKmCdVATq2i_ePTECd11L07mKfbEnX9Dj_Fnn-8MIh4',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black54,
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.bottomRight,
                  child: const Text(
                    'صوت المواطن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'صوتك من أجل عراق أفضل',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D141B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ربط المواطنين بالوزارات الحكومية لحل قضايا الخدمة العامة بكفاءة وشفافية.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4C739A),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'كيف يعمل التطبيق',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D141B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // البطاقات
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _FeatureCard(
                            icon: Icons.edit_note,
                            title: 'تقديم شكوى',
                            description:
                                'أنشئ وأرسل تقريراً مع التفاصيل والصور.',
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
                        ],
                      ),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),

              // صناديق إنشاء الحساب / تسجيل الدخول إذا لم يكن مسجل
              if (!_isLoggedIn)
                Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFFF6F7F8).withOpacity(0.96),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                            fontSize: 17,
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
    final double cardWidth =
        (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;

    return SizedBox(
      width: cardWidth,
      // ارتفاع ثابت مثلاً 150 (غيّره حسب ما يعجبك)
      height: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFCFDBE7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: HomeScreen.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D141B),
                ),
              ),
              const SizedBox(height: 4),
              Expanded( // عشان النص يتمدد داخل المساحة المتبقية
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4C739A),
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
