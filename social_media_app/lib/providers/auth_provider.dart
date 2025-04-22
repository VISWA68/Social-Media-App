import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media_app/screens/setup_screen.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

Future<bool> register(String email, String password, String username, [File? profilePic]) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    String? profileUrl;

    if (profilePic != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${userCredential.user!.uid}.jpg');
      await ref.putFile(profilePic);
      profileUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
      'username': username,
      'profileUrl': profileUrl,
    });

    return true;
  } catch (e) {
    print('Register error: $e');
    return false;
  }
}


 Future<bool> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
      forceCodeForRefreshToken: true,
    );
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final doc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
    if (!doc.exists && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SetupProfileScreen()),
      );
      return false;
    }

    return true;
  } catch (e) {
    print("Google sign-in error: $e");
    return false;
  }
}



  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}