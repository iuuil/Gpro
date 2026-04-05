import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase لكل المنصات (Android / Web / iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

      // البداية تكون من MainShellScreen (مثل ما كانت)
      initialRoute: '/main-shell',
      routes: {
        '/main-shell': (context) => const MainShellScreen(),

        // لو تحتاج تستعمل HomeScreen لوحده
        '/home-screen': (context) => const HomeScreen(),

        '/education-complaint': (context) =>
            const EducationComplaintScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-register': (context) => const AdminRegisterScreen(),
        '/ministries': (context) => const MinistriesScreen(),
        '/splash': (context) => const SplashScreen(),
        '/map-report-screen': (context) => const MapReportScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-complaints': (context) =>
            const AdminComplaintsScreen(),
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