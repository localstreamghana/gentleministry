import 'package:cloud_firestore/cloud_firestore.dart';

class Sermon {
  final String id;
  final String title;
  final String speaker;
  final DateTime date;
  final String? videoUrl;

  Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.date,
    this.videoUrl,
  });

  // Factory to convert Firestore data to our Sermon object
  factory Sermon.fromFirestore(Map<String, dynamic> data, String id) {
    return Sermon(
      id: id,
      title: data['title'] ?? '',
      speaker: data['speaker'] ?? 'Guest Speaker',
      date: (data['date'] as Timestamp).toDate(),
      videoUrl: data['videoUrl'],
    );
  }
}