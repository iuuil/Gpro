import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserRoleAndNavigate();
  }

  Future<void> _saveUserFcmTokenIfNeeded(User user, {required bool isAdmin}) async {
    if (isAdmin) {
      // المسؤول ما يحتاج fcmToken هنا (لو تحب تقدر تخزنه بمكان ثاني)
      return;
    }

    final messaging = FirebaseMessaging.instance;

    // طلب صلاحية الإشعارات (مهم في iOS، في أندرويد تمشي بدون بس عادي تطلبها)
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'fcmToken': token,
      },
      SetOptions(merge: true),
    );

    // تحديث الـ token إذا تغيّر أثناء عمل التطبيق
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'fcmToken': newToken,
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> _checkUserRoleAndNavigate() async {
    // نخلي السبلّاش تبقى شوية حتى يظهر الأنيميشن
    await Future.delayed(const Duration(seconds: 2));

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (!mounted) return;

    if (user == null) {
      // ماكو أحد مسجّل دخول → أعتبره مستخدم عادي وروحه للمين شيل
      Navigator.pushReplacementNamed(context, '/main-shell');
      return;
    }

    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (adminDoc.exists) {
        // مسؤول → ما نخزن fcmToken في users الآن (إلا إذا تريد إشعارات للمسؤولين بعدين)
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        // مستخدم عادي → نخزن fcmToken في users ثم نوديه للمين شيل
        await _saveUserFcmTokenIfNeeded(user, isAdmin: false);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main-shell');
      }
    } catch (e) {
      if (!mounted) return;
      // في حال خطأ نوديه للمسار الآمن (مستخدم عادي)
      Navigator.pushReplacementNamed(context, '/main-shell');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.report_problem_outlined,
                size: 120,
                color: Colors.white,
              ),
              SizedBox(height: 30),
              Text(
                'صوت المواطن',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'قدم شكواك بسهولة',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}