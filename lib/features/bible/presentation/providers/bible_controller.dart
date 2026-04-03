//import 'package:flutter_riverpod/flutter_riverpod.dart'; // Changed from legacy
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gentle_church/features/bible/domain/models/verse.dart';

// Provider to hold the search query
final bibleSearchProvider = StateProvider<String>((ref) => "");

// 1. Updated state type to List<VerseModel>
final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, List<Verse>>((ref) {
  return BookmarkNotifier();
});

class BookmarkNotifier extends StateNotifier<List<Verse>> {
  BookmarkNotifier() : super([]) {
    _loadBookmarks();
  }

  // 2. Convert saved strings back into VerseModel objects on load
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList('bible_bookmarks');
    
    if (rawList != null) {
      state = rawList.map((s) => Verse.fromRawString(s)).toList();
    }
  }

  // 3. Handle VerseModel objects instead of Strings
  Future<void> toggleBookmark(Verse verse) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if bookmark exists based on book, chapter, and verse
    final bool alreadyExists = state.any((v) => 
      v.book == verse.book && 
      v.chapter == verse.chapter && 
      v.verse == verse.verse
    );

    if (alreadyExists) {
      // Remove it
      state = state.where((v) => 
        !(v.book == verse.book && v.chapter == verse.chapter && v.verse == verse.verse)
      ).toList();
    } else {
      // Add it
      state = [...state, verse];
    }

    // 4. Save the list by converting objects back to raw strings
    final rawList = state.map((v) => v.toRawString()).toList();
    await prefs.setStringList('bible_bookmarks', rawList);
  }
}