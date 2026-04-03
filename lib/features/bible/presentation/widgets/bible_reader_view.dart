import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/features/bible/domain/models/verse.dart';
import '../providers/bible_controller.dart'; 

class BibleReaderView extends ConsumerStatefulWidget {
  const BibleReaderView({super.key});

  @override
  ConsumerState<BibleReaderView> createState() => _BibleReaderViewState();
}

class _BibleReaderViewState extends ConsumerState<BibleReaderView> {
  Map<String, dynamic>? _cachedBible;

  Future<Map<String, dynamic>> _loadBible() async {
    if (_cachedBible != null) return _cachedBible!;
    final String response = await rootBundle.loadString('assets/bible/kjv.json');
    _cachedBible = json.decode(response);
    return _cachedBible!;
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(bibleSearchProvider).toLowerCase();
    final bookmarks = ref.watch(bookmarkProvider);

    return Column(
      children: [
        _buildSearchBar(ref),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _loadBible(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) return const Center(child: Text("Word not found."));
              
              final bibleMap = snapshot.data!;
              final allBooks = bibleMap.keys
                  .map((k) => k.split(' ').getRange(0, k.split(' ').length - 1).join(' '))
                  .toSet()
                  .toList();
              
              if (searchQuery.isNotEmpty) {
                final bookMatches = allBooks
                    .where((b) => b.toLowerCase().contains(searchQuery))
                    .toList();
                
                if (bookMatches.isNotEmpty && searchQuery.length < 4) {
                  return _buildBookList(bookMatches, bibleMap);
                }
                return _buildVerseSearchList(bibleMap, searchQuery, bookmarks);
              }

              return _buildBookList(allBooks, bibleMap);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search books or verses...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (val) => ref.read(bibleSearchProvider.notifier).state = val,
      ),
    );
  }

  Widget _buildBookList(List<String> books, Map<String, dynamic> bibleMap) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) => ExpansionTile(
        maintainState: false,
        title: Text(books[index], style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [_ChapterSelector(bibleMap: bibleMap, bookName: books[index])],
      ),
    );
  }

  Widget _buildVerseSearchList(Map<String, dynamic> bibleMap, String query, List<Verse> bookmarks) {
    final results = bibleMap.entries
        .where((e) => e.value.toString().toLowerCase().contains(query))
        .toList();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        final isBookmarked = bookmarks.any((v) => "${v.book} ${v.chapter}:${v.verse}" == entry.key);

        return ListTile(
          title: Text(entry.value),
          subtitle: Text(entry.key, style: TextStyle(color: colorScheme.primary)),
          onLongPress: () => _copyVerse(entry.value, entry.key),
          trailing: IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            color: isBookmarked ? colorScheme.secondary : null,
            onPressed: () {
              final parts = entry.key.split(' ');
              final book = parts.sublist(0, parts.length - 1).join(' ');
              final refParts = parts.last.split(':');
              
              final verseObj = Verse(
                book: book,
                chapter: int.parse(refParts[0]),
                verse: int.parse(refParts[1]),
                text: entry.value,
              );
              
              _handleToggleBookmark(ref, verseObj, isBookmarked);
            },
          ),
        );
      },
    );
  }

  // --- Helper Methods ---

  void _handleToggleBookmark(WidgetRef ref, Verse verse, bool wasBookmarked) {
    ref.read(bookmarkProvider.notifier).toggleBookmark(verse);

    // Only show "Undo" if we just ADDED the bookmark
    if (!wasBookmarked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Clean up existing ones
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved ${verse.book} ${verse.chapter}:${verse.verse}"),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "UNDO",
            onPressed: () => ref.read(bookmarkProvider.notifier).toggleBookmark(verse),
          ),
        ),
      );
    }
  }

  void _copyVerse(String text, String reference) {
    Clipboard.setData(ClipboardData(text: "$text\n— $reference"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied $reference"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ChapterSelector extends ConsumerWidget {
  final Map<String, dynamic> bibleMap;
  final String bookName;

  const _ChapterSelector({required this.bibleMap, required this.bookName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final chapterNumbers = bibleMap.keys
        .where((key) => key.startsWith("$bookName "))
        .map((key) => key.split(' ').last.split(':').first)
        .toSet()
        .toList();

    return Column(
      children: chapterNumbers.map((ch) {
        return ExpansionTile(
          title: Text("Chapter $ch"),
          children: bibleMap.entries
              .where((entry) => entry.key.startsWith("$bookName $ch:"))
              .map((entry) {
            final verseKey = entry.key;
            final verseNumber = verseKey.split(':').last;
            final isBookmarked = bookmarks.any((v) => "${v.book} ${v.chapter}:${v.verse}" == verseKey);

            final verseObj = Verse(
              book: bookName,
              chapter: int.parse(ch),
              verse: int.parse(verseNumber),
              text: entry.value,
            );

            return ListTile(
              dense: true,
              title: Text("$verseNumber ${entry.value}"),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: "${entry.value}\n— $bookName $ch:$verseNumber"));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Verse copied"), behavior: SnackBarBehavior.floating),
                );
              },
              trailing: IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? colorScheme.secondary : null,
                ),
                onPressed: () {
                  ref.read(bookmarkProvider.notifier).toggleBookmark(verseObj);
                  
                  if (!isBookmarked) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Bookmark added"),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () => ref.read(bookmarkProvider.notifier).toggleBookmark(verseObj),
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}