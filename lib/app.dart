import 'package:appoinment/screens/auth/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/api_constants.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme.dart';
import 'screens/profile/profile_screen.dart';

import 'screens/appointments/my_appointments_screen.dart';
import 'screens/appointments/appointment_details_screen.dart';

import 'screens/doctors/doctors_list_screen.dart';
import 'screens/departments/departments_list_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/filters/filters_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.getInstance(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final storage = snap.data!;
        final api = ApiService(baseUrl: ApiConstants.baseUrl, storage: storage);
        final authService = AuthService(api: api, storage: storage);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(authService: authService),
            ),
          ],
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return MaterialApp(
                title: 'Healthcare App',
                theme: AppTheme.light,
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                routes: {
                  '/': (_) => const SplashScreen(),
                  '/onboarding': (_) => const OnboardingScreen(),
                  '/login': (_) => const LoginPage(),
                  '/register': (_) => const RegisterScreen(),
                  '/forgot': (_) => const ForgotPasswordScreen(),
                  '/home': (_) => const HomeScreen(),

                  '/appointments': (_) => const MyAppointmentsScreen(),

                  '/appointment-details': (context) {
                    final args = ModalRoute.of(context)!.settings.arguments;

                    if (args is int) {
                      return AppointmentDetailScreen(appointmentId: args);
                    }

                    if (args is Map) {
                      final id = args['id'];
                      final appointmentId = (id is int)
                          ? id
                          : int.tryParse('$id');

                      if (appointmentId != null) {
                        return AppointmentDetailScreen(
                          appointmentId: appointmentId,
                        );
                      }
                    }

                    return const Scaffold(
                      body: Center(child: Text('No appointment id provided')),
                    );
                  },

                  '/profile': (_) => const ProfileScreen(),
                  '/doctors': (_) => const DoctorsListScreen(),
                  '/departments': (_) => const DepartmentsListScreen(),
                  '/notifications': (_) => const NotificationsScreen(),
                  '/filters': (_) => const FiltersScreen(),
                  '/otp': (context) {
                    final args =
                        ModalRoute.of(context)!.settings.arguments as Map;
                    return OtpScreen(
                      email: args['email'],
                      fullName: args['fullName'],
                      phone: args['phone'],
                      password: args['password'],
                      avatarPath: args['avatarPath'],
                    );
                  },
                },
              );
            },
          ),
        );
      },
    );
  }
}
