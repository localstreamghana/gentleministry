class PrayerRequest {
  final String id;
  final String userId;
  final String userEmail;
  final String text;
  final DateTime createdAt;

  PrayerRequest({required this.id, required this.userId, required this.userEmail, required this.text, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userEmail': userEmail,
    'text': text,
    'createdAt': DateTime.now(),
  };
}