import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/api_constants.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/appointments/book_appointment_screen.dart';
import 'screens/appointments/my_appointments_screen.dart';
import 'screens/appointments/appointment_details_screen.dart';
import 'screens/doctors/doctors_list_screen.dart';
import 'screens/departments/departments_list_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/filters/filters_screen.dart';
import 'screens/chat/chats_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.getInstance(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return MaterialApp(
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

                routes: {
                  '/': (_) => SplashScreen(),
                  '/onboarding': (_) => OnboardingScreen(),
                  '/login': (_) => LoginPage(),
                  '/register': (_) => RegisterScreen(),
                  '/forgot': (_) => ForgotPasswordScreen(),
                  '/home': (_) => HomeScreen(),

                  // Appointments
                  '/appointments': (_) => MyAppointmentsScreen(),

                  '/book': (context) {
                    final args = ModalRoute.of(context)!.settings.arguments;
                    if (args is Map<String, dynamic>) {
                      return BookAppointmentScreen(doctor: args);
                    }
                    return Scaffold(
                      body: Center(child: Text('No doctor provided')),
                    );
                  },

                  '/appointment-details': (context) {
                    final ap =
                    ModalRoute.of(context)!.settings.arguments as Map;
                    return AppointmentDetailsScreen(appointment: ap);
                  },

                  '/profile': (_) => ProfileScreen(),
                  '/doctors': (_) => DoctorsListScreen(),
                  '/departments': (_) => DepartmentsListScreen(),
                  '/notifications': (_) => NotificationsScreen(),
                  '/filters': (_) => FiltersScreen(),
                  '/chat': (_) => Chats(),
                },

                initialRoute: '/',
              );
            },
          ),
        );
      },
    );
  }
}