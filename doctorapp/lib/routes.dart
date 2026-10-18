import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/departments_screen.dart';
import 'screens/doctors_list_screen.dart';
import 'screens/doctor_detail_screen.dart';
import 'screens/appointment_booking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/departments':
        return MaterialPageRoute(builder: (_) => DepartmentsScreen());
      case '/doctors':
        return MaterialPageRoute(builder: (_) => DoctorsListScreen());
      case '/doctor':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DoctorDetailScreen(doctorId: args?['id']),
        );
      case '/book':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AppointmentBookingScreen(doctorId: args?['id']),
        );
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => NotificationsScreen());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
