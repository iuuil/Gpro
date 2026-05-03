// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/complaints_center_screen.dart';
import '../screens/admin_login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_register_screen.dart';
import '../screens/admin_complaints_screen.dart';
import '../screens/ministries_screen.dart';
import '../screens/complaint_screen.dart';
import '../screens/education_complaint_screen.dart';
import '../screens/map_report_screen.dart';
import '../screens/main_shell_screen.dart';
import '../screens/my_complaints_screen.dart';

// هاندلر للإشعارات في الخلفية (مطلوب من FCM)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ممكن تضيف لوجيك هنا لو تحتاج
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://mdtjrogdfggahrdcvyvr.supabase.co', // بدون /rest/v1/
    anonKey: 'sb_publishable_YX6LQOG-K45iuKdvdGSaUg_8jkN2zR3',
  );

  // تهيئة الهاندلر للإشعارات في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صوت المواطن',
      debugShowCheckedModeBanner: false,

      // اللغة والـ RTL
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },

      // البداية من SplashScreen حتى نحدد نوع المستخدم (مسؤول أو عادي)
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),

        // مستخدم عادي (Main Shell)
        '/main-shell': (context) => const MainShellScreen(),

        // لو تحتاج تستعمل HomeScreen لوحده
        '/home-screen': (context) => const HomeScreen(),

        '/education-complaint': (context) =>
            const EducationComplaintScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        '/my-complaints': (context) => const MyComplaintsScreen(),

        // صفحات المسؤول
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-register': (context) => const AdminRegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-complaints': (context) =>
            const AdminComplaintsScreen(),

        // باقي الصفحات
        '/ministries': (context) => const MinistriesScreen(),
        '/map-report-screen': (context) => const MapReportScreen(),
        '/complaints-center': (context) =>
            const ComplaintsCenterScreen(),

        // صفحة تقديم الشكوى مع arguments من MinistriesScreen
        '/complaint': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

          return ComplaintScreen(
            ministry: args['ministry'] as String,
            icon: Icons.apartment,
            logoUrl: args['logoUrl'] as String?,
          );
        },
      },
    );
  }
}