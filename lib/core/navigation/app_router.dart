import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentle_church/core/di/providers.dart';
import 'package:gentle_church/features/auth/presentation/pages/login_screen.dart';
import 'package:gentle_church/features/home/presentation/pages/home_screen.dart';
// Import your Profile widget - update path if different
import 'package:gentle_church/features/profile/presentation/widgets/profile_view.dart'; 
import 'package:gentle_church/features/bible/presentation/pages/bookmarks_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  // Create the stream and ensure it's disposed when the provider is destroyed
  final refreshNotifier = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges,
  );
  ref.onDispose(() => refreshNotifier.dispose());

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final user = authState.value;
      final bool isLoggedIn = user != null;
      final bool isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Sub-routes for cleaner navigation
          GoRoute(
            path: 'profile',
            builder: (context, state) => const Scaffold(
              body: ProfileView(),
            ),
          ),
          // Placeholder for your Bookmarks screen
          GoRoute(
            path: 'bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}