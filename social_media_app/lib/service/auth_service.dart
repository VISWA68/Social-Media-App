import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
