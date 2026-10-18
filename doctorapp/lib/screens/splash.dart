import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // بعد 3 ثواني ننتقل تلقائيًا إلى شاشة البداية
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding'); // أو '/login'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // خلفية فاتحة
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض الأنيميشن
            Lottie.asset(
              'assets/json/Doctor.json', // المسار داخل مجلد assets
              width: 280,
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'Online Doctor App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A4C8A), // لون أزرق مميز
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your health, our priority',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
