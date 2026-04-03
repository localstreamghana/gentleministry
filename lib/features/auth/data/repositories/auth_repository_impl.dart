import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gentle_church/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance; // ← singleton (required in v7+)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AuthRepositoryImpl(this._auth);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ────────────────────────────────────────────────
  // Profile Management
  // ────────────────────────────────────────────────

  @override
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(newName.trim());
      await user.reload();
    }
  }

  @override
  Future<void> updatePhotoUrl(String url) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(url);
      await user.reload();
    }
  }

  @override
  Future<void> updateProfileImage(File image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final storageRef = _storage.ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');

      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      await updatePhotoUrl(downloadUrl);
    } catch (e) {
      throw Exception("Image Upload Failed: $e");
    }
  }

  // ────────────────────────────────────────────────
  // Authentication
  // ────────────────────────────────────────────────

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize (safe to call multiple times)
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null, // ← correct for v7+ (only idToken needed for Firebase)
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ────────────────────────────────────────────────
  // Church Social Features
  // ────────────────────────────────────────────────

  @override
  Future<void> addPrayerRequest(String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not signed in");

    await _firestore.collection('prayers').add({
      'text': text.trim(),
      'userName': user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
      'userPhoto': user.photoURL,
      'userId': user.uid,
      'amenCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addAmen(String prayerId) async {
    await _firestore.collection('prayers').doc(prayerId).update({
      'amenCount': FieldValue.increment(1),
    });
  }
}