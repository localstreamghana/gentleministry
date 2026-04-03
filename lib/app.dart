import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/core/navigation/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the routerProvider we defined
    final router = ref.watch(routerProvider);

    // 2. Use MaterialApp.router instead of MaterialApp
    return MaterialApp.router(
      title: 'Gentle Church',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 3. Connect the router configuration
      routerConfig: router,
    );
  }
}