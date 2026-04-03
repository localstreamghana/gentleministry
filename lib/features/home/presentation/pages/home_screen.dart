import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/core/di/providers.dart';
import 'package:gentle_church/features/profile/presentation/widgets/profile_view.dart';
import 'package:gentle_church/features/sermons/presentation/widgets/sermon_list_view.dart';
import 'package:gentle_church/features/prayer/presentation/widgets/prayer_wall_view.dart';
import 'package:gentle_church/features/bible/presentation/widgets/bible_reader_view.dart';
import 'package:gentle_church/features/bible/presentation/providers/daily_verse_provider.dart'; // Import your new provider
import 'package:gentle_church/core/utils/app_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SermonListView(),
    const BibleReaderView(),
    const PrayerWallView(),
    const ProfileView()
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await AppUtils.confirmExit(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gentle Church"),
        ),
        body: Column(
          children: [
            _WelcomeHeader(authState: authState),
            const _DailyVerseCard(), // Added the Daily Bread here
            const Divider(height: 1),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.unselectedWidgetColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.book_online_outlined), activeIcon: Icon(Icons.book_online), label: 'Sermons'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Bible'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Prayer'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final AsyncValue authState;
  const _WelcomeHeader({required this.authState});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning! Peace be with you";
    if (hour < 17) return "Good afternoon! Peace be with you";
    return "Good evening! Peace be with you";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), // Reduced bottom padding
      color: colorScheme.primary.withOpacity(0.08),
      child: authState.when(
        data: (user) {
          if (user == null) return const Text("Welcome, Guest");

          final String displayName = (user.displayName != null && user.displayName!.isNotEmpty)
              ? user.displayName!
              : (user.email?.split('@')[0] ?? "Member");

          return Text(
            "${_getGreeting()}, $displayName",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          );
        },
        loading: () => const Text("Updating...", style: TextStyle(fontSize: 15, color: Colors.grey)),
        error: (_, __) => const Text("Welcome to Gentle Church"),
      ),
    );
  }
}

class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(dailyVerseProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08), // Match the header background
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "DAILY BREAD",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                verse.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "- ${verse.book} ${verse.chapter}:${verse.verse}",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}