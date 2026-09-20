import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/robot_service.dart';
import 'theme/app_theme.dart';

class TelepresenceApp extends StatelessWidget {
  const TelepresenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RobotService()),
      ],
      child: MaterialApp(
        title: 'Robot Control',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
