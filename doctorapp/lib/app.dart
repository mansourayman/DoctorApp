import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/api_constants.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'constants/app_colors.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container(
            color: AppColors.primary,
            child: Center(child: CircularProgressIndicator()),
          );
        final storage = snapshot.data!;
        final api = ApiService(baseUrl: ApiConstants.baseUrl, storage: storage);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AuthProvider(apiService: api, storage: storage),
            ),
          ],
          child: MaterialApp(
            title: 'Healthcare App',
            theme: ThemeData(primarySwatch: AppColors.materialPrimary),
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          ),
        );
      },
    );
  }
}
