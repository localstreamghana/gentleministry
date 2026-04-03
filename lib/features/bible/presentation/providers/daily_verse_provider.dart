import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/features/bible/domain/models/verse.dart';

// A small collection of encouraging verses for the "Daily" rotation
final List<Verse> encouragingVerses = [
  Verse(book: "Joshua", chapter: 1, verse: 9, text: "Have not I commanded thee? Be strong and of a good courage..."),
  Verse(book: "Philippians", chapter: 4, verse: 13, text: "I can do all things through Christ which strengtheneth me."),
  Verse(book: "Psalm", chapter: 23, verse: 1, text: "The Lord is my shepherd; I shall not want."),
  Verse(book: "Romans", chapter: 8, verse: 28, text: "And we know that all things work together for good to them that love God."),
  Verse(book: "Isaiah", chapter: 41, verse: 10, text: "Fear thou not; for I am with thee: be not dismayed; for I am thy God."),
];

final dailyVerseProvider = Provider<Verse>((ref) {
  // Picks a verse based on the current day of the year so it stays the same all day
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return encouragingVerses[dayOfYear % encouragingVerses.length];
});