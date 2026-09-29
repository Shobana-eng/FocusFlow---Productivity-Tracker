import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'themes/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ProductivityTrackerApp(),
    ),
  );
}

class ProductivityTrackerApp extends StatelessWidget {
  const ProductivityTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: AppTheme.lightTheme,

      // Dark Theme
      darkTheme: AppTheme.darkTheme,

      // Theme Mode
      themeMode: themeProvider.themeMode,

      home: const OnboardingScreen(),
    );
  }
}
