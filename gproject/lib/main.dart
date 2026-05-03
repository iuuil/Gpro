// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// الشاشات
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/complaints_center_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/admin_complaints_screen.dart';
import 'screens/ministries_screen.dart';
import 'screens/complaint_screen.dart';
import 'screens/education_complaint_screen.dart';
import 'screens/map_report_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/my_complaints_screen.dart';

// الثيم
import 'theme/app_theme.dart';

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
    url: 'https://mdtjrogdfggahrdcvyvr.supabase.co',
    anonKey: 'sb_publishable_YX6LQOG-K45iuKdvdGSaUg_8jkN2zR3',
  );

  // تهيئة الهاندلر للإشعارات في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

/// MyApp Stateful حتى نتحكم بالـ ThemeMode من الإعدادات
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isThemeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode'); // 'light' / 'dark' / 'system'

    setState(() {
      switch (saved) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case null:
        default:
          _themeMode = ThemeMode.light;
      }
      _isThemeLoaded = true;
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });

    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
      case ThemeMode.light:
      // ignore: unreachable_switch_default
      default:
        value = 'light';
    }
    await prefs.setString('themeMode', value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThemeLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'صوت المواطن',
      debugShowCheckedModeBanner: false,

      // اللغة
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

      // لضبط الـ RTL على كل الشاشات
      builder: (context, child) {
        final Widget safeChild = child ?? const SizedBox.shrink();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: safeChild,
        );
      },

      // ربط الثيم من AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      home: const SplashScreen(),

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/main-shell': (context) => const MainShellScreen(),
        '/home-screen': (context) => const HomeScreen(),
        '/education-complaint': (context) =>
            const EducationComplaintScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/my-complaints': (context) => const MyComplaintsScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-register': (context) => const AdminRegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-complaints': (context) =>
            const AdminComplaintsScreen(),
        '/ministries': (context) => const MinistriesScreen(),
        '/map-report-screen': (context) => const MapReportScreen(),
        '/complaints-center': (context) =>
            const ComplaintsCenterScreen(),
        '/complaint': (context) {
          final route = ModalRoute.of(context);
          final args = route?.settings.arguments;

          if (args == null || args is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(
                child: Text('لا توجد بيانات للشكوى'),
              ),
            );
          }

          return ComplaintScreen(
            ministry: args['ministry'] as String? ?? '',
            icon: Icons.apartment,
            logoUrl: args['logoUrl'] as String?,
          );
        },
      },
    );
  }
}