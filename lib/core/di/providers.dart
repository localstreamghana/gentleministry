import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentle_church/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gentle_church/features/auth/domain/entities/user_entity.dart';
import 'package:gentle_church/features/sermons/domain/models/sermon.dart';

// Firebase Auth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthProvider));
});

// ✅ FIXED: Map Firebase User → UserEntity
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {

  return ref
      .watch(authRepositoryProvider)
      .authStateChanges
      .map((user) {
        if (user == null) return null;

        return UserEntity(
          id: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
      });
});
final sermonsProvider = StreamProvider<List<Sermon>>((ref) {
  return FirebaseFirestore.instance
      .collection('sermons')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Sermon.fromFirestore(doc.data(), doc.id))
          .toList());
});

final prayersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('prayers')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id, // Now we have the ID for the button!
            };
          }).toList());
});
