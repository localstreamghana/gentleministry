import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();

  // Unified Profile Methods
  Future<void> updateDisplayName(String newName);
  Future<void> updatePhotoUrl(String url); 
  Future<void> updateProfileImage(File image);

  // Social features
  Future<void> addPrayerRequest(String text);
  Future<void> addAmen(String prayerId);
}