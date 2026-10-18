import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _navigated = true;
        _goNext();
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (!_navigated && mounted) {
        _navigated = true;
        _goNext();
      }
    });
  }

  void _goNext() {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width * 0.7,
                height: size.width * 0.7,
                child: Lottie.asset(
                  'assets/lottie/Doctor.json',
                  controller: _ctrl,
                  onLoaded: (composition) {
                    _ctrl.duration = composition.duration;
                    if (mounted) _ctrl.forward();
                  },
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Your Health — Our Priority',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Stay safe and healthy with us',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
