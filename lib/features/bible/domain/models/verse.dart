class Verse { // Changed from VerseModel to Verse to match your UI's expectation
  final String book;
  final int chapter;
  final int verse;
  final String text;

  Verse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  String toRawString() => "$book|$chapter|$verse|$text";

  factory Verse.fromRawString(String raw) {
    final parts = raw.split('|');
    // Basic error handling in case a pipe is missing in the saved string
    if (parts.length < 4) {
      return Verse(book: 'Error', chapter: 0, verse: 0, text: 'Malformed data');
    }
    return Verse(
      book: parts[0],
      chapter: int.parse(parts[1]),
      verse: int.parse(parts[2]),
      text: parts[3],
    );
  }
}