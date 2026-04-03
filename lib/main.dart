import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/firebase_options.dart';
import 'package:gentle_church/core/theme/app_theme.dart';
import 'package:gentle_church/core/theme/theme_provider.dart';
import 'package:gentle_church/core/navigation/app_router.dart';
import 'package:gentle_church/core/services/notification_service.dart';

// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. App Check
  await FirebaseAppCheck.instance.activate(
    providerAndroid:AndroidDebugProvider()
  );

  // 3. Initialize Notifications
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  // 4. Schedule notification AFTER the app is running
  // This prevents a 'stuck' splash screen if the OS delays the request
  NotificationService.scheduleDailyNotification();
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme state (Light, Dark, or System)
    final themeMode = ref.watch(themeProvider);
    
    // Watch the GoRouter configuration for navigation
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Gentle Church',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Router Configuration
      routerConfig: router,
    );
  }
}